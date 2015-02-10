{AUTHOR: Mr Lucas Rezac}
{TITLE: SDcardTest}
{PURPOSE: To slap Eric in the face whenever he starts annoying people}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

       ' DO  = 7
        'CLK = 6
        'DI  = 5
        'CS  = 4

VAR
  long  stack[256]
  long pointer, lastpointer
  long buf[1]
  byte stop
  long index
  byte DO, CLK, DI, CS
  'long datfilename , lastfilename
   
OBJ
  sd : "fsrw"
  'nums : "Simple_Numbers"
  'str : "String"
 ' pst : "Parallax Serial Terminal"
  
PUB init(d0, clk1, di1, cs1,datpointer,savefilename) | insert_card
  DO := d0
  CLK := clk1
  DI := di1
  CS := cs1
  datfilename := savefilename
  
''sets this programs pointer to the given data pointer
  pointer := datpointer

''creates new cog
  return cognew(start,@stack)
PRI start
''sets the stop boolean to false (otherwise program will exit immediately)
  stop := false
                                ''calls the insert card function                   
  repeat while \sd.mount_explicit(DO,CLK,DI,CS) < 0 ''wait until card is inseted, using the abort catch            
''sets the last pointer for reasons obviously apparent to even the most confused banana
  lastpointer := 0
  doStuff
  
PRI doStuff 
  {'sd.popen(string("matches.csv"), "r")  ''appends to text file  
  'sd.pread(@buf,1)
  'add := buf[1]+1
  'sd.pclose
  'sd.popen(string("matches.csv"),"w")
  'sd.pputs(add)
  'sd.pclose
  'sd.popen(str.stringConcatenate(str.stringConcatenate(string("match"),nums.dec(add)),string(".csv")),"a")}
 'repeats until this object's stop function is called
  sd.popen(datfilename,"a")
  repeat while !stop
    {if datfilename <> lastfilename
      sd.pclose
      sd.popen(long[datfilename],"a")
    lastfilename := @datfilename     }
  ''if pointer != lastpointer
    
    if long[pointer] <> lastpointer
      sd.pputs(long[pointer]) ''writes data
    lastpointer := long[pointer]
PRI openFile
  repeat while long[datfilename]==0 'don't start writing files until the file name has been set
  sd.popen(datfilename,"a")   
PUB end ''stops program
  sd.pclose
  stop := true
PUB setFileName(filename)  ''sets the file name. Defaults to test.txt.
  datFileName := filename
DAT
datfilename byte "test.txt",0