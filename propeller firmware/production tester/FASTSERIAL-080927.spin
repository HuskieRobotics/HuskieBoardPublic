''****************************************************
''*  HALF-DUPLEX HIGH-SPEED PRECISION SERIAL DRIVER  *
''*  FASTSERIAL                                      *
''*  (C) 2008 Peter Jakacki                          *
''****************************************************
{{
This driver dedicates a cog to either receiving or transmitting serial data
in a half-duplex fashion. The aim is to have precise bit timing which is important
at high-speeds at and above 115K baud.

The transmit routines have been to tested to 1Mbit and the receive routines work at 1Mbit

}}

CON
  rxsz          = 256          ' any binary multiple

  databits      = 8
  stopbits      = 1

'mode bits
  invrx         = 0
  invtx         = 1
  open          = 2
  half          = 3             'ignore tx echo on rx
'  
  rs485         = 4             'tepin = txpin, txpin = rxpin
  parity        = 5
  odd           = 6
  xonxoff       = 7
  breakoff      = 8             'disable break detection

VAR

  long  cog                     'cog flag/id
  
  long  rx_head                 '9 contiguous longs accessed by COG
  long  rx_tail

  long  rx_pin                  ' rxpin mask or rxtx mask
  long  tx_pin                  ' txpin mask or te mask
  long  rxtx_mode               ' rxtx mode mask
  long  bit_ticks

  long  txhold
  
  long  buffer_ptr
  long  chksum
                     
  byte  rx_buffer[rxsz]           'transmit and receive buffers


PUB start(rxdpin, txdpin, mode, baudrate) : okay

{{
Start serial driver - starts a cog
returns false if no cog available

mode bits
0 = invert rx
1 = invert tx
2 = open-drain/source tx
3 = ignore tx echo on rx
4 = rs485 (tepin = txpin, txpin = rxpin)
5 = parity enable
6 = odd parity
7 = half-duplex
}}
 
  stop
  txhold := $100
  longfill(@rx_head, 0, 4)
  longmove(@rx_pin, @rxdpin, 3)          ' copy parameter list to memory (quick assignment)
  baud(baudrate)
  buffer_ptr := @rx_buffer               ' setup buffer_ptr to pass to cog (temp)
  okay := cog := cognew(@entry, @rx_head) + 1

PUB baud(baudrate)
  bit_ticks := (clkfreq / baudrate)


PUB stop

'' Stop serial driver - frees a cog

  if cog
    cogstop(cog~ - 1)
  longfill(@rx_head, 0, 9)

    
PUB rxcheck : rxbyte

'' Check if byte received (never waits)
'' returns -1 if no byte received, $00..$FF if byte

  rxbyte--
  if rx_tail <> rx_head
    rxbyte := rx_buffer[rx_tail]
    rx_tail := (rx_tail + 1) & (rxsz-1)

pub rxterm : rxbyte
  rxbyte := 0
  if rx_tail <> rx_head
    rxbyte := rx_buffer[(rx_head-1) & (rxsz-1)]

pub rxstr : rxres
  if rxterm == $0d and rx_head 
    rx_head := 0
    rx_tail := 0
    rxres := @rx_buffer

PUB rx : rxbyte

'' Receive byte (may wait for byte)
'' returns $00..$FF
    repeat while (rxbyte := rxcheck) < 0
    chksum ^= rxbyte

PUB rxtime(ms) : rxbyte | t

'' Wait ms milliseconds for a byte to be received
'' returns -1 if no byte received, $00..$FF if byte
   t := cnt
     repeat until (rxbyte := rxcheck) => 0 or (cnt - t) / (clkfreq / 1000) > ms

PUB tx(txbyte)
  repeat while txhold
  txhold := txbyte|$8000_0000
PUB txcount(txbyte,count)

  tx(txbyte)

pub str(stringptr)
  repeat while txhold
  txhold := stringptr|$4000_0000
     
PUB hexsp(value, digits, sp)     ' print hex number with optional trailing spaces

'' Print a hexadecimal number
  value <<= (8 - digits) << 2
  repeat digits
    tx(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))
  repeat sp
    tx(" ")

PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    tx("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      tx(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      tx("0")
    i /= 10

PUB ndec(value,digits) | i,dg

'' Print a decimal number

  if value < 0
    -value
    tx("-")
    digits--

  i := 1_000_000_000

  repeat dg from 1 to 10
    if value => i
      tx(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1 or dg > 10-digits
      tx("0")
    i /= 10


PUB crlf
  tx($0D)
  tx($0A)


  
'********************************* ANSI TERMINAL SUPPORT ******************

con
  #0,black,red,green,yellow,blue,magenta,cyan,white

pub vtx(ch)
  tx(ch)
pub spaces(n)
  repeat n
    vtx(" ")
pub tab
  vtx(9)
pub atr(ch)
  escb(ch)
  vtx("m")
pub plain
  atr($30)
pub reverse
  atr($37)
pub bold
  atr($31)
pub esc(ch)
  vtx($1b)
  vtx(ch)
pub escb(ch)
  esc($5b)
  vtx(ch)
pub curoff
  escb("?")
  dec(25)
  vtx("l")
pub esch(ch)
  esc($23)
  vtx(ch)
pub dht
  esch("3")
pub dhb
  esch("4")
pub narrow
  esch("5")
pub wide
  esch("6")
pub cur(n,cmd)
  esc($5b)
  dec(n)
  vtx(cmd)
pub xy(x,y)
  esc($5b)
  dec(y)
  vtx(";")
  dec(x)
  vtx("H")
pub home
  escb($48)
pub erscn
  escb("2")
  vtx("J")
pub erline
  escb("2")
  vtx("K")
pub cls
  home
  erscn
pub fg(col)
  escb($33)
  vtx(col+$30)
  vtx($6D)
pub bg(col)
  escb($34)
  vtx(col+$30)
  vtx($6D)
pub margins(top,bottom)
  esc($5b)
  dec(top)
  vtx(";")
  dec(bottom)
  vtx("r")
pub horz(n)| i
  repeat i from 0 to n
    vtx($c4)
pub hline(x,y,n)
  xy(x,y)
  horz(n)
pub vert(n) | i
  repeat i from 1 to n
    str(string($b3,$0a,$08))
pub vline(x,y,n)
  xy(x,y)
  vert(n)
pub box (x,y,w,h)
' top line
  xy(x,y)      ' to top left
  vtx($da)     ' top left corner
  horz(w-2)    ' top line 
  vtx($bf)     ' top right corner
' bottom line
  xy(x,y+h)    ' to bottom left
  vtx($c0)     ' bottom left corner
  horz(w-2)    ' bottom line
' left side
  xy(x,y+1)    ' to left side below corner
  vert(h-1)    ' left side
' right side
  xy(x+w,y+1)
  vert(h-1)
  vtx($d9)     ' bottom right cornet


DAT

'***********************************
'* Assembly language serial driver *
'***********************************

                        org
'
'
' Entry
'
entry                   mov     t1,par                'get structure address
                        add     t1,#8            'skip past heads and tails

                        rdlong  t2,t1                 'get rx_pin bit# (or tr)
                        cmp     t2,#32 wc
         if_c           mov     rxpin,#1
         if_c           shl     rxpin,t2             ' rxpin has 1 bit set 

                        add     t1,#4                 'get tx_pin  (or te)
                        rdlong  t2,t1
                        cmp     t2,#32 wc
         if_c           mov     txpin,#1
         if_c           shl     txpin,t2                '

                        add     t1,#4                   'get rxtx_mode
                        rdlong  config,t1

                        mov     tepin,#0                'prepare tepin
                        test    config,#|<rs485  wz     'rs485?
        if_nz           mov     tepin,txpin             ' the second parameter is actually the transmit enable
        if_nz           mov     txpin,rxpin             ' rx and tx pin are shared so tx is same as rx
        if_nz           andn    outa,tepin              ' make sure te is low
        if_nz           or      dira,tepin              ' activate te
        
                        add     t1,#4                   'get bit_ticks
                        rdlong  bitticks,t1
                        mov     stticks,bitticks
                        shr     stticks,#1
                        sub     stticks,#10

                        add     t1,#4
                        mov     t4,t1                   ' set pointer to txhold
                        wrlong  zero,t4

                        add     t1,#4                   'get buffer_ptr
                        rdlong  rxbuff,t1

                        test    config,#|<open  wz      'init tx pin according to mode
                        test    config,#|<invtx wc
        if_z_ne_c       or      outa,txpin
        if_z            or      dira,txpin

                        mov     txcode,#transmit        'initialize ping-pong multitasking

'******************** end of initialization ***********************

receive                 jmpret  rxcode,txcode           'run a chunk of transmit code, then return
                        test    rxpin,ina       wz
        if_nz           jmp     #receive
                                                        'time sample for middle of start bit
                        mov     rxcnt,cnt
                        add     rxcnt,stticks
                        waitcnt rxcnt,bitticks
                        'sample middle of start bit
                        test    rxpin,ina       wz       'sample middle of start bit
        if_nz           jmp     #receive
'
' START bit validated
'
                        mov     rxbits,#databits+stopbits      'ready to receive byte
                        test    config,#|<parity wz
        if_nz           add     rxbits,#1               'allow an extra bit for parity                        
                        call    #rxchar                 'shift in character+parity+stopbits
                        and     rxdata,#(|<databits)-1  'mask to suit bit size
                       '!!! what are we going to do with received parity???
                        call    #rxstore
                        mov     rxdata,#0               'null terminate
                        add     t2,rxbuff
                        wrbyte  rxdata,t2
                        jmp     #receive                'byte done, receive next byte

rxstore
                        rdlong  t2,par                  'save received byte and inc head
                        add     t2,rxbuff
                        wrbyte  rxdata,t2
                        sub     t2,rxbuff
                        add     t2,#1
                        and     t2,#rxsz-1
                        wrlong  t2,par
rxstore_ret            ret


' receive one character + <parity> + stop
'
rxchar                  mov     rxhold,#1               'shifting mask starting from lsb
                        mov     rxdata,#0
:rxlp                   waitcnt rxcnt,bitticks          'ready next bit period
                        test    rxpin,ina      wc      'receive bit on rx pin
        if_c            or      rxdata,rxhold           ' merge next data bit (rxhold) if 1 (c)
                        shl     rxhold,#1               'promote data mask to next highest bit (0..7)
                        djnz    rxbits,#:rxlp
rxchar_ret              ret
'
'
'************************ Transmit ************************
'
transmit                jmpret  txcode,rxcode         'run a chunk of receive code, then return
                        rdlong  txdata,t4               ' read txhold register for character or stringptr
                        test    txdata,strflg  wz      ' strings will have high order bit set
        if_nz           jmp     #transmitstr
                        test    txdata,chflg wz
        if_nz           wrlong  zero,t4
        if_nz           jmp     #transmitchar                    
                        jmp     #transmit

transmitstr
                        wrlong  zero,t4              ' clear txhold
                        andn    t3,strflg
                        mov     t3,txdata            ' read string pointer into t3
                        
transmitstr1
                        rdbyte  txdata,t3
                        and     txdata,#$ff wz
        if_z            jmp     #transmit        
                        add     t3,#1
                        or      txdata,stopmask
                        shl     txdata,#1

                        mov     txbits,#databits+1+stopbits
                        mov     txcnt,cnt
                        add     txcnt,bitticks
txstr                   shr     txdata,#1       wc    ' lsb first
                        muxc    outa,txpin           ' output bit         
                        waitcnt txcnt,bitticks
                        djnz    txbits,#txstr          'another bit to transmit?
                        jmp     #transmitstr1             'byte done, transmit next byte

transmitchar
                        or      txdata,stopmask
                        shl     txdata,#1

                        mov     txbits,#databits+1+stopbits
txdat                   mov     txcnt,cnt
                        add     txcnt,bitticks
txbit                   shr     txdata,#1       wc    ' lsb first
                        muxc    outa,txpin           ' output bit         
                        waitcnt txcnt,bitticks
                        djnz    txbits,#txbit          'another bit to transmit?
                        jmp     #transmit             'byte done, transmit next byte




stopmask                long    $FFFFFFFF<<databits
strflg                  long    $4000_0000
chflg                   long    $8000_0000
zero                    long    0

txpin                   long    0               'mask of tx pin
rxpin                   long    0               'mask of rx pin

'
'
' Uninitialized data
'
t1                      res     1
t2                      res     1
t3                      res     1
t4                      res     1               'pointer to txhold

config                  res     1
bitticks                res     1
stticks                 res     1

rxbuff                  res     1               'pointer to rxbuf in hub memory
rxdata                  res     1               'assembled character
rxbits                  res     1               'counter
rxcnt                   res     1
rxcode                  res     1
rxhold                  res     1


txdata                  res     1
txcnt                   res     1
txcode                  res     1               ' pointer to current transmit code used by JMPRET

tepin                   res     1
tecnt                   res     1
txbits                  res     1

breakcnt                res     2
lastchar                res     1
rxmask2                 res     1
txmask2                 res     1
rsmask2                 res     1

rsmask                  res     1
        