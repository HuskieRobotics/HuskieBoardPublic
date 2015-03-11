{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000


        NUMCHANNELS = 5
        
        BRIGHTNESS = 80
        
VAR
  long RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, BLACK, WHITE
  long HUSKIEORANGE, HUSKIEBLUE 
  byte ch
  byte PIN,LENGTH
  byte strinpt
  long pointer
  long neopixels[64]
  long colors[6], colors2[12]
  long stack[512]
  byte channels[NUMCHANNELS]
  byte batterylevel 

  ''BOOLEANS
  byte isFlashingOnOff
  byte isFlashingGreen
  byte isEnabled
  byte stop
  byte flash
  byte buttonPressed
  byte potentiometer
OBJ
  neo : "Neopixel Driver"
  pst : "Parallax Serial Terminal"
  str : "String"
  rand: "RealRandom"
PUB init(pin_,length_,pointer_,buttonPtr,potentPtr)
  PIN := pin_
  'LENGTH := length_
  LENGTH := 64
  pointer := pointer_
  batteryLevel := 100
  buttonPressed := buttonPtr
  potentiometer := potentPtr
  isEnabled := false
  isFlashingOnOff := false
  isFlashingGreen := false
  stop := false
  flash := false
  cognew(main,@stack[0])
PUB main   | c, x, in
  'neo.start(PIN,LENGTH)
  neo.start(20,64)
  pst.start(115_200)
  rand.start
 'pst.str(string("Started!",13))
  setColors 
  neo.fill(0,64,RED)
  'pst.str(string("Done setting colors!",13)) 
  'waitcnt(cnt+clkfreq*2)
  'stripes
  repeat while !stop
    if isEnabled
      if flash
        flash := false
      if isFlashingOnOff
        neo.fill(0,64,BLACK)
      elseif isFlashingGreen
        neo.fill(0,64,GREEN)
      else
        'do stuff here
        neo.fill(0,10,HUSKIEORANGE)
        neo.fill(0,batteryLevel/10,HUSKIEBLUE)

       
    else
      repeat while !isEnabled
       'pst.str(string("!isEnabled"))
        'if !isEnabled
          'shade
        if !isEnabled
          gradient
        if !isEnabled
          bounce
        if !isEnabled
          center
        if !isEnabled
          rainbow
        if !isEnabled
          random
        if !isEnabled
          stripes
    
  {
  METHOD LIST:

  shade
  gradient
  bounce
  center
  rainbow
  stripes
  random
  }
PUB activemode
  isEnabled := true
PUB setBatteryLevel(level)
  batterylevel :=  level
PUB passiveMode
  isEnabled := false
PUB set20secsLeft
  isFlashingOnOff := true
PUB halt
  stop := true
PRI shade  | c,count
  c := 0
  repeat count from 0 to 20
    neo.fill(0,64,colors2[c])
    c++
    if c > 11
      c := 0
    waitcnt(cnt+clkfreq/2)
    if buttonPressed
      return
    
PRI gradient | r,g,b,freq , count
  freq := potentiometer/50
  'repeat count from 0 to 1
    r := 255
    g := 0
    b := 0
    repeat g from 0 to 255
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
    repeat r from 255 to 0
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
    repeat b from 0 to 255
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
    repeat g from 255 to 0
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
       return
    repeat r from 0 to 255
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
    repeat b from 255 to 0
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
PRI stripes | offset, x, i, count
  offset := 0
  repeat count from 0 to 100
    repeat x from 0+offset to 64+offset
      repeat i from 0 to 3
        neo.set(limit(x+i),HUSKIEORANGE)
      repeat i from 4 to 7
        neo.set(limit(x+i),HUSKIEBLUE)
      'neo.fill(limit(x),limit(x+3),ORANGE)
      if buttonPressed
        return
      'neo.fill(limit(x+4),limit(x+7),BLUE)
      x+=7
    offset++
    if offset > 64
      offset := 0
    waitcnt(cnt+clkfreq/(potentiometer/10))
PRI limit(i) : val
  if i < 0
    i := 64-i
    return i
  elseif i > 64
    i := i-64
    return i
  return i  
PRI center | c, x
  c := 0
  repeat
    repeat x from 0 to 32
      neo.set(x,colors[c])
      neo.set(LENGTH-x, colors[c])
      if buttonPressed
        return
      waitcnt(cnt+clkfreq/(potentiometer/50))
    c++
    if c == 6
      c := 0
PRI bounce | c,x , count
  c := 0
  repeat count from 0 to 2
    repeat x from 0 to 64
      neo.set(x,colors[c])
      neo.set(LENGTH-x, colors[c-2])
      if buttonPressed
        return
      waitcnt(cnt+clkfreq/(potentiometer/50))
    c++
    if c == 6
      c := 0
PRI rainbow | x, i , count
  channels[0] := 64
  repeat x from 1 to NUMCHANNELS
    channels[x] := channels[x-1]-12
  repeat count from 0 to 40
    repeat i from 0 to NUMCHANNELS
      ch := channels[i]
      repeat x from ch to ch-11
        if testCh(x)  
          neo.set(x,colors[ch-x])
      channels[i] := ch+1
      if channels[i]-1 > LENGTH
        channels[i] := 0
    waitcnt(cnt+clkfreq/(potentiometer/10))
    if buttonPressed
      return
PRI random | x, count 
  repeat count from 0 to 10
    repeat x from 0 to 64
      neo.set(x,neo.colorx(rand.random*255,rand.random*255,rand.random*255,BRIGHTNESS))
    waitcnt(cnt+clkfreq/(potentiometer/10))
    if buttonPressed
      return
PRI testCh(channel)
  return (ch =< 64 and ch => 0)
PRI setColors | x , r, g, b, in
  RED := neo.colorx(255,0,0,BRIGHTNESS)
  ORANGE := neo.colorx(255,136,0,BRIGHTNESS)
  YELLOW :=  neo.colorx(255,255,0,BRIGHTNESS)
  GREEN := neo.colorx(0,255,0,BRIGHTNESS)
  BLUE := neo.colorx(0,0,255,BRIGHTNESS)
  PURPLE :=  neo.colorx(187,0,255,BRIGHTNESS)
  BLACK := neo.colorx(0,0,0,BRIGHTNESS)
  WHITE := neo.colorx(255,255,255,BRIGHTNESS)
  HUSKIEORANGE := neo.colorx(230,92,0,BRIGHTNESS)
  HUSKIEBLUE := neo.colorx(6,0,120,BRIGHTNESS)
  colors[0] := RED
  colors[1] := ORANGE
  colors[2] := YELLOW
  colors[3] := GREEN
  colors[4] := BLUE
  colors[5] := PURPLE

  colors2[0] := RED
  colors2[1] := neo.colorx(255,85,0,BRIGHTNESS)
  colors2[2] := neo.colorx(255,145,0,BRIGHTNESS)
  colors2[3] := neo.colorx(255,204,0,BRIGHTNESS)
  colors2[4] := neo.colorx(217,255,0,BRIGHTNESS)
  colors2[5] := neo.colorx(140,255,0,BRIGHTNESS)
  colors2[6] := neo.colorx(0,255,17,BRIGHTNESS)
  colors2[7] := neo.colorx(0,255,34,BRIGHTNESS)
  colors2[8] := neo.colorx(0,255,255,BRIGHTNESS)
  colors2[9] := neo.colorx(0,4,255,BRIGHTNESS)
  colors2[10]:= neo.colorx(98,0,255,BRIGHTNESS)
  colors2[11]:= neo.colorx(255,0,221,BRIGHTNESS)
 
DAT
name    byte  "string_data",0        
        