{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  symbol
   
OBJ
  pst : "Parallax Serial Terminal"
  
PUB main
  pst.start(115_200)
  pst.print(string("Start!",13))
  pst.print(string("To move on to next pin, press enter",13))
  outputPinAndWait(1)

PRI outputPinAndWait(pin)
  pst.str(string("Outputting power on pin "))
  pst.dec(pin)
  pst.char(13)
  outa[pin] := 1
  pst.charIn

DAT
name    byte  "string_data",0        
        