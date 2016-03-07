CON                                                                                                                                         
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz           
        _xinfreq = 5_000_000

VAR
  byte mode

OBJ
  neo_main : "LED Main"

  
PUB main
  neo_main.start(5, 14, 60)
                                            
  repeat
  {
    neo_main.change_mode(0)
    waitcnt(cnt + clkfreq / 2)
    neo_main.change_mode(1)    
    waitcnt(cnt + clkfreq / 2)
    neo_main.change_mode(2)
    waitcnt(cnt + clkfreq / 2)
    neo_main.change_mode(3)
    waitcnt(cnt + clkfreq / 2)
    neo_main.change_mode(4)
    waitcnt(cnt + clkfreq / 2)
    neo_main.change_mode(5)
    waitcnt(cnt + clkfreq / 2)
    }  