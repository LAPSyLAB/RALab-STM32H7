/*
 * Main.s
 *
 *  Created on: Aug 24, 2022
 *      Author: rozman
 */


  .syntax unified
  .cpu cortex-m7
  .thumb


///////////////////////////////////////////////////////////////////////////////
// Definitions
///////////////////////////////////////////////////////////////////////////////
// Definitions section. Define all the registers and
// constants here for code readability.

// Constants

	.equ     LEDDELAY,      64000

// For LOOPTC Software delay
// By default 64MHz internal HSI clock is enabled
// Internal loop takes N cycles

// Register Addresses
// You can find the base addresses for all peripherals from Memory Map section 2.3.2
// RM0433 on page 131. Then the offsets can be found on their relevant sections.

// RCC   base address is 0x58024400
//   AHB4ENR register offset is 0xE0
	.equ     RCC_AHB4ENR,   0x580244E0 // RCC AHB4 peripheral clock reg

// GPIOI base address is 0x58022000
	.equ     GPIOI_BASE,   0x58022000 // GPIOI base address)

//   MODER register offset is 0x00
	.equ     GPIOx_MODER,   0x00 // GPIOx port mode register
//   ODR   register offset is 0x14
	.equ     GPIOx_ODR,     0x14 // GPIOx output data register
//   BSSR   register offset is 0x18
	.equ     GPIOx_BSSR,     0x18 // GPIOx port set/reset register


// Values for BSSR register - pin 13: LED is on, when GPIO is off
	.equ     LEDs_OFF,       0x00002000   	// Setting pin to 1 -> LED is off
	.equ     LEDs_ON,   	 0x20000000   	// Setting pin to 0 -> LED is on

// Start of data section
 		.data

 		.align

STEV1: 	.word 	0x10   	// 32-bitna spr.
STEV2: 	.word 	0x40   	// 32-bitna spr.
VSOTA: 	.word 	0      	// 32-bitna spr.

LEDSTAT: .word  0		// LED Status



// Start of text section
  .text

  .type  main, %function
  .global main

   	   	.align
main:
  		ldr r0, =STEV1   // Naslov od STEV1 -> r0
  		ldr r1, [r0]    // Vsebina iz naslova v r0 -> r1

  		ldr r0, =STEV2   // Naslov od STEV1 -> r0
  		ldr r2, [r0]	// Vsebina iz naslova v r0 -> r2

  		add r3,r1,r2    // r1 + r2 -> r3

  		ldr r0, =VSOTA   // Naslov od STEV1 -> r0
  		str r3,[r0]		// iz registra r3 -> na naslov v r0

	    bl 	INIT_IO     // Priprava za kontrolo LED diode

loop:
		bl LED_ON       // Vklop LED diode

		mov r0,#500
		bl DELAY	 	// Zakasnitev: r0 x 1msec

		bl LED_OFF      // Izlop LED diode

		mov r0,#500
		bl DELAY	 	// Zakasnitev: r0 x 1msec

		b loop          // skok na vrstico loop:


__end: 	b 	__end



INIT_IO:
  	push {r5, r6, lr}

	// Enable GPIOI Peripheral Clock (bit 8 in AHB4ENR register)
	ldr r6, = RCC_AHB4ENR       // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, #0x00000100          // Set bit 8 to enable GPIOI clock
	str r5, [r6]                // Store result in peripheral clock register

	// Make GPIOI Pin13 as output pin (bits 27:26 in MODER register)
	ldr r6, =GPIOI_BASE       // Load GPIOD BASE address to r6
	ldr r5, [r6,#GPIOx_MODER]  // Read GPIOD_MODER content to r5
	and r5, #0xF3FFFFFF          // Clear bits 27-26 for P13
	orr r5, #0x04000000          // Write 01 to bits 27-26 for P13
	str r5, [r6]                // Store result in GPIO MODER register

  	pop {r5, r6, pc}



LED_ON:
    push {r5, r6, lr}
	// Set GPIOx Pins to 0 (through BSSR register)
	ldr    r6, =GPIOI_BASE       // Load GPIOI BASE address to r6
	mov    r5, #LEDs_ON
	str    r5, [r6,#GPIOx_BSSR] // Write to BSRR register
  	pop {r5, r6, pc}

LED_OFF:
    push {r5, r6, lr}
	// Set GPIOx Pins to 1 (through BSSR register)
	ldr    r6, =GPIOI_BASE       // Load GPIOI BASE address to r6
	mov    r5, #LEDs_OFF
	str    r5, [r6,#GPIOx_BSSR] // Write to BSRR register
  	pop {r5, r6, pc}


// Delay with internal SW loop approx. r0 x ms
DELAY:
    push {r1, lr}

MSEC: ldr r1,=LEDDELAY
LOOP:    subs r1, r1, #1
         bne LOOP

      subs r0, r0, #1
      bne MSEC
    pop {r1, pc}


