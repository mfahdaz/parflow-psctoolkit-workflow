# ParFlow - PSCToolKit Interface Workflow

This repository provides a reproducible workflow for building and running ParFlow with the PSCToolKit interface, including support for the PSCToolKit NVector interface with the SPGMR solver.

Development is currently carried out on:

https://github.com/mfahdaz/parflow/tree/psctoolkit_interface

## Repository Structure

```
.
├── install_parflow_cpus.sh            # Standard ParFlow + PSCToolKit build
├── install_pf_psctoolkit_spgmr.sh     # ParFlow build using PSCToolKit NVector and KINSOL SPGMR
├── psctoolkit/                        # PSCToolKit + SUNDIALS installation
├── testcases/                         # Example simulation cases
├── run.sh                             # Standard large testcase
├── run_tiny.sh                        # Minimal validation run
├── run_tiny_psctoolkit_spgmr.sh       # ParFlow-PSCToolkit NVector inteface with KINSOL SPGMR validation run
├── LICENSE
└── README.md
```

## Overview

Two ParFlow configurations are supported:
| **Configuration**                     | **Purpose**                                               |
| ---------------------------------     | ----------------------------------------------------- |
| Standard PSCToolKit Interface         | Default ParFlow build using PSCToolKit                |
| PSCToolKit NVector + SPGMR            | Experimental (PF+PSCToolkit NVector) interface using SUNDIALS SPGMR solver    |



## Installation

Installation consists of two main steps:

1. Install PSCToolKit
2. Install ParFlow

### 1. Install PSCToolKit

From the repository root:

```bash
export ROOT_DIR=${PWD}
cd ${ROOT_DIR}/psctoolkit
bash install_psctoolkit_sundials.sh
```

This step installs:

- PSBLAS
- AMG4PSBLAS
- SUNDIALS with PSCToolKit interface

Installation location:

`psctoolkit/install/`

#### Local / Non-cluster Installation Notes

Some systems do not correctly support: `echo -e`. In such a case, replace occurrences of: `echo -e` with `printf` in `make2cmakeset.sh` on PATH_1, PATH_2 and PATH_3 defined in lines `156-158` of installation script `install_psctoolkit_sundials.sh`.

Then rerun the script starting from the SUNDIALS compilation step.

Make sure all required environment variables exported earlier in the script are still defined before restarting.

### 2. Install ParFlow

After PSCToolKit installation completes, choose one build configuration.

#### Option A - Standard ParFlow + PSCToolKit

Recommended for:

- regular simulations
- scaling studies
- general development

```bash
cd ${ROOT_DIR}
bash install_parflow_cpus.sh
```

#### Option B - ParFlow with PSCToolKit NVector + SPGMR

This configuration builds ParFlow using the PSCToolKit NVector interface and runs simulations using the SUNDIALS SPGMR iterative solver.

Recommended for:

- interface validation
- solver development
- PSCToolKit NVector testing

```bash
cd ${ROOT_DIR}
bash install_pf_psctoolkit_spgmr.sh
```

#### Tcl Requirement

ParFlow must be compiled with: `Tcl version < 8.6.14`

Using newer Tcl versions causes runtime failures.

## Running Example Cases

Example simulations are provided in: `testcases/`. Two versions of the ClayL test case are included.

### Available Test Cases
1. clayL_tiny.tcl
    - Designed for debugging and validation
    - Very small computational domain
    - Fast execution
2. clayL.tcl
    - Larger domain configuration
    - Suitable for:
        - performance testing
        - weak scaling experiments


#### Runtime Parameters

Both test cases accept parameters passed by the run scripts:

| **Parameter** | **Description**                                            |
| --------- | ------------------------------------------------------ |
| `xsplit`  | Number of process partitions in x-direction            |
| `ysplit`  | Number of process partitions in y-direction            |
| `nodes`   | Number of compute nodes (**must be a perfect square**) |
| `ncells`  | Number of grid cells in x and y directions             |


**Notes**

- The z-dimension is fixed for each testcase.
- ncells must be divisible by both xsplit and ysplit.


## Run Scripts

The repository root provides ready-to-use run scripts.

### 1. run_tiny.sh 
Runs the debugging testcase:

- Domain size: **3 × 3 × 3**
- Process topology: **1 × 1 × 1**
- Single-node execution
- Fixed z-dimension: **3**

Run with:

```bash
bash run_tiny.sh
```
Recommended for:

- verifying installation
- debugging workflow issues

### 2. run.sh

Runs the larger ClayL testcase:

- Domain size: **100 × 100 × 240**
- Process topology: **2 × 2 × 1**
- Single-node execution
- Fixed z-dimension: **240**

Run with:

```bash
bash run.sh
```

This script can also be adapted for:

- weak scaling experiments
- multi-node runs
- custom domain sizes
- different MPI process layouts

Modify the script parameters to change:

- domain size
- number of nodes
- processes per node

### 3. run_tiny_psctoolkit_spgmr.sh

Validation run for the PSCToolKit NVector + SPGMR interface.

Purpose:

- verify NVector integration
- confirm SPGMR solver functionality
- minimal fast test

Run with:

```bash
bash run_tiny_psctoolkit_spgmr.sh
```

## Recommended Workflow
### Standard Usage

```
1. Install PSCToolKit
2. Install ParFlow
3. Run `run_tiny.sh` to validate installation
4. Run `run.sh` for performance or scaling tests
```

### PF + SPGMR + PSCToolkit Nvector Interface Testing

```
1. Install PSCToolKit
2. Install ParFlow SPGMR build
3. Run run_tiny_psctoolkit_spgmr.sh
```

## Troubleshooting Tips
- Verify Tcl version (< **8.6.14**)
- Ensure environment variables persist across shells
- Confirm MPI and compiler modules are loaded consistently
- If builds fail on laptops, replace echo -e with printf