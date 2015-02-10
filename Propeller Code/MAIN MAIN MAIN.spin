{AUTHOR: Lucas Rezac}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  pointerToPointerThing
  long  datFileName[32] 'name can't be longer than 128 bytes
  
   
OBJ
  RRConn : "LOG STRING - Lucas Rezac"
  sd   : "SDcardTest"
  
PUB main
  longfill(@datFileName,0,32)
  datFileName[0] := $54657374 'Test
  datFileName[1] := $312e6373 '1.cs
  datFileName[2] := $76000000               
  RRConn.init(1,0,0,460_800,@pointerToPointerThing,@datFileName) 
  sd.init(7,6,5,4,@pointerToPointerThing,@datFileName)
  
              
        