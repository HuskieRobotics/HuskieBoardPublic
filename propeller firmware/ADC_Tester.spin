{
Author: Calvin Field

}


con
        _clkmode    = xtal1 + pll16x                                           'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq    = 5_000_000


        adc_CS1     = 20        
        adc_CS2     = 19        
        adc_DO      = 21        
        adc_DI      = 23       
        adc_CLK     = 22       

obj
  adc     : "jm_adc124s021"
  pst     : "Parallax Serial Terminal"


pub main
  pst.start(115200)
  adc.start(adc_CS1,adc_CS2,adc_CLK,adc_DI,adc_DO)  'New adc driver

  repeat
    adc.setArray

    pst.str(string("1st ADC long val: "))
    pst.dec(adc.read(0))
    pst.char(13)
    pst.str(string("2nd ADC long val: "))
    pst.dec(adc.read(1))
    pst.char(13)
    pst.str(string("3rd ADC long val: "))
    pst.dec(adc.read(2))
    pst.char(13)
    pst.str(string("4th ADC long val: "))
    pst.dec(adc.read(3))
    pst.char(13)
    pst.str(string("5th ADC long val: "))
    pst.dec(adc.read(4))
    pst.char(13)
    pst.str(string("6th ADC long val: "))
    pst.dec(adc.read(5))
    pst.char(13)
    pst.str(string("7th ADC long val: "))
    pst.dec(adc.read(6))
    pst.char(13)
    pst.str(string("8th ADC long val: "))
    pst.dec(adc.read(7))
    pst.char(13)
    pst.char(13)
    pst.char(13)
    pst.char(13)

    waitcnt(cnt+clkfreq/15)
  
  