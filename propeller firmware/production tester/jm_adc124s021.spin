'' =================================================================================================
''
''   File....... jm_adc124s021.spin 
''   Purpose.... Interface for ADC124S021 ADC chip (used on Propeller Activity Board)
''   Author..... Jon "JonnyMac" McPhalen
''               Copyright (c) 2013-14 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started.... 
''   Updated.... 09 OCT 2014
''
'' =================================================================================================

{{

   Note on object: The ADC returns the channel value set in the _previous_ read cycle, hence this
   code uses a double read each time to ensure the current channel value is returned.
   
}}  



con { fixed io pins }

  RX1 = 31                                                      ' programming / terminal
  TX1 = 30
  
  SDA = 29                                                      ' eeprom / i2c
  SCL = 28


var

  long  cs1                                                     ' active-low chip select
  long  cs2                                                     ' active-low chip select
  long  sck                                                     ' active-low clock
  long  mosi                                                    ' prop -> adc.di
  long  miso                                                    ' prop <- adc.do


pub start(cs1pin, cs2pin, sckpin, dipin, dopin)

'' Configure IO pins used by ADC
'' -- pins define connections to ADC124S021

  longmove(@cs1, @cs1pin, 5)                                    ' copy pins

  outa[cs1] := 1                                                ' output high to disable
  dira[cs1] := 1

  outa[cs2] := 1
  dira[cs2] := 1
  
  outa[sck] := 1                                                ' output high
  dira[sck] := 1 

  dira[miso] := 0                                               ' input (from adc)

  dira[mosi] := 1                                               ' output (to adc)

pub setArray | count
    count := 0
    repeat 8
      long[@ins+count] := read(count)
      count++    

pub readArray(ch)
    return long[@ins+ch]
 
pub read(ch) | ctrlbits, adcval

'' Reads adc (ADC124S021) channel, 0 - 3   or 4 - 7
'' -- returns 12-bit value

  if ((ch < 0) or (ch > 7))                                     ' validate channel
    return -1


  ctrlbits := ((ch << 3) << 24) | ((ch << 3) << 8)              ' config for two reads


  if (ch & $04 == 0)
    outa[cs1] := 0
  else
    outa[cs2] := 0                                              ' select device
  repeat 32                                                     ' two complete reads
    outa[sck] := 0                                              ' clock low
    outa[mosi] := (ctrlbits <-= 1)                              ' output control bits  
    adcval := (adcval << 1) | ina[miso]                         ' get result bit
    outa[sck] := 1                                              ' clock high

  outa[cs1] := 1                                                ' deselect both devices
  outa[cs2] := 1                                                ' deselect device

  return adcval & $0FFF                                         ' return 2nd read

dat
  ins long 0,0,0,0,0,0,0,0


{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to miso so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}