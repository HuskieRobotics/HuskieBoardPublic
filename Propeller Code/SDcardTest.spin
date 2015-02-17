{AUTHOR: Lucas Rezac}
{TITLE: SDcardTest}
{PURPOSE: To slap Eric in the face whenever he starts annoying people and also get Lucas very frustrated.}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

       ' DO  = 7
        'CLK = 6
        'DI  = 5
        'CS  = 4

VAR
  long  stack[512]
  long pointer, lastpointer
  long buf[1]
  long adcpointer
  byte stop
  long index
  byte DO, CLK, DI, CS
  long datfilename , lastfilename
   
OBJ
  sd : "fsrw"
  'nums : "Simple_Numbers"
  'str : "String"
  pst : "Parallax Serial Terminal"
  
  
PUB init(d0, clk1, di1, cs1,datpointer,savefilename,adcpointer_) | insert_card
  DO := d0
  CLK := clk1
  DI := di1
  CS := cs1
  adcpointer := adcpointer_
  datfilename := savefilename
  pst.startrxtx(-1,16,0,115_200)
''sets this programs pointer to the given data pointer
  pointer := datpointer
  pst.str(string("SD card works!",13))
''creates new cog
  return cognew(start,@stack)
PRI start
''sets the stop boolean to false (otherwise program will exit immediately)
  stop := false
                                ''calls the insert card function                   
  repeat while \sd.mount_explicit(DO,CLK,DI,CS) < 0 ''wait until card is inseted, using the abort catch
    pst.str(string("Waiting for mount_explicit to return true!",13))
  pst.str(string("Mounted SD!",13))         
''sets the last pointer for reasons obviously apparent to even the most confused banana
  lastpointer := 0

  repeat while long[datfilename] == 0 and long[pointer] == 0 'don't continue until we know the name of the file, or we are starting to have data to log
    pst.str(string("Waiting for Bennet to become smart...",13))
     
  if long[datfilename] == 0 'has the filename still not been set?
    sd.popen(@testb,"w")    'just append to match.csv
    sd.pputs(String(13,10,"-=-=-=-=-=-=-=-=-=-=BEGIN NEW MATCH=-=-=-=-=-=-=-=-=-=-",13,10)) 'show that it is a new match
  else
    sd.popen(datfilename,"w")       'open a (probably) new file
    
  pst.str(string("Starting main loop!"))
  
  mainLoop
  
PRI mainLoop | x ,channel                                                                                   
 'repeats until this object's stop function is called

  
  repeat 'while !stop       
    pst.str(string("Pointer testing...........................",13))
    if long[pointer] <> lastpointer  'is there new data to write?
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
'datfilename byte "match.txt",0
testb byte "match.csv",0  