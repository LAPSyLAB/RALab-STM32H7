# STM32H750B-DK_CubeMX_Default Assembler Project

## Description 

Basic Assembler project for the board debug:

- adds two numbers
- each 0.5 sec LED diode changes state on/off
	- triggered by software delay loop 
		- counting up to 500 to switch LED

- derived from STM32H750B-DK_ASS_Basic project by trimming project settings and adding LED blinking

- currently it is debugged from RAM memory
	- FLASH/RAM can be selected in Project Settings -> Tool Settings -> MCU GCC Linker by selecting RAM or FLASH .ld script
	- works on board from FLASH/RAM
				
TODO:
	
	
	
