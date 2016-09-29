/*
 * w1-gpio-cl
 * Command line configured gpio w1 bus master driver
 *
 * Copyright (c) 2016 Piotr Stolarz <pstolarz@o2.pl>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/gpio.h>
#include <linux/delay.h>

#if !defined(CONFIG_GPIOLIB) || !CONFIG_GPIOLIB
# error Kernel need to be configured with GPIOLIB support
#endif

#if (!defined(CONFIG_W1) || !CONFIG_W1) && \
	(!defined(CONFIG_W1_MODULE) || !CONFIG_W1_MODULE)
# error Kernel need to be configured with W1 support
#endif

#if CONFIG_W1_MAST_MAX <= 0
# error Incorrect or undefined CONFIG_W1_MAST_MAX
#endif

#include "w1/w1_int.h"
#include "gen-mast.h"

#define MODULE_NAME  "w1-gpio-cl"
#define LOG_PREF     MODULE_NAME ": "


struct mast_dta
{
	int gdt;    /* data wire gpio */
	int od;     /* data wire gpio is an open drain type of output */
	int bpu;    /* enable data wire bit-banged pull-up */
	int gpu;    /* pull-up gpio (-1: not configured) */
	int rev;    /* reverse logic for pull-up gpio */

	struct w1_bus_master *master;
	int delay;  /* requested pull-up delay */
};

static int n_mast;
static struct mast_dta mast_dtas[CONFIG_W1_MAST_MAX];

/*
 * W1 bus master bit read callback.
 */
static u8 w1_read_bit(void *data)
{
	struct mast_dta *mdt = (struct mast_dta*)data;

	return (gpio_get_value(mdt->gdt) ? 1 : 0);
}

/*
 * W1 bus master bit write callback.
 */
static void w1_write_bit(void *data, u8 bit)
{
	struct mast_dta *mdt = (struct mast_dta*)data;

	if (bit)
		gpio_direction_input(mdt->gdt);
	else
		gpio_direction_output(mdt->gdt, 0);
}

/*
 * W1 bus set pull-up callback.
 */
static u8 w1_set_pullup(void *data, int delay)
{
	struct mast_dta *mdt = (struct mast_dta*)data;

	if (delay) {
		mdt->delay = delay;
	} else {
		if (mdt->delay) {
			gpio_set_value(mdt->gpu, (mdt->rev ? 1 : 0));
			msleep(mdt->delay);
			gpio_set_value(mdt->gpu, (mdt->rev ? 0 : 1));
		}
		mdt->delay = 0;
	}

	return 0;
}

/*
 * W1 bus set bit-banged pull-up callback.
 */
static void w1_bitbang_pullup(void *data, u8 on)
{
	struct mast_dta *mdt = (struct mast_dta*)data;

	if (on)
		gpio_direction_output(mdt->gdt, 1);
	else
		gpio_direction_input(mdt->gdt);
}

/*
 * Get a token for parse_mast_conf().
 */
static size_t get_tkn(const char **p_str, const char **p_tkn)
{
	char c;

	/* cut leading spaces */
	while ((c=**p_str, c==' ' || c=='\t')) (*p_str)++;
	*p_tkn = *p_str;

	for (; (c=**p_str, c && c!=' ' && c!='\t'); (*p_str)++) {
		if (!((c >= '0' && c <= '9') ||
			  (c >= 'a' && c <= 'z') ||
			  (c >= 'A' && c <= 'Z')))
		{
			if (*p_str == *p_tkn) (*p_str)++;
			break;
		}
	}
	return *p_str - *p_tkn;
}

/*
 * Parse w1 master conf argument and write a result under mast_dta struct.
 * If success 0 is returned. In case some parameter is absent in the conf,
 * default value is assumed.
 */
static int parse_mast_conf(const char *arg, struct mast_dta *mdt)
{
	int val;
	const char *tkn;
	size_t ltkn;

	struct {
		unsigned gdt :1;
		unsigned od  :1;
		unsigned bpu :1;
		unsigned gpu :1;
		unsigned rev :1;
		unsigned val :1;
	} exts = {0};

	/* set defaults */
	mdt->gdt = mdt->gpu = -1;
	mdt->od = mdt->bpu = 0;

	for (ltkn = get_tkn(&arg, &tkn);
		ltkn;
		exts.gdt = exts.od = exts.bpu =
			exts.gpu = exts.rev =exts.val = 0)
	{
		/* param name */
		if (!strncmp(tkn, "gdt", ltkn)) {
			exts.gdt = 1;
		} else
		if (!strncmp(tkn, "od", ltkn)) {
			exts.od = 1;
		} else
		if (!strncmp(tkn, "bpu", ltkn)) {
			exts.bpu = 1;
		} else
		if (!strncmp(tkn, "gpu", ltkn)) {
			exts.gpu = 1;
		} else
		if (!strncmp(tkn, "rev", ltkn)) {
			exts.rev = 1;
		} else {
			/* unknown param */
			return -EINVAL;
		}

		/* value existence */
		ltkn = get_tkn(&arg, &tkn);
		if (ltkn > 0) {
			if (*tkn==':' || *tkn=='=') {
				ltkn = get_tkn(&arg, &tkn);
				if (ltkn) exts.val = 1;
			} else
			if (*tkn==',' || *tkn==';') {
				ltkn = get_tkn(&arg, &tkn);
			} else {
				/* malformed */
				return -EINVAL;
			}
		}

		/* value parsing */
		if (exts.gdt || exts.gpu) {
			if (exts.val)
			{
				/* integer */
				for (val=0; tkn<arg; tkn++) {
					if (*tkn>='0' && *tkn<='9') {
						val = val*10 + *tkn-'0';
					} else {
						/* parsing error */
						return -EINVAL;
					}
				}

				if (exts.gdt)
					mdt->gdt = val;
				else
					mdt->gpu = val;
			} else {
				/* value is required */
				return -EINVAL;
			}
		} else {
			/* od, bpu, rev */
			if (exts.val)
			{
				/* bool */
				if (tkn-arg==1 && (*tkn=='1' ||
					*tkn=='y' || *tkn=='Y'))
				{
					val = 1;
				} else
				if (tkn-arg==1 && (*tkn=='0' ||
					*tkn=='n' || *tkn=='N'))
				{
					val = 0;
				} else {
					/* parsing error */
					return -EINVAL;
				}
			} else {
				/* if no value is provided assume 1 */
				val = 1;
			}

			if (exts.od)
				mdt->od = val;
			else if (exts.bpu)
				mdt->bpu = val;
			else
				mdt->rev = val;
		}

		/* get the next token (if required) */
		if (exts.val) {
			ltkn = get_tkn(&arg, &tkn);
			if (ltkn > 0) {
				if (*tkn!=',' && *tkn!=';') {
					/* malformed */
					return -EINVAL;
				}
				ltkn = get_tkn(&arg, &tkn);
			}
		}
	}
	return 0;
}

/*
 * Module initialization.
 */
int init_module(void)
{
	int i, ret=0;
	struct mast_dta mdt;
	const char *marg;

	n_mast = 0;
	mdt.delay = 0;

	for (i=0; i<CONFIG_W1_MAST_MAX; i++) {
		if (!(marg = get_mast_arg(i))) continue;

		if ((ret = parse_mast_conf(marg, &mdt)) != 0) {
			printk(KERN_ERR LOG_PREF
				"Invalid arg format; m%d <%s>\n", i+1, marg);

			goto finish;
		}

		if (mdt.gdt < 0 || !gpio_is_valid(mdt.gdt)) {
			printk(KERN_ERR LOG_PREF
				"Invalid or not provided 'gdt' gpio;"
				" m%d <%s>\n", i+1, marg);

			ret = -EINVAL;
			goto finish;
		}

		if (mdt.gpu >= 0 && !gpio_is_valid(mdt.gpu)) {
			printk(KERN_ERR LOG_PREF
				"Invalid 'gpu' gpio; m%d <%s>\n", i+1, marg);

			ret = -EINVAL;
			goto finish;
		}

		if (mdt.od && (mdt.gpu < 0 && mdt.bpu)) {
			printk(KERN_ERR LOG_PREF
				"Can't enable data wire but-banged pull-up for"
				" open-drain gpio; m%d <%s>\n", i+1, marg);

			ret = -EINVAL;
			goto finish;
		}

		if (!mdt.od && (mdt.gpu >=0 && mdt.bpu)) {
			printk(KERN_ERR LOG_PREF
				"Be specific if pull-up should be enabled via"
				" bit-banging the data wire or an external "
				"gpio; m%d <%s>", i+1, marg);

			ret = -EINVAL;
			goto finish;
		}

		if ((ret = gpio_request_one(mdt.gdt,
			GPIOF_IN | (mdt.od ? GPIOF_OPEN_DRAIN : 0),
			MODULE_NAME)) != 0)
		{
			printk(KERN_ERR LOG_PREF
				"%d gpio request error: %d; m%d <%s>",
				mdt.gdt, ret, i+1, marg);
			goto finish;
		}

		if (mdt.gpu >= 0 &&
			(ret = gpio_request_one(mdt.gpu,
				(mdt.rev ?
					 GPIOF_OUT_INIT_LOW :
					 GPIOF_OUT_INIT_HIGH),
				MODULE_NAME)) != 0)
		{
			printk(KERN_ERR LOG_PREF
				"%d gpio request error: %d; m%d <%s>",
				mdt.gpu, ret, i+1, marg);
			goto finish;
		}

		mdt.master = (struct w1_bus_master*)kzalloc(
			sizeof(struct w1_bus_master), GFP_KERNEL);
		mast_dtas[n_mast++] = mdt;

		if (!mdt.master) {
			printk(KERN_CRIT LOG_PREF "No memory");
			ret = -ENOMEM;
			goto finish;
		}

		mdt.master->data = &mast_dtas[n_mast-1];
		mdt.master->read_bit = w1_read_bit;
		mdt.master->write_bit = w1_write_bit;

		if (mdt.gpu >= 0)
			mdt.master->set_pullup = w1_set_pullup;
		else if (mdt.bpu)
			mdt.master->bitbang_pullup = w1_bitbang_pullup;

		if ((ret = w1_add_master_device(mdt.master)) != 0) {
			kfree(mdt.master);
			mast_dtas[n_mast-1].master = NULL;

			printk(KERN_ERR LOG_PREF
				"w1_add_master_device error: %d", ret);
			goto finish;
		}
	}

	if (!n_mast) {
		printk(KERN_ERR LOG_PREF
			"No w1 master(s) specification. Exiting...");

		ret = -EINVAL;
		goto finish;
	}

finish:
	if (ret) cleanup_module();
	return ret;
}

/*
 * Module clean-up.
 */
void cleanup_module(void)
{
	int i;

	for (i=0; i < n_mast; i++) {
		if (mast_dtas[i].gdt >= 0) gpio_free(mast_dtas[i].gdt);
		if (mast_dtas[i].gpu >= 0) gpio_free(mast_dtas[i].gpu);
		if (mast_dtas[i].master) {
			w1_remove_master_device(mast_dtas[i].master);
			kfree(mast_dtas[i].master);
		}
	}
}

MODULE_VERSION("1.0");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Command line configured gpio w1 bus master driver");
MODULE_AUTHOR("Piotr Stolarz <pstolarz@o2.pl>");
/* vim: set noet ts=8 sw=8 sts=0: */
