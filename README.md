# ParFlow - PSCToolKit Interface Workflow

This repository provides a workflow for building and running ParFlow with the PSCToolKit interface.

Development is currently carried out on the following branch:

https://github.com/mfahdaz/parflow/tree/psctoolkit_interface

## Repository Structure

```
.
├── install_parflow_cpus.sh   # ParFlow installation script
├── psctoolkit/               # PSCToolKit source and install scripts
├── testcases/                # Example simulation cases
├── run.sh                    # Standard example run
├── run_tiny.sh               # Minimal debugging run
└── README.md
```
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

#### Local / Non-cluster Installation Notes

On some systems (especially local):

The command `echo -e` may fail. Replace occurrences of: `echo -e` with `printf` in `make2cmakeset.sh` on PATH_1, PATH_2 and PATH_3.

Then rerun the script starting from the SUNDIALS compilation step.

Make sure all required environment variables exported earlier in the script are still defined before restarting.

### 2. Install ParFlow

After PSCToolKit finishes installing:

```bash
cd ${ROOT_DIR}
bash install_parflow_cpus.sh
```

#### Requirement

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

## Recommended Workflow
1. Install PSCToolKit
2. Install ParFlow
3. Run `run_tiny.sh` to validate installation
4. Run `run.sh` for performance or scaling tests

## Troubleshooting Tips
- Verify Tcl version (< **8.6.14**)
- Ensure environment variables persist across shells
- Confirm MPI and compiler modules are loaded consistently
- If builds fail on laptops, replace echo -e with printf