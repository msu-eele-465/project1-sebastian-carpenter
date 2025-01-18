;-------------------------------------------------------------------------------
; Sebastian Carpenter, EELE 465, 1/18/25
;
; Project 1:
;   A 'heartbeat' program for the MSP430FR2355
;   
;   delay_1s:
;       subroutine utilizing polling to blink P1.0 at 0.5Hz.
;
;   TB0_interrupt_led_ISR:
;       interrupt routing toggling P6.6 at 1Hz (flash at 0.5Hz)
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
            .global __STACK_END
            .sect   .stack                  ; Make stack linker segment ?known?

            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs

RESET       mov.w   #__STACK_END,SP         ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT

;-------------------------------------------------------------------------------
; init START
;-------------------------------------------------------------------------------

init:
; --- LEDs ---
        ; setup P1.0 for Poll LED
        bic.b   #BIT0, &P1SEL0      ; digital I/O
        bic.b   #BIT0, &P1SEL1      ; digital I/O

        bis.b   #BIT0, &P1DIR       ; set as output
        bic.b   #BIT0, &P1OUT       ; clear output

; --- turn off low impedance ---

        bic.b	#LOCKLPM5, &PM5CTL0

;----------------------------------- init END ----------------------------------

;-------------------------------------------------------------------------------
; main START
;-------------------------------------------------------------------------------

main:
        call    #flash              ; flash the Poll LED, P1.0, to simulate MSP heartbeat

        jmp     main                ; infinite loop

;----------------------------------- main END ----------------------------------

;-------------------------------------------------------------------------------
; flash SUBROUTINE
;-------------------------------------------------------------------------------

; use polling to wait 1 second before toggling P1.0
flash:
        ; poll for 1 second before toggling Poll LED
        call    #delay_1s
        xor.b   #BIT0, &P1OUT

        ret

;--------------------------------- flash END ----------------------------------

;------------------------------------------------------------------------------
; delay_1s SUBROUTINE
;------------------------------------------------------------------------------

; use polling to wait about 1 second
delay_1s:
        mov.w   #01027d, R15       	; set R15 to represent outer loop for coarse grain adjustment

delay_1s_outer:
        mov.w   #00154h, R14       	; set R14 to represent inner loop for fine grain adjustment

delay_1s_inner:
        dec.w   R14
        jnz     delay_1s_inner      ; repeat inner loop for ~1ms

        dec.w   R15
        jnz     delay_1s_outer      ; repeat outer loop for ~1s

        ret
;---------------------------------- delay_1s END ------------------------------

;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   RESET_VECTOR            ; MSP430 RESET Vector
            .short  RESET                   ;
            .end
