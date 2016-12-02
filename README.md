# citatlaskit
Tools for applying the CIT168 atlas to individual MRI data

## Introduction
The bash scripts provided here are wrappers for a combination of FSL and ANTs commands which map individual T1w and/or T2w structural images to most high SNR midspace templates, including MNI/ICBM152 and CIT168/HCP.

## Requirements
The bash scripts were developed for FSL 5.0.9 and ANTs 2.1.0, both of which are the latest versions at the time of writing. Original development was under MacOS 10.12 (Sierra), but they should work fine under most Linux and Unix variants. The FSL source and binaries for several common platforms can be downloaded from https://fsl.fmrib.ox.ac.uk/fsldownloads/fsldownloadmain.html. The ANTs git repository can be cloned from https://github.com/stnava/ANTs and compiled using CMake.

## Registering the CIT168 atlas to individual T1w structural images


## Registering the CIT168 atlas to individual T1w and T2w image pairs
The CIT168 atlas supplies a T1w and T2w template pair which are in the same space. If you have both T1w and T2w 3D structural images for individual patients or participants, information from both contrasts can be used to determine an optimal mapping from template to individual spaces.
