#!/bin/bash
#++++++++++++++++++++++++++++++++++++++++++++++++++
# Author: Ruya XIAO
# Version: 1.1/Oct 2014
# E-mail: ruya.xiao@gmail.com
#++++++++++++++++++++++++++++++++++++++++++++++++++

#coreg & resample


curDir=`pwd`
DEM=hanyuan
master=20090725
slave=20091003
rlks=1
azlks=5
pair="${master}_${slave}"

echo 'Interf_processing' > create_offset.in
  echo '' >> create_offset.in
  echo '' >> create_offset.in
  echo '' >> create_offset.in
  echo '' >> create_offset.in
  echo '' >> create_offset.in

echo "create_offset $master.slc.par $slave.slc.par $pair.off 1"
create_offset $master.slc.par $slave.slc.par $pair.off 1 < create_offset.in

echo "init_offset_orbit $master.slc.par $slave.slc.par $pair.off"
init_offset_orbit $master.slc.par $slave.slc.par $pair.off 

vi $pair.off
echo "check the $pair.off file..."
stopPoint

echo "(first time)offset_pwr $master.slc $slave.slc $master.slc.par $slave.slc.par $pair.off $pair.offs $pair.snr 256 512 $pair.offsets 1 80 80 9"
echo "(first time)offset_fit $pair.offs $pair.snr $pair.off $pair.coffs $pair.coffsets 10 6"

offset_pwr $master.slc $slave.slc $master.slc.par $slave.slc.par $pair.off $pair.offs $pair.snr 256 512 $pair.offsets 1 80 80 9
offset_fit $pair.offs $pair.snr $pair.off $pair.coffs $pair.coffsets 10 6 > Interf.offset_fit

echo "Stop here and check the Interf.offset_fit"
final_std=`grep 'final model fit std. dev. (samples) range:' Interf.offset_fit`
echo $final_std

stopPoint

echo "SLC_interp $slave.slc $master.slc.par $slave.slc.par $pair.off $slave.rslc $slave.rslc.par"
SLC_interp $slave.slc $master.slc.par $slave.slc.par $pair.off $slave.rslc $slave.rslc.par


echo "multi_look $slave.rslc $slave.rslc.par $slave.mli $slave.mli.par $rlks $azlks"
multi_look $slave.rslc $slave.rslc.par $slave.rmli $slave.rmli.par $rlks $azlks

resampled_width=`awk '$1 == "range_samples:" {print $2}' $master.mli.par`


echo "dis2pwr $master.mli $slave.rmli $resampled_width $resampled_width"
echo "find out the region of interests (width and lines)..."

dis2pwr $master.mli $slave.rmli $resampled_width $resampled_width

#划定roi感兴趣区域(1000*5000)
#SLC_copy 20090725.slc 20090725.slc.par 20090725roi.slc 20090725roi.slc.par - - 801 1000 22501 5000
#SLC_copy 20091003.slc 20091003.slc.par 20091003roi.slc 20091003roi.slc.par - - 801 1000 22501 5000
#multi_look 20090725roi.slc 20090725roi.slc.par 20090725roi.mli 20090725roi.mli.par 1 5
#multi_look 20091003roi.slc 20091003roi.slc.par 20091003roi.mli 20091003roi.mli.par 1 5
