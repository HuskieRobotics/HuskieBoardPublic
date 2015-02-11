{AUTHOR: Bennett Johnson}
{OBJECT: API}
{REVISION: v0}
{REVISED BY: }
{PURPOSE: This object is the API for the Rob0RIO Expansion Board developed by Team 3061, subgroup led by Brandon John.}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        log = false
        
VAR
  long  cmd  
  long  stack[250]
OBJ
  sd      : "fsrw"
  io      : "rxSerialHSLP_11"
  pst     : "Parallax Serial Terminal"
  
PUB UART(Baud, input, output, mode)
  if input == output
    pst.str(string("Input pin cannot be the same as the output."))
  io.start(input, mode, baud)
  pst.start(baud)
  cmd := io.rx
  repeat 'Will check for data.
    if io.rxCheck
      cmd := io.rx
      if cmd == pst.char(10)         ' End of packet transmission
        if temp[0] == string("0x01")   ' SD Log
          log := true
        stack += temp
      if temp := string("~")         ' First Transmission set
        temp := cmd+string(",")
      else                           ' Add Bytes to transmission 
        temp += cmd+string(",") 
          
                 
      
                  
     
PUB SDlog(filename, pointer, baud, input, output, mode)
  sd.setdate(2015, 2, 10, 0, 0, 0)
  sd.popen(filename, "a")

  if log
    sd. 
  
DAT        
temp    byte  "~",10        