#!/bin/bash

cd ../../maps
MAPFILE='Z.03.USS_Almayer.dmm'
copy %MAPFILE% %MAPFILE%.backup
MAPFILE='Z.01.LV624.dmm'
copy %MAPFILE% %MAPFILE%.backup
MAPFILE='Z.01.Prison_Station_FOP.dmm'
copy %MAPFILE% %MAPFILE%.backup
MAPFILE='Z.01.BigRed_v2.dmm'
copy %MAPFILE% %MAPFILE%.backup
MAPFILE='Z.01.Ice_Colony_v2.dmm'
copy %MAPFILE% %MAPFILE%.backup
MAPFILE='Z.01.Davn_Bap.dmm'
copy %MAPFILE% %MAPFILE%.backup
MAPFILE='Z.01.Desert_Dam.dmm'
copy %MAPFILE% %MAPFILE%.backup
MAPFILE='Z.01.Whiskey_Outpost.dmm'
copy %MAPFILE% %MAPFILE%.backup

pause
