{RoboRIO Serial proof of concept}
                                
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000  
   
OBJ                            
  fds1     : "FASTSERIAL-080927"
  fds2     : "FASTSERIAL-080927"

VAR
   long cog1[1000]
   long cog2[1000] 
   
PUB Begin
  cognew(TerminalToRobo, @cog1)
  cognew(RoboToTerminal, @cog2)
  'cognew(RoboToRobo, @cog1)
  'cognew(TerminalToTerminal, @cog2)
  
  
PUB RoboToTerminal
  fds1.start(11, 30, 0, 230400) 
  repeat
    'fds1.tx(fds1.rx)
    fds1.str(fds1.rxstr)
PUB TerminalToRobo
  fds2.start(31, 10, 0, 230400)
  repeat
    fds2.tx(fds2.rx)
                        
PUB RoboToRobo
  fds2.start(11, 10, 0, 230400) 
  repeat
    fds2.tx(fds2.rx)  
PUB TerminalToTerminal
  fds1.start(31, 30, 0, 230400) 
  repeat
    fds1.tx(fds1.rx)                                 