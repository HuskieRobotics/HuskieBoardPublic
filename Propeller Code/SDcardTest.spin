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
   
OBJ
  sd : "fsrw"
  'nums : "Simple_Numbers"
  'str : "String"
 ' pst : "Parallax Serial Terminal"
  
PUB init(d0, clk1, di1, cs1,datpointer) | insert_card
  DO := d0
  CLK := clk1
  DI := di1
  CS := cs1
''waits two (2) seconds, in theory
  'waitcnt(clkfreq*2 + cnt)
''starts the Terminal
  'pst.start(115_200)
''tells the user the program has started
  'pst.str(string("Program start!",13))
''sets the stop boolean to false (otherwise program will exit immediately)
  stop := false
''calls the insert card function
  insert_card := sd.mount_explicit(DO,CLK,DI,CS)
''if the card inserted correctly, display Mounted. Otherwise, program will exit.
 ' pst.str(string("Mounted",13))
  if insert_card < 0 ''if sd card not connected...  (this doesn't really work)
   ' pst.str(string("Micro SD card not found!",13))
    return  -1  ''ends program
''sets this programs pointer to the given data pointer
  pointer := @datpointer
''sets the last pointer for reasons obviously apparent to even the most confused banana
  lastpointer := 0
  {sd.popen(string("test.txt"),"w")
  sd.pputs(0)
  sd.pclose
  sd.popen(string("test.txt"),"a")
  sd.pputs(@fdata)
  sd.pclose
  pst.str(string("Program done!"))
  return -1 }
''creates new cog
  return cognew(doStuff,stack[100])
  ''pst.str(string("Micro SD card successfully connected!",13))      
PRI doStuff 
  {'sd.popen(string("matches.csv"), "r")  ''appends to text file  
  'sd.pread(@buf,1)
  'add := buf[1]+1
  'sd.pclose
  'sd.popen(string("matches.csv"),"w")
  'sd.pputs(add)
  'sd.pclose
  'sd.popen(str.stringConcatenate(str.stringConcatenate(string("match"),nums.dec(add)),string(".csv")),"a")}
''opens the log file
  sd.popen(@datfilename,"a")
''repeats until this object's stop function is called
  repeat while !stop
  ''if pointer != lastpointer
    if pointer <> lastpointer
      sd.pputs(@pointer) ''writes data
    lastpointer := pointer        
PUB end ''stops program
  sd.pclose
  stop := true
PUB setFileName(filename)  ''sets the file name. Defaults to test.txt.
  datFileName := @filename
DAT
datfilename byte "test.txt",0