{AUTHOR: Calvin Field}
{This is basically a passthrough object for the fsrw object
This is needed because the mounting of the sd card needs to be on a separate cog}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000


VAR
  byte sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS
  long stack[100]    
  byte fileOpen
  
OBJ
  sd      : "fsrw"

PUB start(sd_do, sd_clk, sd_di, sd_cs)

  'All the pins for the sd card
  sd_SPI_DO  := sd_do
  sd_SPI_CLK := sd_clk
  sd_SPI_DI  := sd_di
  sd_SPI_CS  := sd_cs
                                     
  fileOpen := false
  
  cognew(mount, @stack)
               
PRI mount
  'wait until card is inseted, using the abort catch                                       
  repeat while \sd.mount_explicit(sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS) < 0 

PUB setdatedirect(date) 'Must call BEFORE opening the file, if you want the "recently modified" date to be correct. Otherwise, not required.
  sd.setdatedirect(date)

PUB openFile(filePt, mode)
  if fileOpen
    return
  fileOpen := true
  return \sd.popen(filePt, mode)

PUB writeData(datPt)
  if fileOpen
    \sd.pputs(datPt)
    \sd.pflush

PUB readData(buffer, numBytes)
  return \sd.pread(buffer, numBytes)
  
PUB closeFile
  \sd.pclose
  fileOpen := false
                       