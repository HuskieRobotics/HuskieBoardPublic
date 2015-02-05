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
''sets the global data pointer to the given pointer
  globaldatapointer := dataPointer
''for use in the double buffering system
  buffer := false
''creates a new cog cheeseburger
  cognew(main,@stack[256])
PUB main | x
''starts FullDuplexSerial2
  cereal.start(1,0,0,256_000, stack)
''loops infinitely
  repeat
  ''the command value
    cmd := cereal.rx
  ''command number 1 : Recieve and write data
    if cmd == 1
    ''length of string
      length := cereal.rx
    'tests the length, has to be less than 250
      if not(length > 250)
      'switches the data pointer to write to depending on the buffer value 0/1
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