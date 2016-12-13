#!/bin/bash
#
# Perform SyN multimodal warping from individual to template space using joint T1 and T2 cost function
#
# USAGE  : ind2tmp_T1T2 -t1i <individual T1> -t2i <individual T2> -t1t <template T1> -t2t <template T2> -pt <prob atlas>
#
# AUTHOR : Mike Tyszka
# PLACE  : Caltech
# DATES  : 2016-09-30 JMT From scratch
#
# MIT License
#
# Copyright (c) 2016 Mike Tyszka
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:"
	echo "  ind2tmp_T1T2.sh -t1i <img> -t2i <img> -t1t <img> -t2t <img>"
	echo ""
	echo "Arguments:"
	echo "  -t1i : Individual T1w image (3D)"
	echo "  -t2i : Individual T2w image (3D)"
	echo "  -t1t : Template T1w image (3D)"
	echo "  -t2t : Template T2w image (3D)"
	echo "  -pt  : Template probabilistic atlas (4D)"
	echo ""
	echo "All images are Nifti-1 format, compressed or uncompressed"

	exit
fi

while [[ $# -gt 1 ]]
do
	key="$1"

	case $key in
		-t1i)
			T1ind="$2"
			shift
			;;
		-t2i)
			T2ind="$2"
			shift
			;;
		-t1t)
			T1tmp="$2"
			shift
			;;
		-t2t)
			T2tmp="$2"
			shift
			;;
		-pt)
			pAtmp="$2"
			shift
			;;
		*)
			# Unknown option
			;;
	esac

	shift # past argument or value

done

# Splash text
echo "------------------------------------------------------------"
echo " SyN Warp T1 and T2 templates to individual space"
echo "------------------------------------------------------------"
echo "Individual T1 : ${T1ind}"
echo "Individual T2 : ${T2ind}"
echo "  Template T1 : ${T1tmp}"
echo "  Template T2 : ${T2tmp}"
echo "   Prob Atlas : ${pAtmp}"

# Fixed ANTs parameters
nthreads=4

# Registration files
prefix=TMP2IND_
tmp2ind_affine=${prefix}0GenericAffine.txt
tmp2ind_warp=${prefix}1Warp.txt
logfile=${prefix}Warp.log

# Output filenames
T1tmp2ind=T1w_tmp2ind.nii.gz
T2tmp2ind=T2w_tmp2ind.nii.gz
pAtmp2ind=pA_tmp2ind.nii.gz

# Calculate affine and SyN warp
if [ -s ${tmp2ind_warp} ]
then
	antsRegistrationSyN.sh -d 3 -n ${nthreads} -t b -o ${prefix} -f ${T1ind} -f ${T2ind} -m ${T1tmp} -m ${T2tmp} 2>&1 > ${logfile}
fi

# Rename warped template T1
if [ -s ${T1tmp2ind} ]
then
	mv ${prefix}_Warped.nii.gz ${T1tmp2ind}
fi

# Resample template T2 to individual space
if [ -s ${T2tmp2ind} ]
then
	WarpImageMultiTransform	3 ${T2tmp} ${T2tmp2ind} -R ${T1ind} $(tmp2ind_warp) ${tmp2ind_affine} --use-BSpline
fi

# Resample probabilistic atlas to individual space
if [ -s ${pAtmp2ind} ]
then
	WarpImageMultiTransform	3 ${pAtmp} ${pAtmp2ind} -R ${T1ind} $(tmp2ind_warp) ${tmp2ind_affine} --use-BSpline
fi

# Report output filenames
echo "------------------------------------------------------------"
echo " Output files"
echo "------------------------------------------------------------"
echo "Template T1 in individual space : ${T1tmp2ind}"
echo "Template T2 in individual space : ${T2tmp2ind}"
echo "Prob atlas in individual space  : ${pAtmp2ind}"
