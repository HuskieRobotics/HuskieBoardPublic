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
  long stackSerial[512]
  long  cmd, length, globaldatapointer
  byte data1[256], data2[256], dataPt[256]
  byte sdfilename
  byte  filedata[256]
  long  testabfhg[128]
  byte buffer
  byte cheeseburger
  byte rx, tx, mode
  long baud
  byte checksum
OBJ
  'cereal    : "FullDuplexSerial2"  THIS ONE DOES NOT WORK FOR OUR NEEDS!!!
  cereal : "rxSerialHSLP_11"
  pst : "Parallax Serial Terminal"
  util : "Util"
PUB start | in, x, errors
  {Use this only to test the baudrates.
  Set up the roboRIO code to send ASCII values of 0 to 9.
  It will recieve them, and check if they are the same ones
  using the below loop. If not, it will say so, and also display
  a total error count.}

  util.wait(3)
  pst.start(115_200)
  pst.str(string("Program start!",13))
  
  pst.str(string("Baudrates:",13,"1. 460_800",13,"2. 230_400",13,"3. 256_000",13,"4. 115_200",13))
  pst.str(string("Choose a baudrate from the menu (enter a number from 1 to 4): "))
  in := pst.decIn
  if in == 1
    baud := 460_800
  elseif in == 2
    baud := 230_400
  elseif in == 3
    baud := 256_000
  elseif in == 4
    baud := 115_200
  else
    pst.str(string("Error, that was not one of the options.",13))
    baud := 460_800 
  pst.str(string("Started program with baudrate "))
  pst.dec(baud)
  pst.char(13)
  util.wait(1)
  cereal.start(1,0,baud)

  errors := 0
  repeat
    repeat x from "0" to "9"
      in := cereal.rx
      pst.str(string("Recieved data: "))
      pst.dec(in)
      pst.str(string(", which is "))
      ifnot x == in
       ''pst.str(string("not "))
       ''else
        pst.str(string("not "))
        errors++
        x--
      pst.dec(x)   
      pst.str(string("  Errors: "))
      pst.dec(errors)
      pst.char(13) 
PUB init(rx_, tx_, mode_, baudrate,dataPointer,savefilename)
''sets the global data pointer to the given pointer
  globaldatapointer := dataPointer
  rx := rx_
  tx := tx_
  mode := mode_
  baud := baudrate
  sdfilename := @savefilename
''for use in the double buffering system
  buffer := false
''creates a new cog cheeseburger
  cognew(main,@stack[0])
PUB main | x, in, errors, y
  'starts the program, and waits 3 seconds for you to open up, clear, and re-enable the terminal
  dira[15] := true
  util.wait(3)
  pst.start(115_200)                  
  pst.str(string("Program start!",13))
  ''starts the serial object
  cereal.start(rx,tx,baud)
      
  'RECIEVING CODE
  repeat
    ''pst.str(string("  Outer loop",13))
  ' the command value
    cmd := cereal.rx
    ''pst.dec(cmd)
    
  ' command number 1 : Recieve and write data
    if cmd == 1
    
      pst.str(string("cmd == 1",13))
    ' length of string
      length := cereal.rx
      
    ' tests if the length is less than 250
      if length < 250

      ' switches the data pointer to write to depending on the buffer value (0/1)
        if buffer
          dataPt := @data1
        else
          dataPt := @data2
          
      ' reverses the buffer value
        buffer := !buffer
        pst.str(string("Length:" ))
        pst.dec(length)
        checksum := cmd+length
        'cereal.rx
      ' gets all the string data and stores
      ' it to either data1 or data2,
      ' depending on the buffer value
        pst.char(13)
        pst.str(string("Recieved:"))                                                                                                                          
        repeat x from 0 to length-3
          dataPt[x] := cereal.rx
          pst.hex(dataPt[x],2)
        ' updates the checksum value
          checksum+=dataPt[x]
        pst.char(13)  
      ' checks the sum against the given length
      ' if it is bad, then doesn't save the packet
        y := cereal.rx
        if true'checksum == y
          long[globaldatapointer] := @dataPt
          pst.str(string("Line written: "))
          pst.str(@globaldatapointer)
          'buffer := !buffer
          outa[15] := false
          pst.char(13)
          
        else 'if some error occured, turns an LED on pin 15 : ON
          pst.str(string("Bad checksum!",13))
          pst.str(string("Checksum should be "))
          pst.dec(checksum)
          pst.str(string(", found: "))
          pst.dec(y)
          pst.char(13)
          pst.str(string("Data: "))
          pst.str(@dataPt)
          pst.char(13)
          outa[15]:=true
        'longfill(@dataPt,0,64)
  ' command number 3 : Set SD save file name
    if cmd == 3
    
      pst.str(string("cmd == 3",13))
    ' length of string
      length := cereal.rx
      
    ' tests if the length is less than 250
      if length < 250
        
      ' gets all the string data and stores
      ' it to either data1 or data2,
      ' depending on the buffer value                                                                                                                          
        repeat x from 0 to length-3
        
          filedata[x] := cereal.rx
        ' 
        ' updates the checksum value
          checksum+=filedata[x]
          
      ' checks the sum against the given length
      ' if it is bad, then doesn't save the packet
        if checksum == cereal.rx
          long[sdfilename] := @filedata
          outa[15] := false
          
        else 'if some error occured, turns an LED on pin 15 : ON
          outa[15]:=true
        pst.str(string("File name changed to :"))
        pst.str(@filedata)
        pst.char(13)
        util.wait(1)
    
      
PUB setCheeseburger(newCheeseburger) 
  cheeseburger := @newCheeseburger
  return -1

DAT
secret_string byte "THIS STRING IS NEVER USED IN THIS PROGRAM, BUT DO NOT DELETE IT. DOING SO WILL CRASH YOUR COMPUTER.",32766,0
datfilename byte "Null",0 
PRI iHateSpin
  agree(true)
PRI agree(agreed) | java, KING
  java := 9001
  KING := java
  if not agreed
    return -1
  elseif java == KING
    iHateSpin      