{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        
        
        sd_d0       = 1         'SD Card DO
        sd_d1       = 0         'SD Card Data 1
        sd_d2       = 4         'SD Card Data 2      
        sd_d3       = 5         'SD Card CS
        sd_cmd      = 3         'SD Card CMD
        sd_clk      = 2         'SD Card Clock pin
                           
        sd_SPI_DO   = sd_d0
        sd_SPI_CLK  = sd_clk
        sd_SPI_DI   = sd_cmd
        sd_SPI_CS   = sd_d3            
VAR
  long  symbol
   
OBJ
  sd      : "fsrw"
  pst : "Parallax Serial Terminal"
  
PUB public_method_name
  pst.start(115200)    
  sd.setdate(2016, 3, 5, 0, 0, 0)
  DIRA[24..27] ~~
                            
  pst.dec(\sd.mount_explicit(sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS) )

  pst.NewLine
  pst.LineFeed                               
       
  pst.dec(\sd.popen(@file1, "a") )
  pst.NewLine
  pst.LineFeed

  pst.dec(\sd.pputs(@data1))
  pst.Char(" ")
  pst.dec(\sd.pputs(@data2))
  pst.Char(" ")
  pst.dec(\sd.pputs(@data3))
  pst.NewLine
  pst.LineFeed  
  'waitcnt(cnt+clkfreq)
  pst.dec(\sd.pclose       )
  'waitcnt(cnt+clkfreq)
DAT
file1    byte  "abcdcba.txt",0                                     
data1    byte  "abcdefghijklmnopqrstuvwxyz. ",13,10,0
data2    byte  "zyxwvutsrqponmlkjihgfedcba. ",13,10,0
data3    byte  "me with sing you wont time next, C's B A my know I Now.",0
        