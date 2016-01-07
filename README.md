#Roborio Expansion Board
=======================
###This is Team 3061's design for an expansion board for the roboRIO
The 2015 v1 board had a few issues with the SD card, and is no longer under development. It's sources can be found in the expansion-Board-1.0-final branch.

The 2016 v2 board design files are **still under development**, but can be found in the RoboRio-ExpansionBoard-V2 branch. 

The running code for both boards is currently in the master branch, though that will hopefully change soon.

To get Eagle cad (our schematic and board editor) ready for editing, you will need to add ";(Insert github dir here)\lbr\CustomLibraries" to the lbr directory,
and ";(Insert github dir here)\projects\RoboRio" to the Projects directory.
These can be set under Options->Directories, where you must then append these to
the appropriate section. Include the semicolon.
