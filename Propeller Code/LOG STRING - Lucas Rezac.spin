{AUTHOR: Lucas Rezac}
{TITLE: LOG STRING}
{PURPOSE: This object has no purpose. Never use it. In fact, you should immediately delete this file, empty the garbage bin, and
                  restart your computer. Do it. Now. Also, it'd be nice if you could forget about ever reading this text, or better yet,
                  that you ever heard of this file. That would be great. AND as an extra incentive to do the above, let me just say
                  that I know where you live, and your mom's phone number, and your Social Security Card number. Don't make me use
                  that information, because I don't want to. But I will, if I have to.}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  stack[256]
  long  cmd, length, globaldatapointer
  byte data1[256], data2[256]
  byte buffer
  byte cheeseburger
OBJ
  cereal    : "FullDuplexSerial2"
   
PUB init(dataPointer)
  globaldatapointer := dataPointer
  buffer := false
  cognew(main,@stack[256])
PUB main | x
  cereal.start(1,0,0,256_000, stack)
  repeat
    cmd := cereal.rx
    if cmd == 1
      length := cereal.rx
      if not(length > 250)
        if buffer
          repeat x from 0 to length
           data1[x] := cereal.rx
          long[globaldatapointer] := @data1
          buffer := false
        else
          repeat x from 0 to length
            data2[x] := cereal.rx
          long[globaldatapointer] := @data2
          buffer := true
    
      
PUB setCheeseburger(newCheeseburger)
  cheeseburger := @newCheeseburger
  return -1

DAT
secret_string byte "THIS STRING IS NEVER USED IN THIS PROGRAM, BUT DO NOT DELETE IT. DOING SO WILL CRASH YOUR COMPUTER.",32766,0
 
PRI iHateSpin
  agree(true)
PRI agree(agreed) | java, KING
  java := 9001
  KING := java
  if not agreed
    return -1
  elseif java == KING
    iHateSpin      