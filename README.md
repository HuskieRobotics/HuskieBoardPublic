# The Huskie Board
## Overview
The Huskie Board, designed by Team 3061, is an FRC qualified expansion board for the
NI roboRIO robotics controller. In addition to breaking out all available signals on the
MXP expansion port, this board uses a Parallax Propeller chip (8 symmetrical logical
cores with shared memory and peripheral access) to enable tasks such as advanced
data logging, on-field driver control and status, and NeoPixel control. Additional GPIO
and analog inputs are added with open source code to allow further customization.


## Firmware
The Huskie Board's firmware is stored on a 32 KB Flash chip. It can be upgraded over USB, and teams are welcome to load their own firmware. All Huskie Board firmware is stored in the `propeller firmware/` directory.

## roboRIO software
The LabView firmware is available in the `LabView/LabVIEW API/` directory. This includes examples in the `Examples/` folder, and the API source code in the `Huskie Board/` folder. See `install.txt` for more information.

Currently, the roboRIO API is only available for labview, though we hope to port it for C++ and Java soon.

## Hardware
The Huskie Board was designed in Eagle CAD, and sources are available in `Eagle CAD/projects/HuskieBoard/`.