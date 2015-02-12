{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  symbol
   
OBJ
  pst : "Parallax Serial Terminal"
  util : "Util"
  
PUB main  | in
  pst.start(115_200)
  util.wait(3)
  pst.str(string("Program start!",13))
  pst.dec("h")
DAT
name    byte  "string_data",0
       