# Warp CIT168 space to individual space
#
# AUTHOR : Mike Tyszka
# PLACE  : Caltech
# DATES  : 2016-09-30 JMT From scratch

# Subject ID
SID=BG

# Session date
SES=20130326

# UWD amygdala analysis root directory
ROOT_DIR=/Users/jmt/Data/Amygdala/UWD/Structural_Analysis

# Subject/session working directory
WD=$(ROOT_DIR)/$(SID)/$(SES)
PREFIX=$(SID)$(SES)

# Raw T1 and T2 in individual space (from DICOM to Nifti conversion)
IND_T1R=$(PREFIX)_T1w_750um.nii.gz
IND_T2R=$(PREFIX)_T2w_750um.nii.gz

# Individual space images
IND_T1=$(PREFIX)_T1w.nii.gz
IND_T2=$(PREFIX)_T2w.nii.gz
IND_T1_ISO=$(PREFIX)_T1w_iso.nii.gz
IND_T2_ISO=$(PREFIX)_T2w_iso.nii.gz
IND_T2_ALIGNED=$(PREFIX)_T2w_iso_aligned.nii.gz
IND_T1_BRAIN=$(PREFIX)_T1w_brain.nii.gz
IND_T2_BRAIN=$(PREFIX)_T2w_brain.nii.gz
IND_LESION_MASK=$(PREFIX)_lesion_mask.nii.gz
IND_BM=$(PREFIX)_brain_mask.nii.gz
IND_BM_GAUSS=$(PREFIX)_brain_mask_gauss.nii.gz

# Provided by user
LESIONS_IND=$(PREFIX)_Lesions.nii.gz

# T1 and T2 volume crop limits for approx coverage matching
# Use ITK-SNAPs Snake tool to generate ROI bounds
IND_T1_CROP=0 -1 0 -1 8 52 0 -1
IND_T2_CROP=160 192 129 255 8 52 0 -1

# CIT168 atlas templates and prob map
CIT_T1R=$(CIT168_DIR)/CIT168_700um/CIT168_T1w_700um.nii.gz
CIT_T2R=$(CIT168_DIR)/CIT168_700um/CIT168_T2w_700um.nii.gz
CIT_PAMYR=$(CIT168_DIR)/CIT168_700um/CIT168_pAmyNuc_700um.nii.gz

# Crop CIT168 to approximate coverage of individual T1w
CIT_CROP=38 126 52 156 44 68 0 -1
CIT_T1_BRAIN=CIT168_T1w_brain.nii.gz
CIT_T2_BRAIN=CIT168_T2w_brain.nii.gz
CIT_PAMY_BRAIN=CIT168_pAmyNuc_brain.nii.gz
CIT_MASK=CIT168_mask.nii.gz

# SyN warped CIT templates
CIT_T1_SYN=CIT168_T1w_syn.nii.gz
CIT_T2_SYN=CIT168_T2w_syn.nii.gz
CIT_PAMY_SYN=$(PREFIX)_pAmyNuc_syn.nii.gz
SYN_AFFINE=SYN_0GenericAffine.mat
SYN_WARP=SYN_1Warp.nii.gz

# B-spline SyN warped CIT templates
CIT_T1_BSYN=CIT168_T1w_bsyn.nii.gz
CIT_T2_BSYN=CIT168_T2w_bsyn.nii.gz
CIT_PAMY_BSYN=CIT168_pAmyNuc_bsyn.nii.gz
BSYN_AFFINE=BSYN_0GenericAffine.mat
BSYN_WARP=BSYN_1Warp.nii.gz

# Masked B-spline SyN warped CIT templates
CIT_T1_BSYNMASK=CIT168_T1w_bsyn_masked.nii.gz
CIT_T2_BSYNMASK=CIT168_T2w_bsyn_masked.nii.gz
CIT_PAMY_BSYNMASK=CIT168_pAmyNuc_bsyn_masked.nii.gz
BSYNMASK_AFFINE=BSYNMASK_0GenericAffine.mat
BSYNMASK_WARP=BSYNMASK_1Warp.nii.gz

#
# TARGETS
#

all: bsynmask bsyn syn

bsynmask: $(CIT_T1_BSYNMASK) $(CIT_T2_BSYNMASK) $(CIT_PAMY_BSYNMASK)

bsyn: $(CIT_T1_BSYN) $(CIT_T2_BSYN) $(CIT_PAMY_BSYN)

syn: $(CIT_T1_SYN) $(CIT_T2_SYN)

iso: $(IND_T1_ISO) $(IND_T2_ISO)

rigid: $(IND_T2_ALIGNED)

# Crop raw volumes first to remove slab edge effects
$(IND_T1): $(IND_T1R)
	fslroi $(IND_T1R) $(IND_T1) $(IND_T1_CROP)

$(IND_T2): $(IND_T2R)
	fslroi $(IND_T2R) $(IND_T2) $(IND_T2_CROP)

# Resample cropped volumes to isotropic 750 um voxels
# Mask non-brain voxels
$(IND_T1_ISO): $(IND_T1)
	resample $(IND_T1) $(IND_T1_ISO) 0.75

$(IND_T2_ISO): $(IND_T2)
	resample $(IND_T2) $(IND_T2_ISO) 0.75

$(IND_BM_GAUSS): $(IND_BM)
	fslmaths $(IND_BM) -s 1.0 $(IND_BM_GAUSS)

$(IND_T1_BRAIN): $(IND_T1_ISO) $(IND_BM_GAUSS)
	fslmaths $(IND_T1_ISO) -mul $(IND_BM_GAUSS) $(IND_T1_BRAIN)

$(IND_T2_BRAIN): $(IND_T2_ALIGNED) $(IND_BM_GAUSS)
	fslmaths $(IND_T2_ALIGNED) -mul $(IND_BM_GAUSS) $(IND_T2_BRAIN)

# Crop CIT168 templates to approximately same coverage as individual images
$(CIT_T1_BRAIN): $(CIT_T1R)
	fslroi $(CIT_T1R) $(CIT_T1_BRAIN) $(CIT_CROP)

$(CIT_T2_BRAIN): $(CIT_T2R)
	fslroi $(CIT_T2R) $(CIT_T2_BRAIN) $(CIT_CROP)

$(CIT_PAMY_BRAIN): $(CIT_PAMYR)
	fslroi $(CIT_PAMYR) $(CIT_PAMY_BRAIN) $(CIT_CROP)

# ANTs rigid body register individual T2 to T1
$(IND_T2_ALIGNED): $(IND_T1_ISO) $(IND_T2_ISO)
	antsRegistrationSyN.sh -d 3 -m $(IND_T2_ISO) -f $(IND_T1_ISO) -o rigidT2T1_ -n 8 -t r
	mv rigidT2T1_Warped.nii.gz $(IND_T2_ALIGNED)

# ANTs SyN warping of CIT T1,T2 to individual T1,T2
$(CIT_T1_SYN) $(SYN_WARP) $(SYN_AFFINE): $(CIT_T1_BRAIN) $(CIT_T2_BRAIN) $(IND_T1_BRAIN) $(IND_T2_BRAIN) $(CIT_MASK)
	antsRegistrationSyN.sh -d 3 -n 8 -t s -o SYN_ \
	-f $(IND_T1_BRAIN) -f $(IND_T2_BRAIN) -m $(CIT_T1_BRAIN) -m $(CIT_T2_BRAIN)
	mv SYN_Warped.nii.gz $(CIT_T1_SYN)

$(CIT_T2_SYN): $(CIT_T2_BRAIN) $(IND_T1_ISO) $(SYN_WARP) $(SYN_AFFINE)
	WarpImageMultiTransform	3 $(CIT_T2_BRAIN) $(CIT_T2_SYN) -R $(IND_T1_BRAIN) $(SYN_WARP) $(SYN_AFFINE) --use-BSpline

# ANTs b-spline regularized SyN warping of CIT T1,T2 to individual T1,T2
$(CIT_T1_BSYN) $(BSYN_WARP) $(BSYN_AFFINE): $(CIT_T1_BRAIN) $(CIT_T2_BRAIN) $(IND_T1_BRAIN) $(IND_T2_BRAIN) $(CIT_MASK)
	antsRegistrationSyN.sh -d 3 -n 8 -t b -o BSYN_ \
	-f $(IND_T1_BRAIN) -f $(IND_T2_BRAIN) -m $(CIT_T1_BRAIN) -m $(CIT_T2_BRAIN)
	mv BSYN_Warped.nii.gz $(CIT_T1_BSYN)

$(CIT_T2_BSYN): $(CIT_T2_BRAIN) $(IND_T1_BRAIN) $(BSYN_WARP) $(BSYN_AFFINE)
	WarpImageMultiTransform	3 $(CIT_T2_BRAIN) $(CIT_T2_BSYN) -R $(IND_T1_BRAIN) $(BSYN_WARP) $(BSYN_AFFINE) --use-BSpline

# Masked ANTs b-spline regularized SyN warping of CIT T1,T2 to individual T1,T2
$(CIT_T1_BSYNMASK) $(BSYNMASK_WARP) $(BSYNMASK_AFFINE): $(CIT_T1_BRAIN) $(CIT_T2_BRAIN) $(IND_T1_BRAIN) $(IND_T2_BRAIN) $(IND_LESION_MASK) $(CIT_MASK)
	antsRegistrationSyNMask.sh -d 3 -n 8 -t b -o BSYNMASK_ \
	-f $(IND_T1_BRAIN) -f $(IND_T2_BRAIN) -m $(CIT_T1_BRAIN) -m $(CIT_T2_BRAIN) \
	-x $(IND_LESION_MASK) -y $(CIT_MASK)
	mv BSYNMASK_Warped.nii.gz $(CIT_T1_BSYNMASK)

$(CIT_T2_BSYNMASK): $(CIT_T2_BRAIN) $(IND_T1_BRAIN) $(BSYNMASK_WARP) $(BSYNMASK_AFFINE)
	WarpImageMultiTransform 3 $(CIT_T2_BRAIN) $(CIT_T2_BSYNMASK) -R $(IND_T1_BRAIN) $(BSYNMASK_WARP) $(BSYNMASK_AFFINE) --use-BSpline

# Note: for ANTs, the mask is True where the cost function is calculated
$(CIT_MASK): $(CIT_T1_BRAIN)
	fslmaths $(CIT_T1_BRAIN) -thr 0 -bin $(CIT_MASK)

$(IND_LESION_MASK): $(LESIONS_IND)
	fslmaths $(LESIONS_IND) -binv $(IND_LESION_MASK)

$(CIT_PAMY_BSYN): $(CIT_PAMY_BRAIN) $(IND_T1_ISO) $(BSYN_WARP) $(BSYN_AFFINE)
	WarpTimeSeriesImageMultiTransform 4 $(CIT_PAMY_BRAIN) $(CIT_PAMY_BSYN) -R $(IND_T1_BRAIN) $(BSYN_WARP) $(BSYN_AFFINE)

$(CIT_PAMY_BSYNMASK): $(CIT_PAMY_BRAIN) $(IND_T1_ISO) $(BSYNMASK_WARP) $(BSYNMASK_AFFINE)
	WarpTimeSeriesImageMultiTransform 4 $(CIT_PAMY_BRAIN) $(CIT_PAMY_BSYNMASK) -R $(IND_T1_BRAIN) $(BSYNMASK_WARP) $(BSYNMASK_AFFINE)

clean:
	rm -rf SYN_* BSYN_* BSYNMASK_* CIT168_* *_iso* 
