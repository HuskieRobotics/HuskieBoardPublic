CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        
        LCD_Pin    = 18
        LCD_Baud   = 19_200
                         
        adc_CS1     = 20        
        adc_CS2     = 19        
        adc_DO      = 21        
        adc_DI      = 23       
        adc_CLK     = 22       
        
OBJ
  lcd      : "Serial_LCD"
  str      : "String"
  adc      : "jm_adc124s021"
PUB public_method_name | adcInput
  lcd.init(LCD_PIN,LCD_BAUD,4)
  lcd.backlight(true)   
  lcd.cls
                                                   
  adc.start(adc_CS1,adc_CS2,adc_CLK,adc_DI,adc_DO)                            

  repeat
    lcd.gotoxy(0,0)
    repeat adcInput from 0 to 7
      lcd.str(str.integerToHexadecimal(adc.read(adcInput),4))  
      lcd.putc(" ")
    waitcnt(clkfreq/100+cnt)
    'lcd.str(str.integerToHexadecimal(cnt,8))