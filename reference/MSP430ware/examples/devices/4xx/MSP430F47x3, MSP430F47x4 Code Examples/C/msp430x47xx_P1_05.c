//******************************************************************************
//   MSP430x47xx Demo - Write a byte to Port 1
//
//   Description: Writes a byte(FFh) to Port 1 and stays in LPM4
//   ACLK = 32.768kHz, MCLK = SMCLK = default DCO
//
//                MSP430x47xx
//             -----------------
//         /|\|                 |
//          | |                 |
//          --|RST              |
//            |                 |
//            |                 |
//            |                 |
//
//   P. Thanigai / K.Venkat
//   Texas Instruments Inc.
//   November 2007
//   Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.41A
//******************************************************************************
#include  <msp430xG46x.h>

void main(void)
{
  WDTCTL = WDTPW+WDTHOLD;                    // Stop WDT

  P1DIR |= 0x0FF;                            // P1.x output
  P1OUT |= 0x0FF;                            // Set all P1 pins HI

  _BIS_SR(LPM4_bits);                        // LPM4
}
