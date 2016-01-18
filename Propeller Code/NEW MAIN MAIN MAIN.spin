{
Author: Bennett Johnson
Revision #: *
Revised by: *

Packet Types
$00ff: does something

}


con
        _clkmode    = xtal1 + pll16x                                           'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq    = 5_000_000
        
        lcd_pin     = 15        'LCD communication pin
        lcd_baud    = 19_200    'LCD communication baudrate
        
        prop_rx     = 31        'Prop-Plug communication recieve pin
        prop_tx     = 30        'Prop-Plug communication transmit pin
        
        eeprom_sda  = 29        'EEPROM data line  -- Transfers data based on clock line
        eeprom_scl  = 28        'EEPROM clock line -- Keeps time to ensure packet viability
       
        adc_CS      = 23        'To be Defined
        adc_D0      = 22        'To be Defined
        adc_D1      = 21        'To be Defined
        adc_CLK     = 20        'To be Defined
        
        gpio_0      = 4         'General Purpose Input Output Pin 0
        gpio_1      = 5         'General Purpose Input Output Pin 1
        gpio_2      = 6         'General Purpose Input Output Pin 2
        gpio_3      = 7         'General Purpose Input Output Pin 3
        
        robo_tx     = 19        'RoboRIO Transmit Pin
        robo_rx     = 8         'RoboRIO Recieve Pin
        
        robo_cs     = 9         'To be Defined
        robo_clk    = 10        'To be Defined
        robo_miso   = 11        'To be Defined
        robo_mosi   = 12        'To be Defined
        robo_sda    = 13        'To be Defined
        robo_scl    = 14        'To be Defined
        
        sd_d0       = 1         'To be Defined
        sd_d1       = 0         'To be Defined
        sd_d2       = 0         'To be Defined
        sd_d3       = 27        'To be Defined
        sd_cmd      = 3         'To be Defined
        sd_clk      = 2         'To be Defined
        sd_detect   = 26        'To be Defined
        sd_switch   = 24        'To be Defined
        
        led_grn     = 18        'Onboard Green LED pin
        led_ylw     = 17        'Onboard Yellow LED pin
        led_red     = 16        'Onboard Red LED pin
        
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
        longfill(@datfilename, 0, 32)   'fill data file name with zeros until the thirty second byte
        init                            'Initialize all drives


pri init
        {ADC DRIVER}
        adc.start2pin(adc_di, adc_do, adc_clk, adc_cs, $00FF)   'Start ADC Driver
        adcpointer := adc.pointer                               'Set ADC Pointer to ADC Driver constant

        {NEW ADC DRIVER}
        adc2.start(adc_cs,adc_clk,adc_di,adc_do)
        
        {UART CONNECTION DRIVER}
        uart.init(robo_rx, robo_tx, 460_800, )
        
        {SD DRIVER}
        sd.init(27, 25, 0, 1, @sdpointer, @datfilename, adcpointer, @stop, @FAT32Time) {WISWARD NUMBERS AAAAAGHHHHHH}

        