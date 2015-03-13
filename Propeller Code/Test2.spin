{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  symbol
   
OBJ
  pst : "Parallax Serial Terminal"
  
PUB main  | variable , input
  waitcnt(cnt+clkfreq*2)
  pst.start(115_200)
  repeat variable from 0 to 5205
    pst.str(string("ERIC ZAABAAAAAAA SUX "))

  
DAT
name    byte  "string_data",0        
        