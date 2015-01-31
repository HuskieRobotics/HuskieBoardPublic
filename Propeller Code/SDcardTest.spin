{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        DO = 7
        CLK = 6
        DI = 5
        CS = 4

VAR
  long  stack[256]
  long pointer, lastpointer
  long buf[1]
  byte stop
   
OBJ
  sd : "fsrw"
  nums : "Simple_Numbers"
  str : "String"
  ''pst : "Parallax Serial Terminal"
  
PUB init(datpointer) | insert_card 
  ''waitcnt(clkfreq*6 + cnt)
  ''pst.start(115_200)
  ''pst.str(string("Program start!",13))
  stop := false
  insert_card := sd.mount_explicit(DO,CLK,DI,CS)
  pst.dec(insert_card)
  if insert_card < 0 ''if sd card not connected...
    ''pst.str(string("Micro SD card not found!",13))
    return  -1  ''ends program
  pointer := @datpointer
  lastpointer := 0
  
  return cognew(do,stack[100])
  ''pst.str(string("Micro SD card successfully connected!",13))      
PRI do   | add
  'sd.popen(string("matches.csv"), "r")  ''appends to text file  
  'sd.pread(@buf,1)
  'add := buf[1]+1
  'sd.pclose
  'sd.popen(string("matches.csv"),"w")
  'sd.pputs(add)
  'sd.pclose
  'sd.popen(str.stringConcatenate(str.stringConcatenate(string("match"),nums.dec(add)),string(".csv")),"a")
  sd.popen(@datfilename,"a")
  repeat while !stop
    if pointer <> lastpointer
      sd.pputs(@pointer) ''writes data
    lastpointer := pointer        
PUB end
  sd.pclose
  stop := true
PUB setFileName(file)
  datFileName := @file
DAT
datfilename long "null_pointer",0        