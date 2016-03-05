{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  null
  long  data 
OBJ
  lcd   :       "Serial_Lcd"
  util  :       "Util"
  str   :       "String"  
PUB main
  lcd.init(18, 19_400, 4)
  lcd.putc(lcd#LCD_BL_ON)
  lcd.cls            
  lcd.str(string("hi"))
  