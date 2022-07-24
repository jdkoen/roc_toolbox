
# ROC Toolbox for Matlab

## Purpose

This toolxbox is intended to fit models of memory and cognition using signal detection theory based on ratings (i.e., confidence-based response) data. There are three general classes of models included in the toolbox:

* Unequal-variance signal detection model (`uvsd`)
* Dual-process signal detection model (`dpsd`)
* Mixture signal detection model (`msd`)

These models can be fit to empirical data obtain parameter estimates for each model. The toolbox also includes code for parameter recovery similations. 

## Installation

Prerequisites & Included Redistributions:
This toolbox has been developed in Matlab version 2011a and should be compatible with Matlab version 7.10.0.499 (R2009b) and up. You must have the Statistics and Optimization Toolboxes installed with Matlab for the ROC toolbox to function properly. 

The ROC Toolbox includes two code redistributions under the GNU license. The redistributions included in this toolbox are from functions available on the Mathworks File Exchange: (1) loadtxt and sortcell, which can be found on the File Exchange. These functions are necessary for using the roc_import_data function.

Getting the toolbox and adding it to the Matlab path
1) Download a copy of the latest release of ROC Toolbox from:
https://github.com/jdkoen/roc_toolbox/releases

2) Unzip the .zip file to the target directory

3) Use Matlab’s Set Path interface and add the unzipped directory using the “Add with subfolders” option. Make sure to save the updated path.

Alternatively, you can add the following lines to your ‘startup.m’ file:

```matlab
addpath('/path/to/roc_toolbox');
roc_startup;
```

These lines add the path to the ROC toolbox distribution to your Matlab environment, and runs a function named 'roc_startup.m' that will add the necessary directories to your path

You can check to see if the ROC toolbox is in your path by running the following command
	```matlab
  which roc_solver
  ```

To check the version of the ROC Toolbox you are using, run the following command
	```matlab
  roc_version;
  ```

## Tutorials and Documentation

The documentation for the toolbox can accessed [here](ROC_Toolbox_Manual_v1.1.1.pdf).

There are three tutorials provided with the toolbox:
* [Tutorial 1 - Basic Usage](examples/tutorial1_script.m)
* [Tutorial 2 - Advanced Usage](examples/tutorial2_script.m)
* [Tutorial 3 - Importing and Extracting Group Data](examples/tutorial3_script.m)

## Citation

If you find the toolbox useful, please cite the following paper:

Koen, J. D., Barrett, F. S., Harlow, I. M., & Yonelinas, A. P. (2017). The ROC Toolbox: A toolbox for analyzing receiver-operating characteristics derived from confidence ratings. Behavior Research Methods, 49(4), 1399–1406. https://doi.org/10.3758/s13428-016-0796-z
