#!/bin/bash

##
## Files should have 
##               $master.mli   &   $master.mli.par
##               $dem.dem      &   $dem.dem.par
##
## Function: geocode mli to UTM


master=20090725roi
slave=20091003roi
dem=hanyuan
lat_ovr=2
lon_ovr=2

echo "master= $master.mli"
echo "slave= $slave.mli"
echo "dem= $dem.dem"
echo "lat_ovr= $lat_ovr"
echo "lon_ovr= $lon_ovr"
echo "please check the inputs..."

stopPoint

mkdir $master
cd $master
echo "gc_map ../$master.mli.par - ../$dem.dem.par ../$dem.dem seg_dem.par seg.dem $master.lt $lat_ovr $lon_ovr sim_sar_UTM - - - - pix ls_map 6"
gc_map ../$master.mli.par - ../$dem.dem.par ../$dem.dem seg_dem.par seg.dem $master.lt $lat_ovr $lon_ovr sim_sar_UTM - - - - pix ls_map 6


seg_dem_width=`awk '$1 == "width:" {print $2}' seg_dem.par`
seg_dem_lines=`awk '$1 == "nlines:" {print $2}' seg_dem.par`
mli_width=`awk '$1 == "range_samples:" {print $2}' ../$master.mli.par`
mli_lines=`awk '$1 == "azimuth_lines:" {print $2}' ../$master.mli.par`

echo "seg_dem_width: $seg_dem_width"
echo "seg_dem_lines: $seg_dem_lines"
echo "mli_width: $mli_width"
echo "mli_lines: $mli_lines"
echo ""
echo "geocode $master.lt sim_sar_UTM $seg_dem_width sim_sar_RDC $mli_width $mli_lines 1 0"
geocode $master.lt sim_sar_UTM $seg_dem_width sim_sar_RDC $mli_width $mli_lines 1 0

stopPoint

#20090725roi.lt  查找表
#sim_sar_UTM     UTM坐标系下的模拟SAR强度图（dispwr查看）
#sim_sar_RDC     RDC雷达坐标系下的模拟强度图（1000*1000大小，插值到影像空间）

echo 'Interf_processing' > create_offset.in
  echo '' >> create_offset.in
  echo '' >> create_offset.in
  echo '' >> create_offset.in
  echo '' >> create_offset.in
  echo '' >> create_offset.in


echo "create_diff_par ../$master.mli.par - $master.diff_par 1"
create_diff_par ../$master.mli.par - $master.diff_par 1 < create_offset.in

echo "init_offsetm sim_sar_RDC ../$master.mli $master.diff_par"
init_offsetm sim_sar_RDC ../$master.mli $master.diff_par

echo "offset_pwrm sim_sar_RDC ../$master.mli $master.diff_par diff.offs diff.snr 256 256 diff.offsets 1 40 40 9"
offset_pwrm sim_sar_RDC ../$master.mli $master.diff_par diff.offs diff.snr 256 256 diff.offsets 1 40 40 9

echo "offset_fitm diff.offs diff.snr $master.diff_par diff.coffs diff.coffsets 10 6 > diff_offset_std.txt"
offset_fitm diff.offs diff.snr $master.diff_par diff.coffs diff.coffsets 10 6 > diff_offset_std.txt

echo "Stop here and check the diff_offset_std.txt"
final_std=`grep 'final model fit std. dev. (samples) range:' diff_offset_std.txt`
echo $final_std
stopPoint

echo "delete temp files"
echo "rm diff.offs diff.snr diff.coffs diff.coffsets diff.offsets"
rm diff.offs diff.snr diff.coffs diff.coffsets diff.offsets

echo "gc_map_fine $master.lt $seg_dem_width $master.diff_par $master.refined.lt 1"
gc_map_fine $master.lt $seg_dem_width $master.diff_par $master.refined.lt 1

#精化查找表
echo "geocode $master.refined.lt sim_sar_UTM $seg_dem_width sim_sar_refined_RDC $mli_width $mli_lines 1 0"
geocode $master.refined.lt sim_sar_UTM $seg_dem_width sim_sar_refined_RDC $mli_width $mli_lines 1 0

echo "geocode_back ../$master.mli $mli_width $master.refined.lt $master.UTM.mli $seg_dem_width - 2 0"
geocode_back ../$master.mli $mli_width $master.refined.lt $master.UTM.mli $seg_dem_width - 2 0

raspwr $master.UTM.mli $seg_dem_width 1 0 1 1 1. .35 1 $master.UTM.mli.ras
xv $master.UTM.mli.ras
#dishgt seg.dem 20090725roi.UTM.mli 1328

echo "End of $master geocode work"
echo "Using the same look up table as the $master in $slave"
cd ..
mkdir $slave
cd $slave
geocode_back ../$slave.mli $mli_width ../$master/$master.refined.lt $slave.UTM.mli $seg_dem_width - 2 0
raspwr $slave.UTM.mli $seg_dem_width 1 0 1 1 1. .35 1 $slave.UTM.mli.ras
xv $slave.UTM.mli.ras

cd ..
dis2pwr $master/$master.UTM.mli $slave/$slave.UTM.mli $seg_dem_width $seg_dem_width
