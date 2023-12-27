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

// GPIOA base address is 0x58020000
	.equ     GPIOA_BASE,   0x58020000 // GPIOI base address)

// GPIOI base address is 0x58022000
	.equ     GPIOI_BASE,   0x58022000 // GPIOI base address)

// GPIOJ base address is 0x58022000
	.equ     GPIOJ_BASE,   0x58022400 // GPIOJ base address)

//   MODER register offset is 0x00
	.equ     GPIOx_MODER,   0x00 // GPIOx port mode register
//   ODR   register offset is 0x14
	.equ     GPIOx_ODR,     0x14 // GPIOx output data register
//   BSSR   register offset is 0x18
	.equ     GPIOx_BSRR,     0x18 // GPIOx port set/reset register


// Values for BSRR register - pin 13: LED is on, when GPIO is off
	.equ     LED2_OFF,       0x00002000   	// Setting pin to 1 -> LED is off
	.equ     LED2_ON,   	 0x20000000   	// Setting pin to 0 -> LED is on

// Values for BSRR register - pin 2: LED is on, when GPIO is off
	.equ     LED1_OFF,       0x00000004   	// Setting pin to 1 -> LED is off
	.equ     LED1_ON,   	 0x00040000   	// Setting pin to 0 -> LED is on

// Values for BSRR register - pin 3: PA3
	.equ     PA3_ON,         0x00000008   	// Setting pin to 1
	.equ     PA3_OFF,        0x00080000   	// Setting pin to 0

// Vector table offset register definition
// Important for relocated Vector table on running from RAM
	.equ VTOR,0xE000ED08



// Start of data section
 		.data

 		.align

STEV1: 	.word 	0x10   	// 32-bitna spr.
STEV2: 	.word 	0x40   	// 32-bitna spr.
VSOTA: 	.word 	0      	// 32-bitna spr.

LED1:   .word   0		// LED1 State (Green)
LED2:   .word   0		// LED2 State (Red)
PA3:    .word   0		// PA3 pin State (Red)



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

	    bl 	INIT        // Priprava V/I in sistemskih naprav za kontrolo LED diod in PA3

        ldr r1,=LED1
        ldr r2,=LED2
        ldr r3,=PA3

        mov r4,#0xff    // LED(Pin) On value
        mov r5,#0       // LED(Pin) Off value

loop:

		str r4,[r1]     // Vklop LED1 diode
		str r5,[r2]     // Izklop LED2 diode
		str r4,[r3]     // Vklop PA3
        bl  WRITEOUT    // Prenesi na prikljucke

@      delay half cycle

		str r5,[r1]     // Izklop LED1 diode
		str r4,[r2]     // Vklop LED2 diode
		str r5,[r3]     // Izklop PA3
        bl  WRITEOUT    // Prenesi na prikljucke

@      delay half cycle

		b loop          // skok na vrstico loop:


__end: 	b 	__end


INIT:
  		push {lr}

        bl INIT_IO

        ldr r1, =VTOR // Set Vector table addr. to 0x24000000
		ldr r0, =0x24000000
		str r0, [r1]

	  	pop {pc}

INIT_IO:
  	push {r5, r6, lr}

	// Enable GPIOA,I,J Peripheral Clock (bit 8 in AHB4ENR register)
	ldr r6, = RCC_AHB4ENR       // Load peripheral clock reg address to r6
	ldr r5, [r6]                // Read its content to r5
	orr r5, #0x00000300         // Set bits 8 and 9 to enable GPIOI,J clock
	orr r5, #0x00000001         // Set bits 1 to enable GPIOA clock
	str r5, [r6]                // Store result in peripheral clock register

	// Make GPIOA Pin3 as output pin (bits 7:6 in MODER register)
	ldr r6, =GPIOA_BASE       // Load GPIOA BASE address to r6
	ldr r5, [r6,#GPIOx_MODER]  // Read GPIOA_MODER content to r5
	and r5, #0xFFFFFF3F          // Clear bits 7-6 for PA3
	orr r5, #0x00000040          // Write 01 to bits 7-6 for PA3
	str r5, [r6]                // Store result in GPIO MODER register

	// Make GPIOI Pin13 as output pin (bits 27:26 in MODER register)
	ldr r6, =GPIOI_BASE       // Load GPIOI BASE address to r6
	ldr r5, [r6,#GPIOx_MODER]  // Read GPIOI_MODER content to r5
	and r5, #0xF3FFFFFF          // Clear bits 27-26 for P13
	orr r5, #0x04000000          // Write 01 to bits 27-26 for P13
	str r5, [r6]                // Store result in GPIO MODER register

	// Make GPIOJ Pin2 as output pin (bits 5:4 in MODER register)
	ldr r6, =GPIOJ_BASE       // Load GPIOJ BASE address to r6
	ldr r5, [r6,#GPIOx_MODER]  // Read GPIOJ_MODER content to r5
	and r5, #0xFFFFFFCF          // Clear bits 5-4 for P2
	orr r5, #0x00000010          // Write 01 to bits 5-4 for PJ2
	str r5, [r6]                // Store result in GPIO MODER register

  	pop {r5, r6, pc}


WRITEOUT:

		push {r3, r4, r5, r6, lr}
// -----------------------------------
//      Set LED1 from LED1 variable
		ldr r3,=LED1 // Load LED1 value
		ldr r4,[r3]

		cmp r4,#0
		beq L1ON

		mov r5, #LED1_OFF
		b   CONT1
L1ON: 	mov r5, #LED1_ON

CONT1:  // Set GPIOJ Pins through BSRR register
		ldr r6, =GPIOJ_BASE // Load GPIOD BASE address to r6
		str r5, [r6,#GPIOx_BSRR] // Write to BSRR register

// -----------------------------------
//      Set LED2 from LED2 variable
		ldr r3,=LED2 // Load LED1 value
		ldr r4,[r3]

		cmp r4,#0
		beq L2ON

		mov r5, #LED2_OFF
		b   CONT2
L2ON: 	mov r5, #LED2_ON

CONT2:  // Set GPIOI Pins through BSRR register
		ldr r6, =GPIOI_BASE // Load GPIOD BASE address to r6
		str r5, [r6,#GPIOx_BSRR] // Write to BSRR register

// -----------------------------------
//      Set PA3 from PA3 variable
		ldr r3,=PA3 // Load PA3 value
		ldr r4,[r3]

		cmp r4,#0
		beq L3ON

		mov r5, #PA3_OFF
		b   CONT3
L3ON: 	mov r5, #PA3_ON

CONT3:  // Set GPIOA Pins through BSRR register
		ldr r6, =GPIOA_BASE // Load GPIOD BASE address to r6
		str r5, [r6,#GPIOx_BSRR] // Write to BSRR register


RET: 	pop {r3, r4, r5, r6, pc }

