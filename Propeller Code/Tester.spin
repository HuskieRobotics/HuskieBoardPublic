{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  symbol
   
OBJ
  pst : "Parallax Serial Terminal"
  
PUB main | pin
  pst.start(115_200)
  pst.str(string("Start!",13))
  pst.str(string("To move on to next pin, press enter (i think)",13))
  pin := 0
  repeat pin from 0 to 29
    outputPinAndWait(pin)
  pst.str(string("Now we will do the inputs. To stop the loop, press any key (i think)",13))
  repeat while pst.rxcheck == -1
    inputPin
  

PRI outputPinAndWait(pin)
  pst.str(string("Outputting power on pin "))
  pst.dec(pin)
  pst.char(13)
  dira[pin] := 1
  outa[pin] := 1
  pst.charIn
  outa[pin] := 0
  dira[pin] := 0

PRI inputPin
  dira := 0
  
  pst.bin(ina,32)
DAT
name    byte  "string_data",0        
        