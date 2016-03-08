{
Author: Bennett Johnson
Revision #1: Added line for new ADC driver
Revised by: Lucas Rezac

Packet Types                                     
$00ff: does something

}


con
        _clkmode    = xtal1 + pll16x                                           'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq    = 5_000_000
        
        lcd_pin     = 18        'LCD communication pin
        lcd_baud    = 19_200    'LCD communication baudrate
        
        'prop_rx     = 31 'This might be interfering with stuff       'Prop-Plug communication recieve pin
        'prop_tx     = 30 'This might be interfering with stuff      'Prop-Plug communication transmit pin
        
        eeprom_sda  = 29        'EEPROM data line  -- Transfers data based on clock line
        eeprom_scl  = 28        'EEPROM clock line -- Keeps time to ensure packet viability
       
        adc_CS1     = 20        'To be Defined
        adc_CS2     = 19        'To be Defined
        adc_D0      = 21        'To be Defined
        adc_D1      = 23        'To be Defined
        adc_CLK     = 22        'To be Defined
        
        gpio_0      = 14        'General Purpose Input Output Pin 0
        gpio_1      = 15        'General Purpose Input Output Pin 1
        gpio_2      = 16        'General Purpose Input Output Pin 2
        gpio_3      = 17        'General Purpose Input Output Pin 3

        robo_i2c_scl =12
        robo_i2c_sda =13
        
        robo_tx     = 30'11        'RoboRIO Transmit Pin
        robo_rx     = 31'10        'RoboRIO Recieve Pin
        
        robo_cs     = 9         'RoboRIO CS Pin
        robo_clk    = 8         'RoboRIO Clock Pin
        robo_miso   = 7         'RoboRIO MISO
        robo_mosi   = 6         'RoboRIO MOSI

        switch_1    = robo_cs
        switch_2    = robo_clk
        switch_3    = robo_miso
        switch_4    = robo_mosi
        
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
        
        led_0       = 24        'Onboard Green LED pin 0
        led_1       = 25        'Onboard Green LED pin 1
        led_2       = 26        'Onboard Green LED pin 2
        led_3       = 27        'Onboard Green LED pin 3
        
        neopixel    = gpio_0    'Point Neopixel to GPIO Pin 0 -- For ease of use
                                
        
var
    byte datfilename[256]   'SD File name long -- only 255 bytes long
    byte stop               'Stop byte
    byte robodata[8]        'Data Transmitted by robot
    long sdpointer          'Pointer to SD Driver
    long adcpointer         'Pointer to ADC Driver
    long lcdpointer         'Pointer to LCD Driver
    long fat32time          'Time for data file


obj
        uart    : "RR uart connection"
        sd      : "SDcardLogger"
        adc     : "ADC driver"
        adc2    : "jm_adc124s021"

pub main
        longfill(@datfilename, 0, 32)   'fill data file name with zeros until the thirty-second byte
        init                            'Initialize all drives


pri init
        {OLD ADC DRIVER}
        'adc.start2pin(adc_di, adc_do, adc_clk, adc_cs, $00FF)   'Start ADC Driver
        'adcpointer := adc.pointer                               'Set ADC Pointer to ADC Driver constant

        {NEW ADC DRIVER}
        'adc2.start(adc_cs1,adc_cs2,adc_clk,adc_di,adc_do)

        {UART CONNECTION DRIVER}
        uart.init(robo_rx, robo_tx, 230400, sdpointer, datfilename, lcd_pin, lcd_baud, stop, neopixel, led_0, led_1, led_2, fat32time, robodata)
        
        {SD DRIVER}
        'sd.init(27, 25, 0, 1, @sdpointer, @datfilename, adcpointer, @stop, @FAT32Time) {WISWARD NUMBERS AAAAAGHHHHHH}

                                  