//******************************************************************************
//  MSP430F20x1 Demo - Comp_A, Output Reference Voltages on P1.1
//
//  Description: Output Comparator_A reference levels on P1.1. Program will
//  cycle through the on-chip comparator_A reference voltages with output on
//  P1.1. Normal mode is LPM0, TA0_ISR will interrupt LPM0.
//  ACLK = n/a, MCLK = SMCLK = default DCO
//
//		  MSP430F20x1
//             -----------------
//         /|\|              XIN|-
//          | |                 |
//          --|RST          XOUT|-
//            |                 |
//            |         P1.1/CA1|--> Vref
//            |                 |			
//
//  M. Buccini / L. Westlund
//  Texas Instruments Inc.
//  December 2005
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.40A
//******************************************************************************

#include  <msp430x20x1.h>

void delay(void);                           // Software delay

void main (void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  CACTL2 = P2CA4;                           // CA1/P1.1 = +comp
  CCTL0 = CCIE;                             // CCR0 interrupt enabled
  TACTL = TASSEL_2 + ID_3 + MC_2;           // SMCLK/8, cont-mode
  _EINT();                                  // enable interrupts

  while (1)                                 // Loop
  {
    CACTL1 = 0x00;                          // No reference voltage
    _BIS_SR(LPM0_bits);                     // Enter LPM0
    CACTL1 = CAREF0 + CAON;                 // 0.25*Vcc, Comp. on
    _BIS_SR(LPM0_bits);                     // Enter LPM0
    CACTL1 = CAREF1 + CAON;                 // 0.5*Vcc, Comp. on
    _BIS_SR(LPM0_bits);                     // Enter LPM0
    CACTL1 = CAREF1 + CAREF0 + CAON;        // 0.55V, Comp. on
    _BIS_SR(LPM0_bits);                     // Enter LPM0
  }
}

// Timer A0 interrupt service routine
#pragma vector=TIMERA0_VECTOR
__interrupt void Timer_A (void)
{
    _BIC_SR_IRQ(LPM0_bits);                 // Clear LPM0 bits from 0(SR)
}
