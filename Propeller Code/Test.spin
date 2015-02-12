{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  symbol
   
OBJ
  pst : "Parallax Serial Terminal"
  util : "Util"
  sd : "fsrw" 
  
PUB main  | in
  pst.start(115_200)
  repeat while \sd.mount_explicit(7,6,5,4) < 0
  sd.popen(@name,"w")
  sd.pputs(string("Test",13,10,"Test2"))
  sd.pclose
DAT
name    byte  "testwrite.txt",0
       