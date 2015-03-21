{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000


        ADC_CS     = 23
        ADC_DI     = 22
        ADC_DO     = 21
        ADC_CLK    = 20

VAR
  long  symbol
  long  adcvalue
  long  lastvalue
   
OBJ
  adc : "ADC driver"
  pst : "Parallax Serial Terminal"
  
PUB main
  waitcnt(cnt+clkfreq*2)
  pst.start(115_200)
  adc.start(ADC_DI,ADC_CLK,ADC_CS,$00FF)
  adcvalue := adc.in(7)
  lastvalue := 0
  repeat while true
    adcvalue := adc.in(7)
    if adcvalue <> lastvalue
      pst.dec(adcvalue)
      pst.char(13)
      lastvalue := adcvalue      
        