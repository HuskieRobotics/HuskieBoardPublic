CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

                       
PUB main

  dira[24 .. 27]~~

  dira[6 .. 9]~
  
  repeat
    outa[24 .. 27] := !ina[6 .. 9]