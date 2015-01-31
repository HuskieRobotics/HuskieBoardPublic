{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  stack
  long  buffer[250]
  long  pointer[4] 
OBJ
  fds      : "FullDuplexSerial"
  term     : "Parallax Serial Terminal"
  
PUB start
  coginit(1, @stack, com)
  fds.start(0,1,0,115200)
  term.start(115200)
PUB com | count
  count := 0
  repeat
    pointer := fds.Rx
    if fds.Rx
      count += 4 
      abort
  buffer += pointer
  term.Str(buffer)
    
DAT
name    byte  "string_data",0        
        