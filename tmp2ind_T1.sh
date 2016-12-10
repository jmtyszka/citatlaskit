#!/bin/bash
#
# Perform SyN warping from individual to template space using T1 cost function
#
# USAGE  : ind2tmp_T1 -t1i <individual T1> -t1t <template T1> -pt <prob atlas>
#
# AUTHOR : Mike Tyszka
# PLACE  : Caltech
# DATES  : 2016-09-30 JMT From scratch
#          2016-12-09 JMT Adapt joint warp for T1-only warping

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:"
	echo "  ind2tmp_T1T2.sh -t1i <img> -t1t <img> -pt <img>"
	echo ""
	echo "Arguments:"
	echo "  -t1i : Individual T1w image (3D)"
	echo "  -t1t : Template T1w image (3D)"
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

		-t1t)
			T1tmp="$2"
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
echo " SyN Warp T1 template to individual space"
echo "------------------------------------------------------------"
echo "Individual T1 : ${T1ind}"
echo "  Template T1 : ${T1tmp}"
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
pAtmp2ind=pA_tmp2ind.nii.gz

# Calculate affine and SyN warp
if [ -s ${tmp2ind_warp} ]
then
	antsRegistrationSyN.sh -d 3 -n ${nthreads} -t b -o ${prefix} -f ${T1ind} -m ${T1tmp} 2>&1 > ${logfile}
fi

# Rename warped template T1
if [ -s ${T1tmp2ind} ]
then
	mv ${prefix}_Warped.nii.gz ${T1tmp2ind}
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
echo "Prob atlas in individual space  : ${pAtmp2ind}"
