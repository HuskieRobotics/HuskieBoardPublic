{ Author: Brandon John}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  cog
  long  data[8]


CON ''TODO: Remove this section when testing is finished!
        adc_CS1     = 20        
        adc_CS2     = 19        
        adc_DO      = 21        
        adc_DI      = 23       
        adc_CLK     = 22
OBJ
        pst : "Parallax Serial Terminal"
PUB tester  | x
  start(adc_CS1,adc_CS2,adc_CLK,adc_DI,adc_DO)
  pst.start(115200)
  
  repeat
    'pst.bin(long[@data], 32)
    repeat x from 0 to 6
      pst.bin(readArray(x),12)
      pst.str(string(", "))
    pst.bin(readArray(7),12)
    pst.char(13)
    pst.char(13)
    waitcnt(cnt+clkfreq/10)

''END TODO: Remove this section.  
PUB stop                        ' Stop driver - frees a cog
  if cog
     cogstop(cog)

PUB start(cs1pin, cs2pin, sckpin, dipin, dopin)
  cs1_mask := |< cs1pin  
  cs2_mask := |< cs2pin
  clk_mask := |< sckpin
  miso_mask := |< dopin ' ADC DO
  mosi_mask := |< dipin ' ADC DI
  dir_mask := cs1_mask | cs2_mask | clk_mask | mosi_mask
  clear_mask := cs1_mask | cs2_mask | clk_mask
  volts0_loc := @data

  readcnt_max := 4  ''Todo: let the user define this value.
  
  cog := cognew(@ADC, 0)

pub readArray(channel)         'Read from a pre-filled array (using readToArray).
  return data[channel]

DAT
              org       0
ADC           mov       outa, clear_mask        'Turn both cs pins high, to deslect both devices. Also turn on the clock pin.
              mov       dira, dir_mask       

              
Main          mov       b, #1
              shl       b, readcnt_max          'Prepare to read 2^readcnt_max times, before dividing
:loop1        call      #ReadAllPins
              djnz      b, #:loop1              'Read all pins another time, if needed.
              
              mov       ch, #8                  'Loop through each pin
              'Do some averaging math on each channel - shift average left by readcnt_max.
:loop2        mov       temp, ch               'Calculate where to get this value.
              and       temp, #%111            ' We read ch0 as ch8, but it still needs to be read from the right spot.
              add       temp, #ins_sums        ' add sum array offset
              movs      :getsum, temp
              movd      :clearsum, temp        
:getsum       mov       volts_sum, 0-0          'Read ch's voltage sum
:clearsum     mov       0-0, #0                 'Clear the sum
              shr       volts_sum, readcnt_max  'Divide by the number of readings
              'Store the average value!
              sub       temp, #ins_sums        'remove the sum array offset, keep index calc.
              shl       temp, #2
              add       temp, volts0_loc       'Include volts output array offset               
              wrlong    volts_sum, temp        'Write "average volts" to volts output array

              djnz      ch, #:loop2                     'do this all again for the next pin.
              jmp       #Main                   'repeat forever.

ReadAllPins   mov       ch, #8                  
:loop         call      #ReadPin                'Read pin "ch", value put into "volts"
              mov       temp, ch               'Calculate where to put this value.
              and       temp, #%111            'We read ch0 as ch8, but it still needs to be put in the right spot.
              add       temp, #ins_sums        ' add the base offset of the location of ins_sums
              movd      :addvolts, temp
              nop                               'Must have at least one command in between, as it is a 2-stage pipeline
:addvolts     add       0-0, volts              'Add to volts measurement to the correct pin, stored in "ins_sums" array
              djnz      ch, #:loop              'Read another pin if needed.
ReadAllPins_ret ret                             'Return to where this section was called.

              
ReadPin       'Read the analog input pin "ch", set value in "volts"               
              mov       temp, ch
              and       temp, #%011
              mov       ctrlbits, temp          'Set up the ctrlbits, as jm_adc124s021 does. Basically configures this for 2 reads of the same pin, only the second is kept.
              shl       ctrlbits, #16
              or        ctrlbits, temp
              shl       ctrlbits, #11

              and       ch, #4   wz, nr         'Is this on the 1st ADC? If so, set z 
        if_z  andn      outa, cs1_mask          'If 1st ADC, pull low ADC 1 cs
        if_nz andn      outa, cs2_mask          'If 2nd ADC, pull low ADC 2 cs
                                                                                    
              mov       a, #32                  'Prepare to :loop 32 times.
              mov       volts, 0                'Clear volts reading for next measurement
              
:loop         'Read/write a bit
              andn      outa, clk_mask          'clock low
              rol       ctrlbits, #1     wc     'rotate ctrlbits left 1 position,                                                 
        if_nc andn      outa, mosi_mask         'set mosi to bit#0 of ctrlbits - which is in the carry flag
        if_c  or        outa, mosi_mask
        
              shl       volts, #1               'shift volts left 1 bit
              and       miso_mask, ina   wz,nr  'If miso is low,set z
        if_nz or        volts, #1               'if miso is high then 'adc or #1'
              or        outa, clk_mask          'set clock high

              nop                               'Match a minimum 30% duty cycle (This puts us at 32%)
                         
              djnz      a, #:loop
              
              or        outa, clear_mask        'Turn both cs pins high, to deslect both devices. Also turn on the clock pin.
              and       volts, v_mask           'Keep only the actual reading
ReadPin_ret   ret                               'Return to where this section was called.


volts0_loc    long  0
ins_sums      long  0,0,0,0,0,0,0,0
readcnt_max   long  2 'Reads 2^readcnt, max 2^6=64, before dividing.                
cs1_mask      long  0
cs2_mask      long  0
clk_mask      long  0
miso_mask     long  0
mosi_mask     long  0
dir_mask      long  0
clear_mask    long  0
ch            long  0
volts         long  0
v_mask        long  $0FFF
volts_sum     long  0
ctrlbits      long  0
pin_mask      long  0
a             long  0
b             long  0
temp          long  0


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