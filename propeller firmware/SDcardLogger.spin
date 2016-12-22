{AUTHOR: Lucas Rezac}
{TITLE: SDcardTest}
{PURPOSE: Log strings received by RR uart connection.}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        
        LED_YELLOW = 17
VAR
  long  stack[512]
  long pointer, lastpointer
  long buf[1]
  long adcpointer
  long stopPointer
  byte stop
  long index
  byte DO, CLK, DI, CS
  long datfilename , lastfilename
  long timepointer
  byte currCogID
   
OBJ
  sd : "fsrw"     
  pst : "Parallax Serial Terminal"
  stringutils : "String"
  
PUB init(d0, clk1, di1, cs1,datpointer,savefilename,adcpointer_,stopPointer_,timepointer_) | insert_card
  DO := d0
  CLK := clk1
  DI := di1
  CS := cs1
  adcpointer := adcpointer_
  datfilename := savefilename
  stopPointer := stopPointer_
  timepointer := timepointer_
  stop := false  
  pst.startrxtx(-1,4,0,115_200) 'transmit on GPIO0
''sets this programs pointer to the given data pointer
  pointer := datpointer
  pst.str(string("SD card works!",13))
''creates new cog
  currCogID := cognew(start,@stack)
  return currCogID
PUB reinit
  pst.str(string("Resetting SD card logger!"))
  'stop
  stop := false
  long[datfilename] := 0
  cogstop(currCogID)  'does this end the current function if the current function is in the cog it's stopping?
  longfill(@stack,0,512) 'clears the stack. Just because.
  currCogID := cognew(start,@stack)
  return currCogID
PRI start  | loc
  'dira[LED_YELLOW]:=true'set yellow LED to output
''sets the stop boolean to false (otherwise program will exit immediately)
  stop := false
                                ''calls the insert card function                   
  repeat while \sd.mount_explicit(DO,CLK,DI,CS) < 0 ''wait until card is inseted, using the abort catch
    pst.str(string("Waiting for mount_explicit to return true!",13))
  pst.str(string("Mounted SD!",13))         
''sets the last pointer
  lastpointer := 0

  repeat while long[datfilename] == 0 and long[pointer] == 0 'don't continue until we know the name of the file, or we are starting to have data to log
    pst.str(string("Waiting for packet or file name",13))

  
  'setting current date:      
  sd.setdatedirect(long[timepointer])
  'don't worry if the date is uninitialized, since fsrw takes care of timestamps of 0.
  'date must be set BEFORE the file is opened, it will not update during the run

  
  'Don't forget that we are using FAT32, which means that our file name is 8.3 long (8 name, 3 extension chars)
  'Longer file names will be compressed. Also, FAT32 doesn't support lower-case letters in the filename, so those
  'are also automatically converted to caps. 
  repeat loc from datfilename to datfilename+strsize(datfilename)      'don't allow illegal characters!
    if not lookup(byte[loc]:"\","/",":","?","*","<",">","|",34) == 0   'double quote is 34
      byte[loc]:="_"
  sd.popen(datfilename,"a")       'append to the file, not worrying if it already exists.
 
    
  pst.str(string("Starting main loop!"))
  
  mainLoop
  
PRI mainLoop | x ,channel                                                                                   
 'repeats until this object's stop function is called

  
  repeat while !stop       
    pst.str(string("Pointer testing...........................",13))
    if long[pointer] <> lastpointer  'is there new data to write?
      if(stringutils.stringCompareCS(@pointer, string("stop"))==0) 'edit: used string util method instead of ==.'can i do this? Or is string testing done a different way? THIS WILL NOT WORK!!!!!
        reinit
        return
      lastpointer := long[pointer]
      sd.pputs(long[pointer]) ''writes data
      repeat channel from 0 to 7
        sd.pputc(",")
        sdDec(word[adcpointer+channel])'word[pointer+channel] )
        
      sd.pputs(string(13,10))
      pst.str(string("Wrote data :"))
      pst.str(long[pointer])
      pst.char(13)
      sd.pflush
      'dira[LED_YELLOW]:=true'set yellow LED to on, signifying one line was written        
       'set the last pointer
    
  'sd.pclose   
PUB end ''stops program
  sd.pclose
  stop := true
  pst.str(string("Stopped!"))
PUB setFileName(filename)  ''sets the file name. Defaults to test.txt.
  datFileName := filename


PUB sdDec(value) | i, x
{{Send value as decimal characters.
  Parameter:
    value - byte, word, or long value to send as decimal characters.}}

  x := value == NEGX                                                            'Check for max negative
  if value < 0
    value := ||(value+x)                                                        'If negative, make positive; adjust for max negative
    sd.pputc("-")                                                                   'and output sign

  i := 1_000_000_000                                                            'Initialize divisor

  repeat 10                                                                     'Loop for 10 digits
    if value => i                                                               
      sd.pputc(value / i + "0" + x*(i == 1))                                        'If non-zero digit, output digit; adjust for max negative
      value //= i                                                               'and digit from value
      result~~                                                                  'flag non-zero found
    elseif result or i == 1
      sd.pputc("0")                                                                 'If zero digit (or only digit) output it
    i /= 10                                                                     'Update divisor

DAT                              
testb byte "match.csv",0  