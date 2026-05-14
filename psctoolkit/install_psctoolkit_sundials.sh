#!/usr/bin/env bash
###############################
#
# PSCToolKit + SUNDIALS Installation Script
#
# This script downloads and compiles:
#   1. PSBLAS
#   2. AMG4PSBLAS
#   3. SUNDIALS (with PSCToolKit interface)
#
# authors: Muhammad Fahad Azeemi, Manuel Assuncao
# e-mail: <m.fahad, m.gaspar.de.assuncao>@fz-juelich.de
# version: 2026-05-14
#
###############################

set -euo pipefail

############################
# Logging
############################

LOGFILE="$(basename "$0").build_log_$(date +%Y.%m.%d_%H.%M)"
exec > >(tee -a "${LOGFILE}") 2>&1

echo "=== PSCToolKit build started at $(date) ==="

############################
# Directory Layout
############################

export BASE_DIR="$(pwd)"

export PSCTOOLKIT_DIR="${BASE_DIR}"
export BUILD_DIR="${BASE_DIR}/build"
export INSTALL_DIR="${BASE_DIR}/install"

export PSBLAS_DIR="${PSCTOOLKIT_DIR}/psblas3"
export AMG_DIR="${PSCTOOLKIT_DIR}/amg4psblas"
export SUNDIALS_DIR="${PSCTOOLKIT_DIR}/sundials"

export PSBLAS_INSTALL="${INSTALL_DIR}/psblas"
export AMG_INSTALL="${INSTALL_DIR}/amg4psblas"
export SUNDIALS_INSTALL="${INSTALL_DIR}/sundials"

mkdir -p "${PSCTOOLKIT_DIR}" "${BUILD_DIR}" "${INSTALL_DIR}"

############################
# Compiler Configuration
############################

export CC=mpicc
export CXX=mpicxx
export FC=mpif90

export FCFLAGS="-ggdb -O0 -fcheck=all"
export CFLAGS="-ggdb -O0"

NPROC=${NPROC:-4}

############################
# Helper Functions
############################

section () {
  echo ""
  echo "=================================================="
  echo "$1"
  echo "=================================================="
}

clone_if_missing () {
  repo=$1
  branch=$2
  dest=$3

  if [ ! -d "$dest" ]; then
    git clone -b "$branch" "$repo" "$dest"
  else
    echo "Repository already exists: $dest"
  fi
}

############################
# Clone Dependencies
############################

section "Cloning repositories"

cd "${PSCTOOLKIT_DIR}"

clone_if_missing \
  https://github.com/sfilippone/psblas3.git \
  maint-3.9.0 \
  "${PSBLAS_DIR}"

clone_if_missing \
  https://github.com/sfilippone/amg4psblas.git \
  maint-1.2.0 \
  "${AMG_DIR}"

clone_if_missing \
  https://github.com/psctoolkit/sundials.git \
  psblas_interface \
  "${SUNDIALS_DIR}"

############################
# Build Order
# PSBLAS → AMG4PSBLAS → SUNDIALS
############################

############################
# Build PSBLAS
############################

section "Building PSBLAS"

cd "${PSBLAS_DIR}"

./configure \
  --prefix="${PSBLAS_INSTALL}" \
  --disable-cuda \
  MPIFC="${FC}" \
  MPICC="${CC}" \
  FCFLAGS="${FCFLAGS}" \
  CFLAGS="${CFLAGS}"

make -j${NPROC}
make install

echo "PSBLAS installation complete."

############################
# Build AMG4PSBLAS
############################

section "Building AMG4PSBLAS"

cd "${AMG_DIR}"

./configure \
  --prefix="${AMG_INSTALL}" \
  --with-psblas="${PSBLAS_INSTALL}"

make -j${NPROC}
make install

echo "AMG4PSBLAS installation complete."

############################
# Prepare SUNDIALS PSCToolKit Interface
############################

section "Preparing SUNDIALS PSCToolKit modules"

PATH_1="${SUNDIALS_DIR}/src/nvector/psblas"
PATH_2="${SUNDIALS_DIR}/src/sunmatrix/psblas"
PATH_3="${SUNDIALS_DIR}/src/sunlinsol/psblas"

bash "${PATH_1}/make2cmakeset.sh" "${INSTALL_DIR}" "${PATH_1}"
bash "${PATH_2}/make2cmakeset.sh" "${INSTALL_DIR}" "${PATH_2}"
bash "${PATH_3}/make2cmakeset.sh" "${INSTALL_DIR}" "${PATH_3}"

############################
# Build SUNDIALS
############################

section "Building SUNDIALS"

cmake \
  -S "${SUNDIALS_DIR}" \
  -B "${BUILD_DIR}" \
  -DENABLE_MPI=ON \
  -DENABLE_PSCTOOLKIT=ON \
  -DPSCTOOLKIT_DIR="${PSBLAS_INSTALL}" \
  -DPSBLAS_LIBRARY_DIR="${PSBLAS_INSTALL}" \
  -DAMG_DIR="${AMG_INSTALL}" \
  -DSUNDIALS_LOGGING_LEVEL=5 \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX="${SUNDIALS_INSTALL}"

cmake --build "${BUILD_DIR}" -j${NPROC}
cmake --install "${BUILD_DIR}"

echo "SUNDIALS installation complete."

############################
# Done
############################

echo ""
echo "=== PSCToolKit + SUNDIALS build finished successfully ==="
echo "Installation directory:"
echo "  ${INSTALL_DIR}"
echo ""