export SUNLOGGER_ERROR_FILENAME="sundials.error.log"
export SUNLOGGER_WARNING_FILENAME="sundials.warning.log"
export SUNLOGGER_INFO_FILENAME="sundials.info.log"
export SUNLOGGER_DEBUG_FILENAME="sundials.debug.log"

export PARFLOW_DIR="${PWD}/parflow_install"

xsplit=1
ysplit=1
nprocs=1 # must be a square number
ncells=3 # 3 x 3 x 3 cells

tclsh clayL_tiny.tcl ${xsplit} ${ysplit} ${nprocs} ${ncells}

${PARFLOW_DIR}/bin/parflow clayL_tiny_${xsplit}_${ysplit}_${nprocs}_${ncells} \
  > out.txt 2> error.txt