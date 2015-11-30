{
Author: Bennett Johnson
Revision #: *
Revised by: *

Name: UART Monitor Driver
}


CON
        _clkmode    = xtal1 + pll16x                                           'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq    = 5_000_000
        
        {Commands}
        GIVE_DATA       = $00
        WRITE_DATA      = $01
        SET_LOG_HEADER  = $02
        SET_LOG_NAME    = $03
        CLOSE_LOG       = $04
        SET_TIME        = $05
        'Reserved       = $06
        'Reserved       = $07
        SET_LCD_DISP    = $08
        SET_LCD_SIZE    = $09
        'Reserved       = $0A
        'Reserved       = $0B
        'Reserved       = $0C
        'Reserved       = $0D
        'Reserved       = $0E
        'Reserved       = $0F
        REQUEST_ALL     = $10
        REQUEST_ANALOG  = $11
        SET_PIN         = $12
        'Reserved       = $13 - $FF
        
VAR
    