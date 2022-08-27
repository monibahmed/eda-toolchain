#!/bin/bash

echo $HOME

export PATH=$PATH:$PWD/OpenLane:$PWD/OpenLane/scripts
export PDK_ROOT=$HOME/share/pdk
export PDK=sky130A
export STD_CELL_LIBRARY=sky130_fd_sc_hd
export STD_CELL_LIBRARY_OPT=sky130_fd_sc_hd
export OPENLANE_LOCAL_INSTALL=1
