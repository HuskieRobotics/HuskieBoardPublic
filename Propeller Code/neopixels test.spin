{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        LENGTH = 64
        PIN = 8

        NUMCHANNELS = 10

VAR
  long RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, BLACK, WHITE
  byte ch, ch2, ch3, ch4, ch5, ch6, ch7, x 
  byte channels[NUMCHANNELS]
  long colors[8]
OBJ
  neo  : "Neopixel Driver"
  util : "Util"
  
PUB main  | i
   
  neo.start(PIN,LENGTH)
  'neo.set(0,neo.color(255,0,0))
  setColors
  

  channels[0] := 64
  repeat x from 1 to NUMCHANNELS
    channels[x] := channels[x-1]-6
  repeat
    repeat i from 0 to NUMCHANNELS
      ch := channels[i]
      repeat x from ch to ch-5
        if testCh(x)  
          neo.set(x,colors[ch-x])
      channels[i] := ch+1
      if channels[i]-1 > LENGTH
        channels[i] := 0
    waitcnt(cnt+clkfreq/10)      
PRI testCh(channel)
  return (ch =< 64 and ch => 0)
PRI setColors
  RED := neo.color(255,0,0)
  ORANGE := neo.color(255,119,0)
  YELLOW :=  neo.color(255,255,0)
  GREEN := neo.color(0,255,0)
  BLUE := neo.color(0,0,255)
  PURPLE :=  neo.color(187,0,255)
  BLACK := neo.color(0,0,0)
  WHITE := neo.color(255,255,255)
  colors[0] := RED
  colors[1] := ORANGE
  colors[2] := YELLOW
  colors[3] := GREEN
  colors[4] := BLUE
  colors[5] := PURPLE
  colors[6] := BLACK
  colors[7] := WHITE
DAT
name    byte  "string_data",0        
        