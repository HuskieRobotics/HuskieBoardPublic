CON
        _clkmode   = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq   = 5_000_000

        rx_pin = 19
        tx_pin = 8
obj

  serial : "FullDuplexSerial2"
  pst : "Parallax Serial Terminal"

pub main | rx, rx_last

  pst.start(115_200)
  pst.str(string("Program Start!",13))

  serial.start(rx_pin,tx_pin,0,115_200,0)

  repeat
    rx_last := rx
    rx := serial.rxtime(10)
    if rx <> rx_last
      pst.hex(rx,8)
      pst.str(string(" ("))
      pst.dec(rx)
      pst.str(string(")",13))
      if rx == $23
        serial.tx(11)