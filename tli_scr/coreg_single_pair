#!/bin/sh
###########################################################
# Script that:
# 	Co-regitster two image
# Usage:
# 	./run_coreg.sh master slave
# Written by:
# 	T.LI @ISEIS

# Check input params
if [ $# -ne 2 ]
then 
    echo "*** Do co-registration for two images.***"
    echo ""
    echo "Usage: ./coreg_single_pair.sh <master> <slave>"
    echo " "
    echo "input parameters:"
    echo "  master     master date(yyyymmdd)"
    echo "  slave      slave date(yyyymmdd)"
    echo " "
    exit 0
fi


######################################
### parameter files
######################################
MASTER=$1
SLAVE=$2
M_P=${MASTER}
S_P=${SLAVE}
m_slc=../../slc_GAMMA/$M_P.slc
s_slc=../../slc_GAMMA/$S_P.slc
par_m=../../slc_GAMMA/$M_P.slc.par
par_s=../../slc_GAMMA/$S_P.slc.par
MS_off=$M_P-$S_P.off
npoly=3
width=$(awk '$1 == "range_samples:" {print $2}' $par_m)
######################################
###create the ISP processing/offset parameter file from MSP processing parameter and sensor files
######################################
#par_MSP ../$M_P/palsar.par ../$M_P/p$par_m $par_m
#par_MSP ../$S_P/palsar.par ../$S_P/p$par_s $par_s
######################################
###Supports interactive creation of offset/processing parameter file for generation of interferograms
###create_offset reads the SLC parameter files and queries the user for parameters(write into the .off file) required to calculate the offsets 
###using either the cross correlation of intensity or fringe visibility algorithms
### a. scence title: interferogram parameters
### b. range,azimuth offsets of SLC-2 relative to SLC-1(SLC samples):0 0
### c. enter number of offset measurements in range, azimuth: 32 32
### e. search window sizes(range, azimuth, nominal: 64 64)
### f. low correlation SNR threshold for intensity cross correlation 7.0
### g. offset in range to first interfergram sample 0
### h. width of SLCsection to processes (width of SLC-1)
######################################
echo -ne "$M_P-$S_P\n 0 0\n 32 32\n 64 64\n 7.0\n 0\n\n" > create_offset
######################################
create_offset $par_m $par_s $MS_off 1 1 1 <create_offset
rm -f create_offset

######################################
###first guess of the offsets can be obtained based on orbital information
###The position of the initial registration offset estimation can be indicated. As default the SLC-1 image center is used.
######################################
init_offset_orbit $par_m $par_s $MS_off
######################################
###improve the first guess, determines the initial offsets based on the cross-correlation function of the image intensities
###In order to avoid ambiguity problems and achieve an accutare estimates init_offset first be run with multi-looking
###followed by a second run at single look resolution
######################################
init_offset $m_slc $s_slc $par_m $par_s $MS_off 5 5
init_offset $m_slc $s_slc $par_m $par_s $MS_off 3 3
######################################
###the first time offset_pwr and offset_fit, Estimation of offsets 
###first time with larger windowsize
###offset_pwr estimates the range and azimuth registration offset fields using correlation optimization of the detected SLC data
######################################
offset_pwr $m_slc $s_slc $par_m $par_s $MS_off $M_P-$S_P.offs $M_P-$S_P.off.snr 128 128 $M_P-$S_P.offsets 1 - - 7.0 1

######################################
######determine the bilinear registration offset polynomial using a least squares error method
###offset_fit computes range and azimuth registration offset polynomials from offsets estimated by one of the programs offset_pwr
######################################
offset_fit $M_P-$S_P.offs $M_P-$S_P.off.snr $MS_off $M_P-$S_P.coffs $M_P-$S_P.coffsets 10.0 $npoly 0
cp $M_P-$S_P.offsets offsets_pwr_1
cp $M_P-$S_P.coffsets coffsets_pwr_1
rm -f $M_P-$S_P.offs $M_P-$S_P.off.snr $M_P-$S_P.coffs $M_P-$S_P.coffsets $M_P-$S_P.offsets 

######################################
#######the 2nd-time offset_pwr and offset_fit(with smaller windowsize)
######################################
offset_pwr $m_slc $s_slc $par_m $par_s $MS_off $M_P-$S_P.offs $M_P-$S_P.off.snr 128 128 $M_P-$S_P.offsets 1 - - 8.0 1
offset_fit $M_P-$S_P.offs $M_P-$S_P.off.snr $MS_off $M_P-$S_P.coffs $M_P-$S_P.coffsets 15.0 $npoly 0
cp $M_P-$S_P.offsets offsets_pwr_2
cp $M_P-$S_P.coffsets coffsets_pwr_2
rm -f $M_P-$S_P.offs $M_P-$S_P.off.snr $M_P-$S_P.coffs $M_P-$S_P.coffsets $M_P-$S_P.offsets

######################################
###Estimates range and azimuth offset fields of a pair of SLC in support of image co-registration and offset tracking
######################################
offset_pwr_tracking $m_slc $s_slc $par_m $par_s $MS_off $M_P-$S_P.offs $M_P-$S_P.off.snr 32 32 $M_P-$S_P.offsets 2 9.0 40 40 - - - - 1
offset_fit $M_P-$S_P.offs $M_P-$S_P.off.snr $MS_off $M_P-$S_P.coffs $M_P-$S_P.coffsets 20.0 $npoly 0
SLC_interp $s_slc $par_m $par_s $MS_off $S_P.rslc $S_P.rslc.par
SLC_intf $m_slc $S_P.rslc $par_m $S_P.rslc.par $MS_off $M_P-$S_P.int 1 1 - - 1 1
rasmph *.int $width - - - - - - - int.ras 0
rasSLC $S_P.rslc $width - - 10 10 - - - 1 - $S_P.rslc.ras

