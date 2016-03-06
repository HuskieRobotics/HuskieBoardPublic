{RoboRIO Serial proof of concept}
                                
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000  
   
OBJ                            
  fds1     : "FullDuplexSerial"
  fds2     : "FullDuplexSerial"

VAR
   long cog1[1000]
   long cog2[1000]
   
PUB Begin
  cognew(TerminalToRobo, @cog1)
  cognew(RoboToTerminal, @cog2)
  
  
PUB RoboToTerminal
  fds1.start(11, 30, 0, 115200) 
  repeat
    fds1.tx(fds1.rx)
PUB TerminalToRobo
  fds2.start(31, 10, 0, 115200)
  repeat
    fds2.tx(fds2.rx)
                                   