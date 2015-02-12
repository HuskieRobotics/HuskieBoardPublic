''*****************************************************
''*  MCP3008 10-bit/8-channel ADC Driver v1.0         *
''*  Modified by: Martin Hodge                        *
''*  Original Author: Chip Gracey                     *
''*  See end of file for terms of use.                *
''*  (This is just a slightly modified version of the *
''*  original MCP3208 object provided by Parallax)    *
''*****************************************************

VAR

  long  cog

  long  ins[4]          '7 contiguous longs (8 words + 1 long + 2 longs)
  long  count


PUB start(dpin, cpin, spin, mode) : okay

'' Start driver - starts a cog
'' returns false if no cog available
'' may be called again to change settings
''
''   dpin  = pin connected to both DIN and DOUT on MCP3x08
''   cpin  = pin connected to CLK on MCP3x08
''   spin  = pin connected to CS on MCP3x08
''   mode  = channel enables in bits 0..7, diff mode enables in bits 8..15

  stop
  longmove(@ins, @dpin, 4)
  return cog := cognew(@entry, @ins) + 1

PUB pointer
  '' Returns a pointer to ins
  return @ins

  
PUB stop

'' Stop driver - frees a cog

  if cog
    cogstop(cog~ - 1)


PUB in(channel) : sample

'' Read the current sample from an ADC channel (0..7)

  return ins.word[channel]


PUB average(channel, n) : sample | c

'' Average n samples from an ADC channel (0..7)

  c := count
  repeat n
    repeat while c == count
    sample += ins.word[channel]
    c++
  sample /= n

DAT

'************************************
'* Assembly language MCP3008 driver *
'************************************

                        org
'
'
' Entry
'
entry                   mov     t1,par                  'read parameters

                        call    #param                  'setup DIN/DOUT pin
                        mov     dmask,t2

                        call    #param                  'setup CLK pin
                        mov     cmask,t2

                        call    #param                  'setup CS pin
                        mov     smask,t2

                        call    #param                  'set mode
                        mov     enables,t3

'
'
' Perform conversions continuously
'
                        or      dira,cmask              'output CLK
                        or      dira,smask              'output CS

main_loop               mov     command,#$10            'init command
                        mov     t1,par                  'reset sample pointer
                        mov     t2,enables              'get enables
                        mov     t3,#8                   'ready 8 channels

cloop                   shr     t2,#1           wc      'if channel disabled, skip
        if_nc           jmp     #skip

                        test    t2,#$80         wc      'channel enabled, get single/diff mode
                        muxnc   command,#$08
                        mov     stream,command

                        or      outa,smask              'CS high
                        or      dira,dmask              'make DIN/DOUT output
                        mov     bits,#18                'ready 18 bits (cs+1+diff+ch[3]+0+0+data[10])


bloop                   test    stream,#$20     wc      'update DIN/DOUT
                        muxc    outa,dmask

                        cmp     bits,#12        wz      'if command done, input DIN/DOUT
        if_z            andn    dira,dmask

                        andn    outa,cmask              'CLK low
                        nop
                        nop
                        nop
                        or      outa,cmask              'CLK high

                        test    dmask,ina       wc      'sample DIN/DOUT
                        rcl     stream,#1

                        andn    outa,smask              'CS low

                        djnz    bits,#bloop             'next data bit


                        and     stream,mask10           'trim and write sample
                        wrword  stream,t1

skip                    add     t1,#2                   'advance sample pointer
                        add     command,#$01            'advance command
                        djnz    t3,#cloop               'more channels?

                        wrlong  counter,t1              'channels done, update counter
                        add     counter,#1

                        jmp     #main_loop              'perform conversions again
'
'
' Get parameter
'
param                   rdlong  t3,t1                   'get parameter into t3
                        add     t1,#4                   'point to next parameter

                        mov     t2,#1                   'make pin mask in t2
                        shl     t2,t3

param_ret               ret
'
'
mask10                  long    $3FF

t1                      res     1
t2                      res     1
t3                      res     1
t4                      res     1
dmask                   res     1
cmask                   res     1
smask                   res     1
enables                 res     1
command                 res     1
stream                  res     1
bits                    res     1
counter                 res     1

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
