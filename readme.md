# ParFlow - PSCToolKit Interface Workflow

The development of the ParFlow-PSCToolKit Interface is being done on the following github repo branch:
https://github.com/tikoh-station/parflow/tree/psctoolkit_interface

# Installation

Start with the installation of PSCToolKit. You may use our script by running the commands:
```
export BASE_DIR=${PWD}
cd ${BASE_DIR}/psctoolkit
bash install_psctoolkit_sundials.sh
```

If you are trying to make the installation on a laptop, you might have to replace the `echo -e` command with `printf` and rerun the commands in this script from the Sundials compilation (don't forget to set the exports for variables holding directory paths).

Afterwards, proceed with the installation of ParFlow. (Note: you must use a version of Tcl lower than 8.6.14)

```
cd ${BASE_DIR}
bash install_parflow_cpus.sh
```

# Running an example case

In this workflow repo, two test cases based on the same problem are provided, the difference being the size of the domain.

Firstly, there is run case with a tiny 3x3x3 domain, useful for debugging. It can be run with the following command:
```
bash run_tiny.sh
```

Secondly, there is our default run case for weak scaling tests, with a 100x100x240 domain. It can be run with the following command:
```
bash run.sh
```

