{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long null
   
OBJ
 lcd : "Serial_Lcd"
  
PUB main
  lcd.init(14,19_200,2)
  lcd.cursor(0)
  lcd.cls
  lcd.str(string("THIS IS A TEST"))   
        