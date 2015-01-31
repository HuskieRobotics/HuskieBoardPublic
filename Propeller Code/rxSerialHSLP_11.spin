{program rxSerialHSLP_11.spin  version 1.1   3-July-2011
author: Tracy Allen, copyright (c) 2011 MIT license  see below for terms of use

-- This is a receive-only uart, meant to allow low power operation at up to 115200 baud 1 stop bit while operating on a 5MHz clkfreq.
-- At 5Mhz, this code draws 0.7 mA (assuming rxserial pasm occupies one cog and another cog runs spin methods).
-- Higher baud rate possible at correspondingly higher clkfreq.  E.g. 1843200 baud at clkfreq=80MHz
-- Receives sustained 115kbaud packets with one stop bit.
-- same rx methods as fullDuplexSerial, but full duplex serial has too much overhead to receive 115-1 packets with 5MHz clkfreq.
-- Start bit is detected with a waitpeq for low latency.
-- This code does not test for framing errors.

revision history:
--1.1 buffer size any value up available free memory, not necessarily power of 2, using cmpsub instead of and.
--1.0 initial release

Pasm code has been structured for efficiency.
-- Technical note:
  One bit time at 115200 baud is 8.68 microseconds, time for 43 clock ticks at 5MHz, or 10 pasm instructions.
  Most critical is the time between testing for the midpoint of the final data bit and being ready for the next start bit
  That is 1.5 bit times, 13 microseconds, or 65 clock ticks at clkfreq-=5MHz. (1/2 of final data bit + stop bit)
  Time for 16 standard instructions, less if there is a hub instruction.
  The first hub access may take 8 to 22 clock ticks, then the second will hit the sweet spot with two instructions between.
  11 instructions take 44+3+4+(15) = 51 to 66 clock ticks, so the timing is just on the edge of missing head to tail 115200 baud.
  The final waitcnt assures that the stop bit is in progress before looping to look for a new start bit
  The pasm initialization deletes the final waitcnt to shorten the program when the ticks per bit is less than 80 (62500 baud and up)

rxPin:
    All objects should leave this pin as an input
modes:
     0) non-inverted, stop bits are high
     1) inverted, stop bits are low
baudrate:
     up to 115200 baud at clkfreq=5 MHz, 1843200 at clkfreq=80MHz
}

CON
  BUF_SIZ = 700                 ' can be any value, not necessarily a power of 2, up to available free memory.
  SCOPE = 14                    ' pin for optional 'scope output for debugging, normally not active code (see below)

VAR

  long  cog                     'cog flag/id

  long  rx_head                 '6 contiguous longs
  long  rx_tail
  long  rx_pin
  long  rx_mode                 ' 0 if non-inverted (stop=high), 1 if inverted (stop=low)
  long  bit_ticks
  long  buffer_ptr
                     
  byte  rx_buffer[BUF_SIZ]           ' receive buffer, not necessarily a power of two, any size up to memory limit.


PUB start(rxpin, mode, baudrate) : okay

'' Start serial driver - starts a cog
'' returns false if no cog available
''
'' mode     0:non-inverted     1:inverted

  stop
  longfill(@rx_head, 0, 4)
  longmove(@rx_pin, @rxpin, 2)
  bit_ticks := clkfreq / baudrate
  buffer_ptr := @rx_buffer
  okay := cog := cognew(@entry, @rx_head) + 1


PUB stop

'' Stop serial driver - frees a cog

  if cog
    cogstop(cog~ - 1)
  longfill(@rx_head, 0, 9)


PUB rxflush

'' Flush receive buffer

  repeat while rxcheck => 0
  
    
PUB rxcheck : rxbyte

'' Check if byte received (never waits)
'' returns -1 if no byte received, $00..$FF if byte

  rxbyte--
  if rx_tail <> rx_head
    rxbyte := rx_buffer[rx_tail]
    rx_tail := (rx_tail + 1) // buf_siz


PUB rxtime(ms) : rxbyte | t

'' Wait ms milliseconds for a byte to be received
'' returns -1 if no byte received, $00..$FF if byte

  t := cnt
  repeat until (rxbyte := rxcheck) => 0 or (cnt - t) / (clkfreq / 1000) > ms
  

PUB rx : rxbyte

'' Receive byte (may wait for byte)
'' returns $00..$FF

  repeat while (rxbyte := rxcheck) < 0


DAT

'***********************************
'* Assembly language serial driver *
'* receive only, waitpne for start bit *
'***********************************

                        org
'
'
' Entry
'
entry                   mov     t1,par                  ' get structure address
                        add     t1,#8                   ' skip past head and tail

                        rdlong  t2,t1                   ' get rx_pin
                        mov     rxmask,#1
                        shl     rxmask,t2

                        add     t1,#4                   ' get rx_mode
                        rdlong  rxmode,t1
                        mov     rxstart, rxmode         ' if inverted, then mode=1, start bit=1
                        shl     rxstart,t2
                        cmp     rxmode,#1        wz    ' 1 means inverted
                        muxz    invert,#$ff


                        add     t1,#4                   ' get bit_ticks
                        rdlong  bitticks,t1             ' clock ticks per regular bit
                        mov     bittocks,bitticks       ' adjust for the start bit
                        shr     bittocks,#1             ' 0.5 bit
                        add     bittocks,bitticks       ' 1.5 bits
                        sub     bittocks,#16            ' adjust for start bit setup time

                        cmp     bitticks,#80    wc
              if_c      mov     last1, last2            ' shorten the program, skip the final waitcnt for the stop bit

                        add     t1,#4                   'get buffer_ptr
                        rdlong  rxbuff,t1

                        mov     rxhead,#0               ' initial buffer pointer

                        andn     dira, rxmask           ' this cog makes rxpin an input (other cogs need to do the same!)

                         {the following 3 lines are commented out unless for debugging with 'scope
                         also lines below that reference scopePin}
                         'mov     scopePin,#1            ' for scoping bit sampling position
                         'shl     scopePin, #scope       ' dedicated pin # for scope on test setup
                         'or      dira,scopePin          ' scope pin needs to be an output


receive                 'xor     outa,scopePin           ' for debugging with 'scope
                        waitpeq rxstart,rxmask          ' wait for start bit.
                        mov     rxcnt,bittocks          ' timed to center of first data bit (1.5 byte)
                        add     rxcnt,cnt               ' primed for start bit waitcnt
                        mov     t2,rxhead               ' primed for data write location in hub
                        add     t2,rxbuff
                        mov     rxbits,#8               'receive byte, 8 bits, not including start and stop

:bit                    waitcnt rxcnt, bitticks         'wait target midpoint of each data bit
                        ' xor     outa,scopePin           ' commented out, unless 'scoping the signal
                        test    rxmask, ina     wc      ' state of the rx pin --> carry
                        rcr     rxdata, #1              ' shift in the bit
                        djnz    rxbits,#:bit

wrapup                  shr     rxdata, #24
                        xor     rxdata,invert           ' conditionally invert byte (can cut this out if not needed and timing critical)
                        wrbyte  rxdata,t2
                        add     rxhead,#1
                        cmpsub  rxhead,bufferSize
                        wrlong  rxhead,par
last1                   waitcnt rxcnt,#0               ' assures we are at the stop bit (this instruction deleted when bitticks<90)
last2                   jmp     #receive                'byte done, receive next byte




bufferSize             long BUF_SIZ

' Uninitialized data
'
t1                      res     1
t2                      res     1

rxmode                  res     1
rxstop                  res     1
rxstart                 res     1
bitticks                res     1
bittocks                res     1

rxhead                  res     1
rxmask                  res     1
rxbuff                  res     1
rxdata                  res     1
rxbits                  res     1
rxcnt                   res     1
rxends                  res     1
rxfinal                 res     1
invert                  res     1

scopePin                res     1


{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
