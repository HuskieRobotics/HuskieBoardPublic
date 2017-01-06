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
      pst.bin(readArray(x),32)
      pst.str(string(", "))
    pst.bin(readArray(7),32)
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
  miso_mask := |< dipin
  mosi_mask := |< dopin
  dir_mask := cs1_mask | cs2_mask | clk_mask | mosi_mask
  clear_mask := cs1_mask | cs2_mask | clk_mask
  volts0_loc := @data
  cog := cognew(@ADC, 0)

pub readArray(channel)         'Read from a pre-filled array (using readToArray).
  return data[channel]

DAT
              org       0
ADC           mov       outa, clear_mask        'Turn both cs pins high, to deslect both devices. Also turn on the clock pin.
              mov       dira, dir_mask       
              
Loop          call      #ReadAllPins         'TODO: Do the averageing math here.
              jmp       Loop

ReadAllPins   mov       ch, #8
:loop         call      #ReadPin                'Read pin "ch", value put into "volts"
              mov       temp, ch                'Calculate where to put this value.
              and       temp, #%111             'We read ch0 as ch8, but it still needs to be put in the right spot.
              shl       temp, #2                ' multiply by 4 to get long-based address
              add       temp, volts0_loc
              wrlong    volts, temp       
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
              mov       volts, 0               'Clear volts reading for next measurement
:loop         'Read/write a bit
              andn      outa, clk_mask          'clock low
              rol       ctrlbits, #1     wc     'rotate ctrlbits left 1 position,                                                 
        if_nc andn      outa, mosi_mask         'set mosi to bit#0 of ctrlbits - which is in the carry flag
        if_c  or        outa, mosi_mask
        
              shl       volts, #1               'shift volts left 1 bit
              and       miso_mask, ina   wz,nr  'If miso is low,set z
        if_nz or        volts, #1               'if miso is high then 'adc or #1'
              or        outa, clk_mask          'set clock high           
              djnz      a, #:loop
              
              or        outa, clear_mask        'Turn both cs pins high, to deslect both devices. Also turn on the clock pin.
              'and       volts, v_mask           'Keep only the actual reading
              mov volts, clear_mask
ReadPin_ret   ret                               'Return to where this section was called.


volts0_loc    long  0
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
ctrlbits      long  0
pin_mask      long  0
a             long  0
temp          long  0