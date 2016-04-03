{AUTHOR: Calvin Field}
{PURPOSE: Will control sd card functions on a different cog
          Must be on a different cog becuase all other code is suspended if an sd card is not mounted}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        OPEN_FILE  = 1
        WRITE_DATA = 2
        CLOSE_FILE = 3

VAR
  byte sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS
  byte function
  long stack[300]
  byte filename[13]
  byte data_to_write[256]
   
OBJ
  sd      : "fsrw"
  
PUB start(sd_do, sd_clk, sd_di, sd_cs)

  'All the pins for the sd card
  sd_SPI_DO  := sd_do
  sd_SPI_CLK := sd_clk
  sd_SPI_DI  := sd_di
  sd_SPI_CS  := sd_cs

  cognew(main, @stack)
  
PUB main | x
  sd.mount_explicit(sd_SPI_DO, sd_SPI_CLK, sd_SPI_DI, sd_SPI_CS) 'waits for the sd card to be mounted and sets up the pins

  
  repeat
    x := 0 
  
    if function == OPEN_FILE
      sd.popen(filename, "a") 'Open the file
      
      repeat x from 0 to 13         'Reset the file name
        byte[@filename+x] := 0
        
      function := 0 'Reset the fucntion
      

    if function == WRITE_DATA
      sd.pputs(data_to_write) 'Write the data to the open file

      repeat x from 0 to 256        'Reset what is to be written
        byte[@data_to_write+x] := 0

      function := 0 'Reset the function
    

    if function == CLOSE_FILE
      sd.pclose   'Close the currently opened file

      function := 0 'Reset the function

PRI openFile(name)
  filename := name
  function := 1

PRI write(data)
  data_to_write := data
  function := 2

PRI closeFile
  function := 3
    