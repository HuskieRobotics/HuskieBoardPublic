{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  pointer
   
OBJ
  pst : "Parallax Serial Terminal"
  adc : "ADC driver"
  
PUB main  | channel
  pst.start(115_200)
  waitcnt(cnt+clkfreq)
  pst.dec(adc.start(17,19,18,$00FF))
  pst.char(13)
  pointer := adc.pointer
  pst.hex(pointer,8)
  repeat
    repeat channel from 0 to 15
      pst.dec(adc.in(channel))'word[pointer+channel] )
      pst.char(" ")           
    pst.char(13)
    waitcnt(cnt+clkfreq/20)
    
DAT
name    byte  "testwrite.txt",0
       