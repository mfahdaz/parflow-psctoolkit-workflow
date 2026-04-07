###############################
#
# This script downloads and compiles PSCTOOLKIT
# and the SUNDIALS library with the routines from
# PSCTOOLKIT.
#
# Author: Manuel Assuncao (m.gaspar.de.assuncao@fz-juelich.de)
# Date: 22-10-2025
#
###############################

exec > >(tee -a "$0.build_log_$(date +%Y.%m.%d_%H.%M)") 2>&1

export BASE_DIR=$(pwd)
export PSCTOOLKIT_DIR=${BASE_DIR}/psctoolkit
export PSCTOOLKIT_BUILD=${BASE_DIR}/build
export PSCTOOLKIT_INSTALL=${BASE_DIR}/install

# Clone PSCTOOLKIT libraries
mkdir -p ${PSCTOOLKIT_DIR}
cd ${PSCTOOLKIT_DIR}
git clone -b v3.9.0-rc-kinsol https://github.com/sfilippone/psblas3.git
git clone -b v1.2.0-rc3 https://github.com/sfilippone/amg4psblas.git
git clone -b psblas_interface https://github.com/psctoolkit/sundials.git
cd sundials
git checkout 5fad036569133e3157965a615a45264e5d72f3fe

# This script follows this installation order:
# PSBLAS -> AMG4PSBLAS -> SUNDIALS

# Important Variables and Flags

export CC="mpicc"
export CXX="mpicxx"
export FC="mpif90"

export FCFLAGS="-ggdb -O0 -fcheck=all"
export CFLAGS="-ggdb -O0"

# Compile PSBLAS

export PSBLAS_DIR=${PSCTOOLKIT_DIR}/psblas3
export PSBLAS_INSTALL=${PSCTOOLKIT_INSTALL}/psblas

cd ${PSBLAS_DIR}
touch compile
./configure --prefix=${PSBLAS_INSTALL} \
            --disable-cuda \
            MPIFC="${FC}" \
            MPICC="${CC}" \
            FCFLAGS="${FCFLAGS}" \
            CFLAGS="${CFLAGS}"
make -j4
make install

echo ""
echo "End of PSBLAS Compilation."
echo ""

# Compile AMG4PSBLAS

export AMG_DIR=${PSCTOOLKIT_DIR}/amg4psblas
export AMG_INSTALL=${PSCTOOLKIT_INSTALL}/amg4psblas

cd ${AMG_DIR}
touch compile
./configure --prefix=${AMG_INSTALL} \
            --with-psblas=${PSBLAS_INSTALL}
make -j4
make install

echo ""
echo "End of AMG4PSBLAS Compilation."
echo ""

# Compile SUNDIALS

export SUNDIALS_DIR=${PSCTOOLKIT_DIR}/sundials
export SUNDIALS_BUILD=${PSCTOOLKIT_BUILD}
export SUNDIALS_INSTALL=${PSCTOOLKIT_INSTALL}/sundials

export PATH_1=${SUNDIALS_DIR}/src/nvector/psblas
bash ${PATH_1}/make2cmakeset.sh ${PSCTOOLKIT_INSTALL} ${PATH_1}
export PATH_2=${SUNDIALS_DIR}/src/sunmatrix/psblas
bash ${PATH_2}/make2cmakeset.sh ${PSCTOOLKIT_INSTALL} ${PATH_2}
export PATH_3=${SUNDIALS_DIR}/src/sunlinsol/psblas
bash ${PATH_3}/make2cmakeset.sh ${PSCTOOLKIT_INSTALL} ${PATH_3}

cd ${SUNDIALS_BUILD}
cmake -DENABLE_MPI=ON \
  -DENABLE_PSCTOOLKIT=ON \
  -DPSCTOOLKIT_DIR=${PSBLAS_INSTALL} \
  -DPSBLAS_LIBRARY_DIR=${PSBLAS_INSTALL} \
  -DAMG_DIR=${AMG_INSTALL} \
  -S ${SUNDIALS_DIR} \
  -B ${SUNDIALS_BUILD} \
  -DSUNDIALS_LOGGING_LEVEL=5 \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX=${SUNDIALS_INSTALL}

make -j4
make install

echo ""
echo "End of SUNDIALS Compilation."
echo ""