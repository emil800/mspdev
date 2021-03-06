;******************************************************************************
;   MSP-FET430P140 Demo - Timer_B, Toggle P4.0-6, Cont. Mode ISR, XT2 SMCLK
;
;   Description: Use Timer_B CCRx units and overflow to generate eight
;   independent timing intervals. For demonstration, TBCCR0-6 output
;   units are optionally selected with P4.0-6 respectively in toggle
;   mode. As such, these pins will toggle when respective TBCCRx registers
;   match the TBR counter. Interrupts are also enabled with all TBCCRx units,
;   software only adds offset to next interval - as long as the interval
;   offset is aded to TBCCRx, toggle rate is generated in hardware. Timer_B
;   overflow ISR is used to toggle P1.0 with software. Proper use of the
;   TBIV interrupt vector generator is demonstrated.
;   MCLK = SMCLK = TBCLK = XT2 = HF XTAL
;   //* HF XTAL NOT INSTALLED ON FET *//
;   //* Min Vcc required varies with MCLK frequency - refer to datasheet *//	
;
;   As coded with TBCLK= HF XTAL and assuming HF XTAL= 8MHz, toggle rates are:
;   P4.0 = TBCCR0 = 8MHz/(2*200) = 20kHz
;   P4.1 = TBCCR1 = 8MHz/(2*400) = 10kHz
;   P4.2 = TBCCR2 = 8MHz/(2*500) = 8000Hz
;   P4.3 = TBCCR3 = 8MHz/(2*1000) = 4000Hz
;   P4.4 = TBCCR4 = 8MHz/(2*2000) = 2000Hz
;   P4.5 = TBCCR5 = 8MHz/(2*4000) = 1000Hz
;   P4.6 = TBCCR6 = 8MHz/(2*10000) = 400Hz
;   P1.0 = overflow = 8MHz/(2*65536) = 61Hz
;
;                MSP430F149
;             -----------------
;         /|\|            XT2IN|-
;          | |                 | 8Mhz
;          --|RST        XT2OUT|-
;            |                 |
;            |         P4.0/TB0|--> TBCCR0
;            |         P4.1/TB1|--> TBCCR1
;            |         P4.2/TB2|--> TBCCR2
;            |         P4.3/TB3|--> TBCCR3
;            |         P4.4/TB4|--> TBCCR4
;            |         P4.5/TB5|--> TBCCR5
;            |         P4.6/TB6|--> TBCCR6
;            |             P1.0|--> Overflow/software
;
;   M. Buccini / G. Morton
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430x14x.h"
;------------------------------------------------------------------------------
            .text                           ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #0A00h,SP               ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP4     bis.b   #07Fh,&P4SEL            ; P4.x - P4.6 option select
            bis.b   #07Fh,&P4DIR            ; P4.x = outputs
SetupP1     bis.b   #001h,&P1DIR            ; P1.0 = output
SetupBC     bic.b   #XT2OFF,&BCSCTL1        ; XT2 = HF XTAL
SetupOsc    bic.b   #OFIFG,&IFG1            ; Clear OSC fault flag
            mov.w   #0FFh,R15               ; R15 = Delay
SetupOsc1   dec.w   R15                     ; Additional delay to ensure start
            jnz     SetupOsc1               ;
            bit.b   #OFIFG,&IFG1            ; OSC fault flag set?
            jnz     SetupOsc                ; OSC Fault, clear flag again
            bis.b   #SELM_2+SELS,&BCSCTL2   ; MCLK = SMCLK = XT2
SetupCx     mov.w   #OUTMOD_4+CCIE,&TBCCTL0 ; TBCCR0 interrupt enabled
            mov.w   #OUTMOD_4+CCIE,&TBCCTL1 ; TBCCR1 interrupt enabled
            mov.w   #OUTMOD_4+CCIE,&TBCCTL2 ; TBCCR2 interrupt enabled
            mov.w   #OUTMOD_4+CCIE,&TBCCTL3 ; TBCCR3 interrupt enabled
            mov.w   #OUTMOD_4+CCIE,&TBCCTL4 ; TBCCR4 interrupt enabled
            mov.w   #OUTMOD_4+CCIE,&TBCCTL5 ; TBCCR5 interrupt enabled
            mov.w   #OUTMOD_4+CCIE,&TBCCTL6 ; TBCCR6 interrupt enabled
SetupTB     mov.w   #TBSSEL_2+MC_2+TBIE,&TBCTL  ; SMCLK, cont. mode, interrupt
                                            ;													
Mainloop    bis.w   #CPUOFF+GIE,SR          ; Enter LPM3, interrupts enabled
            nop                             ; Required for debugger
                                            ;
;------------------------------------------------------------------------------
TB0_ISR;    Toggle P1.0
;------------------------------------------------------------------------------
            add.w   #200,&TBCCR0            ; Offset until next interrupt
            reti                            ;		
;
;------------------------------------------------------------------------------
TBX_ISR;    Common ISR for TBCCR1-6 and overflow
;------------------------------------------------------------------------------
            add.w   &TBIV,PC                ; Add Timer_B offset vector
            reti                            ; CCR0 - no source
            jmp     TBCCR1_ISR              ; TBCCR1
            jmp     TBCCR2_ISR              ; TBCCR2
            jmp     TBCCR3_ISR              ; TBCCR3
            jmp     TBCCR4_ISR              ; TBCCR4
            jmp     TBCCR5_ISR              ; TBCCR5
            jmp     TBCCR6_ISR              ; TBCCR6
TB_over     xor.b   #001h,&P1OUT            ; Toggle P1.0
            reti                            ; Return from overflow ISR		
                                            ;
TBCCR1_ISR  add.w   #400,&TBCCR1            ; Offset until next interrupt
            jmp     TBX_ISR                 ;
                                            ;
TBCCR2_ISR  add.w   #500,&TBCCR2            ; Offset until next interrupt
            jmp     TBX_ISR                 ;
                                            ;
TBCCR3_ISR  add.w   #1000,&TBCCR3           ; Offset until next interrupt
            jmp     TBX_ISR                 ;
                                            ;
TBCCR4_ISR  add.w   #2000,&TBCCR4           ; Offset until next interrupt
            jmp     TBX_ISR                 ;
                                            ;
TBCCR5_ISR  add.w   #4000,&TBCCR5           ; Offset until next interrupt
            jmp     TBX_ISR                 ;
                                            ;
TBCCR6_ISR  add.w   #10000,&TBCCR6          ; Offset until next interrupt
            jmp     TBX_ISR                 ;
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int13"                ; Timer_B0 Vector
            .short  TB0_ISR                 ;
            .sect   ".int12"                ; Timer_BX Vector
            .short  TBX_ISR                 ;
            .end
