{AUTHOR: Calvin Field}
{Tests the functionality of SD Controller}

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
OBJ
  sd      : "SD Controller"
  util    : "Util"
PUB main
  
  sd.start(sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS)
  util.wait(1)
  sd.openFile(@file1)
  sd.writeData(@data1)
  sd.closeFile
DAT
  file1    byte  "TESTER.txt",0            
  data1    byte  "Hi there!",13,0
              