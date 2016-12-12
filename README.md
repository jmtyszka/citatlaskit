# citatlaskit
Tools for applying the CIT168 atlas to individual MRI data

## Introduction
The bash scripts provided here are wrappers for a combination of FSL and ANTs commands which map individual T1w and/or T2w structural images to most high SNR midspace templates, including MNI/ICBM152 and CIT168/HCP.

## Requirements
These bash scripts wrap ANTs and FSL commands and provide a convenient starting point for registering the CIT168 atlas (or any atlas for that matter) to an individual space. The original script development was under MacOS 10.12 (Sierra), but they should work fine under most Linux and Unix variants.

| Software | Description | Version | Link |
| :------- | :---------- | :------ | :--- |
| FSL      | Neuroimaging analysis | 5.0.8+ | https://fsl.fmrib.ox.ac.uk |
| ANTs     | Image warp registration | 2+ | https://github.com/stnava/ANTs |
| CIT168   | Templates and amygdala atlas | 1.0.1+ | http://evendim.caltech.edu/amygdala-atlas/ |

## Registering the CIT168 atlas to individual T1w structural images
The acquisition of both high resolution T1w and T2w structural images has become routine, but many legacy datasets include only 1 mm isotropic T1w structural images. Use the tmp2ind_T1.sh script to register the CIT168 atlas into the individual T1w space.

## Registering the CIT168 atlas to individual T1w and T2w image pairs
The CIT168 atlas supplies a T1w and T2w template pair which are in the same space. If you have both T1w and T2w 3D structural images for individual patients or participants, information from both contrasts can be used to determine an optimal mapping from template to individual spaces. Use the tmp2ind_T1T2.sh script to register the CIT168 atlas to individual space using both T1w and T2w information (joint cost function).
