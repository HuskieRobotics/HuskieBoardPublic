{AUTHOR: Calvin Field}
{This is basically a passthrough object for the fsrw object
This is needed because the mounting of the sd card needs to be on a separate cog}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000


VAR
  byte sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS
  long stack[100]
  
OBJ
  sd      : "fsrw"

PUB start(sd_do, sd_clk, sd_di, sd_cs)

  'All the pins for the sd card
  sd_SPI_DO  := sd_do
  sd_SPI_CLK := sd_clk
  sd_SPI_DI  := sd_di
  sd_SPI_CS  := sd_cs

  cognew(mounter, @stack)

PRI mounter
  sd.mount_explicit(sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS) 'waits for the sd card to be mounted and sets up the pins
PUB openFile(filePt)
  sd.popen(filePt, "a")
  
PUB writeData(datPt)
  sd.pputs(datPt)
  sd.pflush
  
PUB closeFile
  sd.pclose                           