CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        
        LCD_Pin    = 15
        LCD_Baud   = 19_200

        ADC_CS     = 23
        ADC_DO     = 22
        ADC_DI     = 21
        ADC_CLK    = 20
        
OBJ
  lcd      : "Serial_LCD"
  str      : "String"
  adc      : "ADC driver"
PUB public_method_name | adcInput
  lcd.init(LCD_PIN,LCD_BAUD,4)
  lcd.backlight(true)   
  lcd.cls
                                                   
  adc.start2pin(ADC_DI,ADC_DO,ADC_CLK,ADC_CS,$00FF) 'can only use one of these start methods!
  'adc.start(ADC_DI,ADC_CLK,ADC_CS,$00FF) 'must short together pins 21&22

  repeat
    lcd.gotoxy(0,0)
    repeat adcInput from 0 to 7
      lcd.str(str.integerToHexadecimal(adc.in(adcInput),4))  
      lcd.putc(" ")
    lcd.str(str.integerToHexadecimal(cnt,8))