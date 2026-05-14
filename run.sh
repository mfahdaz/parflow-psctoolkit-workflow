#!/bin/bash

export SUNLOGGER_ERROR_FILENAME="sundials.error.log"
export SUNLOGGER_WARNING_FILENAME="sundials.warning.log"
export SUNLOGGER_INFO_FILENAME="sundials.info.log"
export SUNLOGGER_DEBUG_FILENAME="sundials.debug.log"

export PARFLOW_DIR="${PWD}/parflow_install"

xsplit=2  # number of processes to split x dimension
ysplit=2  # number of processes to split y dimension
nodes=1 # number of nodes - must be a square number
ncells=100 # square problem size. NZ is set as 240. It makes 100 x 100 x 240 domain size.

tclsh testcases/clayL.tcl ${xsplit} ${ysplit} ${nodes} ${ncells}

${PARFLOW_DIR}/bin/parflow clayL_${xsplit}_${ysplit}_${nodes}_${ncells} \
  > out.txt 2> error.txt

exit 0