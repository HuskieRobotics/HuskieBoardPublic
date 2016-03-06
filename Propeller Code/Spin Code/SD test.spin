{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
                      
        sd2 = 5' = CS
        sd3 = 3' = DI
        sd5 = 2' = CLK
        sd7 = 1' = DAT0 

        
        sd_d0       = 2         'SD Card DO
        sd_d1       = 0         'SD Card Data 1
        sd_d2       = 4         'SD Card Data 2      
        sd_d3       = 5         'SD Card CS
        sd_cmd      = 3         'SD Card CMD
        sd_clk      = 2         'SD Card Clock pin
VAR
  long  symbol
   
OBJ
  sd      : "fsrw"
  pst : "Parallax Serial Terminal"
  
PUB public_method_name
  pst.start(115200)    
  sd.setdate(2016, 3, 5, 0, 0, 0)
  DIRA[24..27] ~~
 ' waitcnt(cnt+clkfreq)
                            'DO, CLK, DI, CS 
  pst.dec(\sd.mount_explicit(sd_d0, sd_clk, sd_cmd, sd_d3) )
                                 
                
  waitcnt(cnt+clkfreq)
  sd.popen(@file1, "a")
  sd.pputs(@data1)
  sd.pputs(@data2)
  sd.pputs(@data3)  
  'waitcnt(cnt+clkfreq)
  sd.pclose
  'waitcnt(cnt+clkfreq)
DAT
file1    byte  "abcdcba.txt",0                                     
data1    byte  "abcdefghijklmnopqrstuvwxyz. ",13,10,0
data2    byte  "zyxwvutsrqponmlkjihgfedcba. ",13,10,0
data3    byte  "me with sing you wont time next, C's B A my know I Now.",0
        