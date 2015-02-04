{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  stack
     
OBJ
  io       : "FullDuplexSerial2"
  term     : "Parallax Serial Terminal"
  
PUB start                 
  cognew(@stack, com)
  cognew(@stack, recv)
  io.start(1,0,0,256000, stack)
  term.start(115200)
{PUB recv(origin) | temp
PUB send(destination) | temp}   
DAT
name    byte  "string_data",0        
        