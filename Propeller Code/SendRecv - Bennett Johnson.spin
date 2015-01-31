{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  stack
  long  buffer[250]
  long  pointer[4] 
OBJ
  thing    : ""
  term     : "Parallax Serial Terminal"
  
PUB start
  coginit(1, @stack, com)
  coginit(2, @stack, recv)
  thing.start(1,0,0,256000)
  term.start(115200)
PUB recv | count
  
PUB com  
DAT
name    byte  "string_data",0        
        