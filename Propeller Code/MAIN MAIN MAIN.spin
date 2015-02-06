{AUTHOR: Lucas Rezac}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  idontcare
   
OBJ
  wood : "LOG STRING - Lucas Rezac"
  ace   : "SDcardTest"
  
PUB main
  wood.init(1,0,0,115200,@idontcare)
  'ace.init(7,6,5,4,@idontcare)

DAT
name    byte  "string_data",0        
        