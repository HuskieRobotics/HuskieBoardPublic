{AUTHOR: Mr Lucas Rezac}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        DO  = 7
        CLK = 6
        DI  = 5
        CS  = 4

VAR
  long  stack[256]
  long pointer, lastpointer
  long buf[1]
  byte stop
  long index
   
OBJ
  sd : "fsrw"
  'nums : "Simple_Numbers"
  'str : "String"
  pst : "Parallax Serial Terminal"
  
PUB init(datpointer) | insert_card 
  'waitcnt(clkfreq*4 + cnt)
  pst.start(115_200)
  pst.str(string("Program start!",13))
  stop := false
  insert_card := sd.mount_explicit(DO,CLK,DI,CS)
  pst.str(string("Mounted",13))
  if insert_card < 0 ''if sd card not connected...
    pst.str(string("Micro SD card not found!",13))
    return  -1  ''ends program
  pointer := @datpointer 
  lastpointer := 0
  {sd.popen(string("test.txt"),"w")
  sd.pputs(0)
  sd.pclose
  sd.popen(string("test.txt"),"a")
  sd.pputs(@fdata)
  sd.pclose
  pst.str(string("Program done!"))
  return -1 }
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
  sd.popen(@datfilename,"a")
  repeat while !stop
    if pointer <> lastpointer
      sd.pputs(@pointer) ''writes data
    lastpointer := pointer        
PUB end
  sd.pclose
  stop := true
PUB setFileName(filename)
  datFileName := @filename
DAT
datfilename byte "test.txt",0
fdata byte "FILE WRITE SUCCESS",13,10,"MULTIPLE LINES",0