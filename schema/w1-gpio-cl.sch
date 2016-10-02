EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:maxim
LIBS:w1-gpio-cl-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 1550 1950 0    60   Input ~ 0
GPIO1
Text GLabel 1550 3150 0    60   Input ~ 0
GPIO2
$Comp
L R R?
U 1 1 57F00956
P 1950 1600
F 0 "R?" V 2030 1600 50  0001 C CNN
F 1 "Rpu" V 1950 1600 50  0000 C CNN
F 2 "" V 1880 1600 50  0000 C CNN
F 3 "" H 1950 1600 50  0000 C CNN
	1    1950 1600
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR?
U 1 1 57F00A3A
P 1950 1350
F 0 "#PWR?" H 1950 1200 50  0001 C CNN
F 1 "VCC" H 1950 1500 50  0000 C CNN
F 2 "" H 1950 1350 50  0000 C CNN
F 3 "" H 1950 1350 50  0000 C CNN
	1    1950 1350
	1    0    0    -1  
$EndComp
$Comp
L R R?
U 1 1 57F00BA9
P 1950 2800
F 0 "R?" V 2030 2800 50  0001 C CNN
F 1 "Rpu" V 1950 2800 50  0000 C CNN
F 2 "" V 1880 2800 50  0000 C CNN
F 3 "" H 1950 2800 50  0000 C CNN
	1    1950 2800
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR?
U 1 1 57F00C22
P 1950 2550
F 0 "#PWR?" H 1950 2400 50  0001 C CNN
F 1 "VCC" H 1950 2700 50  0000 C CNN
F 2 "" H 1950 2550 50  0000 C CNN
F 3 "" H 1950 2550 50  0000 C CNN
	1    1950 2550
	1    0    0    -1  
$EndComp
$Comp
L DS18B20 U?
U 1 1 57F00DE9
P 2900 1400
F 0 "U?" H 2750 1650 50  0001 C CNN
F 1 "DS18B20" H 2900 1150 50  0000 C CNN
F 2 "" H 2750 1650 50  0000 C CNN
F 3 "" H 2750 1650 50  0000 C CNN
	1    2900 1400
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR?
U 1 1 57F010A4
P 3000 1700
F 0 "#PWR?" H 3000 1450 50  0001 C CNN
F 1 "GND" H 3000 1550 50  0000 C CNN
F 2 "" H 3000 1700 50  0000 C CNN
F 3 "" H 3000 1700 50  0000 C CNN
	1    3000 1700
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR?
U 1 1 57F010F9
P 2800 1700
F 0 "#PWR?" H 2800 1550 50  0001 C CNN
F 1 "VCC" H 2800 1850 50  0000 C CNN
F 2 "" H 2800 1700 50  0000 C CNN
F 3 "" H 2800 1700 50  0000 C CNN
	1    2800 1700
	-1   0    0    1   
$EndComp
$Comp
L DS18B20 U?
U 1 1 57F012C0
P 3650 1400
F 0 "U?" H 3500 1650 50  0001 C CNN
F 1 "DS18B20" H 3650 1150 50  0000 C CNN
F 2 "" H 3500 1650 50  0000 C CNN
F 3 "" H 3500 1650 50  0000 C CNN
	1    3650 1400
	0    -1   -1   0   
$EndComp
$Comp
L VCC #PWR?
U 1 1 57F01683
P 3550 1700
F 0 "#PWR?" H 3550 1550 50  0001 C CNN
F 1 "VCC" H 3550 1850 50  0000 C CNN
F 2 "" H 3550 1700 50  0000 C CNN
F 3 "" H 3550 1700 50  0000 C CNN
	1    3550 1700
	-1   0    0    1   
$EndComp
$Comp
L GND #PWR?
U 1 1 57F0169A
P 3750 1700
F 0 "#PWR?" H 3750 1450 50  0001 C CNN
F 1 "GND" H 3750 1550 50  0000 C CNN
F 2 "" H 3750 1700 50  0000 C CNN
F 3 "" H 3750 1700 50  0000 C CNN
	1    3750 1700
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 57F030EA
P 3750 2950
F 0 "#PWR?" H 3750 2700 50  0001 C CNN
F 1 "GND" H 3750 2800 50  0000 C CNN
F 2 "" H 3750 2950 50  0000 C CNN
F 3 "" H 3750 2950 50  0000 C CNN
	1    3750 2950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 57F031C9
P 3000 2950
F 0 "#PWR?" H 3000 2700 50  0001 C CNN
F 1 "GND" H 3000 2800 50  0000 C CNN
F 2 "" H 3000 2950 50  0000 C CNN
F 3 "" H 3000 2950 50  0000 C CNN
	1    3000 2950
	1    0    0    -1  
$EndComp
$Comp
L DS18B20-PAR U?
U 1 1 57F0AFE1
P 2900 2500
F 0 "U?" H 2750 2750 50  0001 C CNN
F 1 "DS18B20-PAR" H 2900 2250 50  0000 C CNN
F 2 "" H 2750 2750 50  0000 C CNN
F 3 "" H 2750 2750 50  0000 C CNN
	1    2900 2500
	0    -1   -1   0   
$EndComp
Text GLabel 1550 4350 0    60   Input ~ 0
GPIO3
$Comp
L GND #PWR?
U 1 1 57F0BCBA
P 3000 4100
F 0 "#PWR?" H 3000 3850 50  0001 C CNN
F 1 "GND" H 3000 3950 50  0000 C CNN
F 2 "" H 3000 4100 50  0000 C CNN
F 3 "" H 3000 4100 50  0000 C CNN
	1    3000 4100
	1    0    0    -1  
$EndComp
$Comp
L R R?
U 1 1 57F0C069
P 1950 4000
F 0 "R?" V 2030 4000 50  0001 C CNN
F 1 "Rpu" V 1950 4000 50  0000 C CNN
F 2 "" V 1880 4000 50  0000 C CNN
F 3 "" H 1950 4000 50  0000 C CNN
	1    1950 4000
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR?
U 1 1 57F0C0D1
P 1950 3750
F 0 "#PWR?" H 1950 3600 50  0001 C CNN
F 1 "VCC" H 1950 3900 50  0000 C CNN
F 2 "" H 1950 3750 50  0000 C CNN
F 3 "" H 1950 3750 50  0000 C CNN
	1    1950 3750
	1    0    0    -1  
$EndComp
Text Notes 2600 3700 0    51   ~ 0
iButton Reader
Text Notes 4150 1650 0    51   ~ 0
m1="gdt:GPIO1"
Text Notes 4150 2750 0    51   ~ 0
m2="gdt:GPIO2,bpu"
Text Notes 4150 3950 0    51   ~ 0
m3="gdt:GPIO3"
Text GLabel 6600 2100 0    60   Input ~ 0
GPIO_DT
$Comp
L R R?
U 1 1 57F11AB2
P 7350 1650
F 0 "R?" V 7430 1650 50  0001 C CNN
F 1 "Rpu" V 7350 1650 50  0000 C CNN
F 2 "" V 7280 1650 50  0000 C CNN
F 3 "" H 7350 1650 50  0000 C CNN
	1    7350 1650
	1    0    0    -1  
$EndComp
Text GLabel 6600 1550 0    60   Input ~ 0
GPIO_PU
$Comp
L VCC #PWR?
U 1 1 57F121C8
P 7000 1150
F 0 "#PWR?" H 7000 1000 50  0001 C CNN
F 1 "VCC" H 7000 1300 50  0000 C CNN
F 2 "" H 7000 1150 50  0000 C CNN
F 3 "" H 7000 1150 50  0000 C CNN
	1    7000 1150
	1    0    0    -1  
$EndComp
$Comp
L DS18B20 U?
U 1 1 57F13447
P 3650 2500
F 0 "U?" H 3500 2750 50  0001 C CNN
F 1 "DS18B20" H 3650 2250 50  0000 C CNN
F 2 "" H 3500 2750 50  0000 C CNN
F 3 "" H 3500 2750 50  0000 C CNN
	1    3650 2500
	0    -1   -1   0   
$EndComp
$Comp
L Q_PMOS_GDS Q?
U 1 1 57F13865
P 6900 1550
F 0 "Q?" H 7550 1500 50  0001 R CNN
F 1 "Qpu" H 7200 1600 50  0000 R CNN
F 2 "" H 7100 1650 50  0000 C CNN
F 3 "" H 6900 1550 50  0000 C CNN
	1    6900 1550
	1    0    0    -1  
$EndComp
$Comp
L DS18B20-PAR U?
U 1 1 57F13FAF
P 8100 1450
F 0 "U?" H 7950 1700 50  0001 C CNN
F 1 "DS18B20-PAR" H 8100 1200 50  0000 C CNN
F 2 "" H 7950 1700 50  0000 C CNN
F 3 "" H 7950 1700 50  0000 C CNN
	1    8100 1450
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR?
U 1 1 57F140C5
P 8200 1900
F 0 "#PWR?" H 8200 1650 50  0001 C CNN
F 1 "GND" H 8200 1750 50  0000 C CNN
F 2 "" H 8200 1900 50  0000 C CNN
F 3 "" H 8200 1900 50  0000 C CNN
	1    8200 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	1950 2950 1950 3150
Connection ~ 1950 3150
Wire Wire Line
	1950 1750 1950 1950
Connection ~ 1950 1950
Wire Wire Line
	1950 1350 1950 1450
Wire Wire Line
	1950 2550 1950 2650
Wire Wire Line
	2900 1950 2900 1700
Connection ~ 2900 1950
Wire Wire Line
	3650 1700 3650 1950
Connection ~ 3650 1950
Wire Wire Line
	3750 2800 3750 2950
Connection ~ 2800 3150
Connection ~ 2800 4350
Wire Wire Line
	1950 4150 1950 4350
Connection ~ 1950 4350
Wire Wire Line
	1950 3750 1950 3850
Wire Wire Line
	2800 3850 2800 4350
Connection ~ 2800 3850
Wire Wire Line
	3000 3850 3000 4100
Connection ~ 3000 3850
Wire Notes Line
	2700 3750 3100 3750
Wire Notes Line
	3100 3750 3100 3950
Wire Notes Line
	3100 3950 2700 3950
Wire Notes Line
	2700 3950 2700 3750
Connection ~ 7000 2100
Wire Wire Line
	6600 1550 6950 1550
Connection ~ 3650 3150
Wire Wire Line
	3650 2800 3650 3150
Wire Wire Line
	3750 2900 3550 2900
Wire Wire Line
	3550 2900 3550 2800
Connection ~ 3750 2900
Wire Wire Line
	2800 2800 2800 3150
Wire Wire Line
	3000 2800 3000 2950
Connection ~ 8000 2100
Text Notes 7050 2550 0    51   ~ 0
m1="gdt:GPIO_DT,gpu:GPIO_PU,od"
$Comp
L DS18B20 U?
U 1 1 57F1236E
P 8850 1450
F 0 "U?" H 8700 1700 50  0001 C CNN
F 1 "DS18B20" H 8850 1200 50  0000 C CNN
F 2 "" H 8700 1700 50  0000 C CNN
F 3 "" H 8700 1700 50  0000 C CNN
	1    8850 1450
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR?
U 1 1 57F123AC
P 8950 1900
F 0 "#PWR?" H 8950 1650 50  0001 C CNN
F 1 "GND" H 8950 1750 50  0000 C CNN
F 2 "" H 8950 1900 50  0000 C CNN
F 3 "" H 8950 1900 50  0000 C CNN
	1    8950 1900
	1    0    0    -1  
$EndComp
Connection ~ 8850 2100
Wire Wire Line
	8950 1750 8950 1900
Wire Wire Line
	8850 1750 8850 2100
Wire Wire Line
	8750 1750 8750 1850
Wire Wire Line
	8750 1850 8950 1850
Connection ~ 8950 1850
Wire Wire Line
	8200 1750 8200 1900
Wire Wire Line
	8000 1750 8000 2100
Wire Wire Line
	7000 1750 7000 2100
Connection ~ 7350 2100
Wire Wire Line
	7000 1150 7000 1350
Wire Wire Line
	7350 1500 7350 1200
Wire Wire Line
	7350 1200 7000 1200
Connection ~ 7000 1200
Wire Wire Line
	7350 1800 7350 2100
Wire Wire Line
	1550 1950 4000 1950
Wire Wire Line
	1550 3150 4000 3150
Wire Wire Line
	1550 4350 4000 4350
Wire Wire Line
	6600 2100 9200 2100
$EndSCHEMATC
