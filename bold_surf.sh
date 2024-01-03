#! /bin/bash 

# Vol2Surf Script

# Map volumetric data to surface space 

# Author: Raven

# Email: qiaokn123@163.com

# Date: December 29, 2023

# Print usage

Usage() {
  cat <<USAGE 

Usage: 

$(basename $0) -i bold_vol -o out_dir -s fsaverage -r bbregister.dat -t T1OUTDIR

Required:

-i BOLD volume 

-o Output directory

-s Fsaverage subject

-r BBRegister registration

-t T1OUTDIR

USAGE

  exit 1
}

# Parse arguments

if [ $# -lt 5 ]; then
  Usage 
fi

while getopts "i:o:s:r:t:" opt; do
  case $opt in
    i) BOLDVOL=$OPTARG;;
    o) OUTDIR=$OPTARG;;
    s) FSAVERAGE=$OPTARG;;
    r) REG=$OPTARG;;
    t) T1OUTDIR=$OPTARG;;
    \?) Usage;;
  esac
done

# Map volume -> surface

echo "Mapping volume to $FSAVERAGE surface..."

# Surfaces 

SURF_DIR=${OUTDIR}
BOLDOUTDIR=$( dirname $OUTDIR )

mkdir -p $SURF_DIR

cd $SURF_DIR

# Link fsaverage subject

ln -s $FREESURFER_HOME/subjects/fsaverage 

ln -s $T1OUTDIR/freesurfer 

# Map volume to surface

for hemi in lh rh; do
    mri_vol2surf --o $SURF_DIR/${hemi}.fsaverage.nii.gz --hemi $hemi --src $BOLDVOL --reg $REG --sd $SURF_DIR --interp trilin --projfrac 0.5 --surf white --trgsubject fsaverage --noreshape --cortex --surfreg sphere.reg
done

# down-sample to ${FSAVERAGE}

FSAVERAGE_DIR=$SURF_DIR/$FSAVERAGE

ln -s $FREESURFER_HOME/subjects/$FSAVERAGE $FSAVERAGE_DIR

for hemi in lh rh; do
    # Mapping from fsaverage -> fsaverage5/6
    mri_surf2surf --hemi $hemi --srcsubject fsaverage --sval $SURF_DIR/${hemi}.fsaverage.nii.gz --trgsubject ${FSAVERAGE} --tval $SURF_DIR/${hemi}.${FSAVERAGE}.nii.gz --sd $SURF_DIR --cortex 
done
