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
  long  stack[512]
  long  cmd, length, globaldatapointer
  byte data1[256], data2[256]
  long  testabfhg[128]
  byte buffer
  byte cheeseburger
  byte rx, tx, mode, baud
  byte checksum
OBJ
  cereal    : "FullDuplexSerial2"
  pst : "Parallax Serial Terminal"

PUB testa
  init(1,0,0,115_200, @testabfhg)
PUB init(rx1, tx1, mode1, baudrate,dataPointer)
''sets the global data pointer to the given pointer
  globaldatapointer := dataPointer
  rx := rx1
  tx := tx1
  mode := mode1
  baud := baudrate
''for use in the double buffering system
  buffer := false
''creates a new cog cheeseburger
  cognew(main,@stack[0])
PUB main | x
  dira[15] := true
  pst.start(115_200)
  pst.str(string("Running",13))
  ''outa[15] := true
''starts FullDuplexSerial2
  cereal.start(rx,tx,mode,baud, @stack)
''loops infinitely
  repeat
    repeat x from 0 to 7
        pst.hex(cereal.rx,2)
    pst.char(13)
  repeat
    pst.str(string("  Outer loop",13))
  ''the command value
    cmd := cereal.rx
    pst.hex(cmd,2)
  ''command number 1 : Recieve and write data
    if cmd == 1
      pst.str(string("cmd == 1",13))
    ''length of string
      length := cereal.rx
    'tests the length, has to be less than 250
      if not(length > 250)
        pst.str(string("length !> 250",13))
      'switches the data pointer to write to depending on the buffer value 0/1
        if buffer
          repeat x from 0 to length-3
            data1[x] := cereal.rx
            pst.hex(data1[x],8)
            checksum+=data1[x]
          if checksum == cereal.rx
            long[globaldatapointer] := @data1
            buffer := false
          else
            outa[15]:=true
        else
          repeat x from 0 to length-3
            data2[x] := cereal.rx
            pst.hex(data2[x],8)
            checksum+=data2[x]
          if checksum == cereal.rx ''if checksum is bad, doesn't save the packet
            long[globaldatapointer] := @data2
            buffer := true
          else
            outa[15]:=true
        pst.str(string("Data:",13))
    
      
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