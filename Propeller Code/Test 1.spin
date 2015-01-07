{Test 1}
CON      
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000  

VAR
  long  symbol
  word  s1
  byte  s2
   
OBJ                                      
  serial        : "FullDuplexSerial"
  
PUB main
  serial.Start( 31,30,%0000, 115200)
  repeat
    sayHi
    waitcnt(cnt+clkfreq)
    
       

PUB sayHi
  serial.Str(@hi)

DAT
name    byte  "string_data"
hi      byte  "Hi!",13,0  
        