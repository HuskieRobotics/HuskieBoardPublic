{AUTHOR: Calvin Field}

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
  sd : "SD Controller"
  pst : "Parallax Serial Terminal"

PUB main
  pst.start(115200)

  sd.start(sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS)
  pst.str(string("Started logger"))
  pst.char(13)
  sd.openFile(@file1)
  pst.str(string("Opened file"))
  pst.char(13)
  sd.write(@data1)
  pst.str(string("Wrote Data"))
  pst.char(13)
  sd.closeFile
  pst.str(string("Closed file"))
  pst.char(13)
DAT
  file1    byte  "TESTER1.txt",0
  data1    byte  "Boi, it works, maybe.",0
              