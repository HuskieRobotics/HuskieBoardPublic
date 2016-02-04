{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
  

VAR
  long null
  long batVolt
  byte A, Af, B, C, Cf, D, Df, E, F, Ff, G, Gf
   
OBJ
 lcd : "Serial_Lcd"
 util : "Util"
 str : "String"
PUB temp
  batVolt := 100
  A := 220
  Af := 221
  B := 222
  C := 223
  Cf := 224
  D := 225
  Df := 226
  E := 227
  F := 228
  Ff := 229
  G := 230
  Gf := 231
  
  init(15,19_200,4, @batVolt)
PUB init(pin_,baud_,numLines_,batteryVoltagePtr)
  lcd.init(pin_,baud_,numLines_)
  batVolt := batteryVoltagePtr
  main
PUB main  | strng   ,note
  lcd.init(15,19_200,4)
  lcd.putc(lcd#LCD_BL_ON)
  lcd.cursor(0)
  lcd.cls
  lcd.str(string("Hello? Is anybody   there?"))
  util.wait(5)
  lcd.cls
  lcd.str(string("I don't hate you."))      
  
  'GDGDCDCAfB
  {
  lcd.putc(217)
  lcd.putc(211)
  lcd.putc(G)
  lcd.putc(D)
  lcd.putc(G)
  lcd.putc(D)
  lcd.putc(C)
  lcd.putc(D)
  lcd.putc(G)
  lcd.putc(G)
  lcd.putc(D)
  lcd.putc(213)
  lcd.putc(A)
  waitcnt(cnt+clkfreq/2)  '
  lcd.putc(A)
  waitcnt(cnt+clkfreq/2)
  lcd.putc(211)
  lcd.putc(A)
  lcd.putc(B)
  lcd.putc(C)
  lcd.putc(B)
  lcd.putc(G)
  lcd.putc(G)
  lcd.putc(D)
  lcd.putc(213)
  lcd.putc(G)
  lcd.putc(219)
  lcd.putc(G)
  lcd.putc(D)
  lcd.putc(G)
  lcd.putc(D)
  lcd.putc(C)
  lcd.putc(D)
  lcd.putc(G)
  lcd.putc(G)
  lcd.putc(D)
  lcd.putc(213)
  lcd.putc(A)
  waitcnt(cnt+clkfreq/2)  '
  lcd.putc(A)
  waitcnt(cnt+clkfreq/2)
  lcd.putc(211)
  lcd.putc(A)
  lcd.putc(B)
  lcd.putc(C)
  lcd.putc(B)
  lcd.putc(G)
  lcd.putc(G)
  lcd.putc(D)    }

  
 
    
        