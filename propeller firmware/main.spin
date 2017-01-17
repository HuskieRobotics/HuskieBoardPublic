con
        _clkmode    = xtal1 + pll16x                                           'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq    = 5_000_000
        
        lcd_pin     = 18        'LCD communication pin
        lcd_baud    = 19_200    'LCD communication baudrate
        LCD_SIZE    = 4         'default lcd size is 4 lines
        
        prop_rx     = 31        'Prop-Plug communication recieve pin
        prop_tx     = 30        'Prop-Plug communication transmit pin
        
        eeprom_sda  = 29        'EEPROM data line  -- Transfers data based on clock line
        eeprom_scl  = 28        'EEPROM clock line -- Keeps time to ensure packet viability
       
        adc_CS1     = 20        
        adc_CS2     = 19        
        adc_DO      = 21        
        adc_DI      = 23       
        adc_CLK     = 22       
        
        gpio_0      = 14        'General Purpose Input Output Pin 0
        gpio_1      = 15        'General Purpose Input Output Pin 1
        gpio_2      = 16        'General Purpose Input Output Pin 2
        gpio_3      = 17        'General Purpose Input Output Pin 3

        robo_i2c_scl =12
        robo_i2c_sda =13
        
        robo_tx     = 11        'RoboRIO Transmit Pin
        robo_rx     = 10        'RoboRIO Recieve Pin
        
        robo_mosi   = 6         'RoboRIO MOSI   
        robo_miso   = 7         'RoboRIO MISO   
        robo_clk    = 8         'RoboRIO Clock Pin 
        robo_cs     = 9         'RoboRIO CS Pin    

        switch_1    = robo_mosi      '6
        switch_2    = robo_miso      '7
        switch_3    = robo_clk       '8
        switch_4    = robo_cs        '9
        
        robo_sda    = 13        'RoboRIO SDA
        robo_scl    = 12        'RoboRIO SCL
        
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
        
        led_1       = 24        'Onboard Green  LED 1
        led_2       = 25        'Onboard Green  LED 2
        led_3       = 26        'Onboard Green  LED 3
        led_4       = 27        'Onboard Red    LED 4
        
        neopixel    = gpio_0    'Point Neopixel to GPIO Pin 0 -- For ease of use


        ROBORIO_UART_CONNECTION_BAUD = 230400    
                                
        FIRMWARE_MAJOR = 1 'up to 256
        FIRMWARE_MINOR = 4 'up to 256
        FIRMWARE_FIX   = 2 'up to 256
        FIRMWARE_TEST  = 0 'up to 256

        FIRMWARE_V = (FIRMWARE_MAJOR * |<0) + (FIRMWARE_MINOR * |<8) + (FIRMWARE_FIX* |<16) + (FIRMWARE_TEST *|<24) 

obj
        uart    : "RR uart connection"

pub main
    scroll
    {UART CONNECTION DRIVER}
    uart.init(ROBORIO_UART_CONNECTION_BAUD, FIRMWARE_V)
     
     
    'LED stuff, for autonomous mode selection
    DIRA[led_1 .. led_4] := $F
    repeat 
      OUTA[led_1 .. led_4] := !INA[robo_MOSI .. robo_CS]

pri scroll 'Quickly scroll through the LEDs twice, to clearly show that the board just booted.
    OUTA[led_1 .. led_4] := 0
    DIRA[led_1 .. led_4] := $F
    repeat 2                       
      waitcnt(cnt+clkfreq/10)
      OUTA[led_1 .. led_4] := %0001
      waitcnt(cnt+clkfreq/10)
      OUTA[led_1 .. led_4] := %0011
      waitcnt(cnt+clkfreq/10)
      OUTA[led_1 .. led_4] := %0010
      waitcnt(cnt+clkfreq/10)
      OUTA[led_1 .. led_4] := %0110
      waitcnt(cnt+clkfreq/10)
      OUTA[led_1 .. led_4] := %0100
      waitcnt(cnt+clkfreq/10)
      OUTA[led_1 .. led_4] := %1100
      waitcnt(cnt+clkfreq/10)
      OUTA[led_1 .. led_4] := %1000
      waitcnt(cnt+clkfreq/10)
      OUTA[led_1 .. led_4] := %1001
    OUTA[led_1 .. led_4] := 0
    DIRA[led_1 .. led_4] := 0                        