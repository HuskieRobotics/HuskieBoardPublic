{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        LENGTH = 64
        PIN = 4

        NUMCHANNELS = 5

VAR
  long RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, BLACK, WHITE
  byte ch, ch2, ch3, ch4, ch5, ch6, ch7, x 
  byte channels[NUMCHANNELS]
  long colors[12]
OBJ
  neo  : "Neopixel Driver"
  util : "Util"
  
PUB main  | i
   
  neo.start(PIN,LENGTH)
  'neo.set(0,neo.color(255,0,0))
  setColors
  

  channels[0] := 64
  repeat x from 1 to NUMCHANNELS
    channels[x] := channels[x-1]-12
  repeat
    repeat i from 0 to NUMCHANNELS
      ch := channels[i]
      repeat x from ch to ch-11
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
  colors[1] := neo.color(255,85,0)
  colors[2] := neo.color(255,145,0)
  colors[3] := neo.color(255,204,0)
  colors[4] := neo.color(217,255,0)
  colors[5] := neo.color(140,255,0)
  colors[6] := neo.color(0,255,17)
  colors[7] := neo.color(0,255,34)
  colors[8] := neo.color(0,255,255)
  'colors[9] := neo.color(0,157,255)
  colors[9] := neo.color(0,4,255)
  colors[10]:= neo.color(98,0,255)
  colors[11]:= neo.color(255,0,221)
  'colors[12] := neo.color(187,0,255)
  'colors[13] := neo.color(255,0,238)
  'colors[14] := neo.color(255,0,119)
  'colors[15] := neo.color(255,0,17)
  
DAT
name    byte  "string_data",0        
        