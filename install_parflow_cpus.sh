#!/bin/bash
#
# authors: Muhammad Fahad Azeemi, Manuel Assuncao
# e-mail: <m.fahad, m.gaspar.de.assuncao>@fz-juelich.de
# version: 2026-05-14
# 
# Installs ParFlow with PSCToolkit interface with Sundials
# 
# USAGE:
# Install with default settings
# >> bash install_parflow_cpus.sh
# 
# Install with user provided modules
# >> bash install_parflow_cpus.sh --loadenv=/PATH/TO/ENV/FILE
#-------------------------------------------------------------------------------

# define your settings here (no need to touch other stuff)
export BASE_ROOTDIR=$(pwd)
export PF_DIR=${BASE_ROOTDIR}/parflow  # where parflow is downloaded
export PARFLOW_DIR=${BASE_ROOTDIR}/parflow_install  # where parflow is installed
export PF_BUILD_DIR=${BASE_ROOTDIR}/parflow_build
export PSCTOOLKIT_INSTALL=${BASE_ROOTDIR}/psctoolkit/install
export PSBLAS_INSTALL=${PSCTOOLKIT_INSTALL}/psblas
export AMG_INSTALL=${PSCTOOLKIT_INSTALL}/amg4psblas
export SUNDIALS_INSTALL=${PSCTOOLKIT_INSTALL}/sundials
#-------------------------------------------------------------------------------

# color codes for different logs
cnormal=$(tput sgr0)
corange=$(tput setaf 166)
ccyan=$(tput setaf 6)
cgreen=$(tput setaf 2)
cred=$(tput setaf 1)
cblue=$(tput setaf 3)
#-------------------------------------------------------------------------------

# check if patht to env file is provided
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help    Display help"
}

case "$1" in
    -h | --help)
        print_usage
        exit 0
        ;;
esac
#-------------------------------------------------------------------------------

exec > >(tee -a "$0.build_log_$(date +%Y.%m.%d_%H.%M)") 2>&1
# save current env for documentation
env > $0.env_compile_time.txt
#-------------------------------------------------------------------------------

# clean up everything
rm -rf $PF_BUILD_DIR $PARFLOW_DIR $PF_DIR
mkdir -vp $PF_BUILD_DIR $PARFLOW_DIR $PF_DIR

# print dir locations
echo "-- ${cblue}PF_DIR ${cnormal}(where parflow will be downloaded): $PF_DIR"
echo "-- ${cblue}PARFLOW_DIR ${cnormal}(parflow installation directory): $PARFLOW_DIR"
echo "-- ${cblue}PF_BUILD_DIR ${cnormal}(parflow build directory): $PF_BUILD_DIR"
echo "-- ${cblue}PSCTOOLKIT_INSTALL ${cnormal}: $PSCTOOLKIT_INSTALL"
echo "-- ${cblue}PSBLAS_INSTALL ${cnormal}: $PSBLAS_INSTALL"
echo "-- ${cblue}AMG_INSTALL ${cnormal}: $AMG_INSTALL"
echo "-- ${cblue}SUNDIALS_INSTALL ${cnormal}: $SUNDIALS_INSTALL"
echo

#-------------------------------Parflow-----------------------------------------
echo ${ccyan}"building Parflow..." ${cnormal}
# download parflow
git clone -b psctoolkit_interface https://github.com/mfahdaz/parflow.git $PF_DIR

# build and install
cd $PF_BUILD_DIR

cmake $PF_DIR \
    -DCMAKE_INSTALL_PREFIX=${PARFLOW_DIR} \
	-DPARFLOW_AMPS_LAYER=mpi1 \
	-DTCL_TCLSH=${EBROOTTCL}/bin/tclsh8.6 \
    -DPARFLOW_ENABLE_PSCTOOLKIT=TRUE \
    -DPSBLAS_ROOT=${PSBLAS_INSTALL} \
    -DAMG_ROOT=${AMG_INSTALL} \
    -DSUNDIALS_ROOT=${SUNDIALS_INSTALL} \
	-DPARFLOW_AMPS_SEQUENTIAL_IO=on \
	-DPARFLOW_ENABLE_TIMING=TRUE \
	-DCMAKE_BUILD_TYPE=Debug \
	-DCMAKE_C_FLAGS='-fopenmp -Wall -Wno-dev' \
	-DPARFLOW_ENABLE_SLURM=TRUE

make -j4
make install
if [ $? -eq 0 ]; then
        echo ${cgreen}"Parflow is installed sucessfully!"${cnormal}
else
        echo ${cred}"Parflow installation failed!"${cnormal}
        exit 1
fi
exit 0
