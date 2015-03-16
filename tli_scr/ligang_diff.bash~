#!/bin/bash
if false; then
#from interferogram
create_offset 20120228.slc.par 20120229.slc.par 0228_0229.off 1
SLC_intf 20120228.slc 20120229.slc 20120228.slc.par 20120229.slc.par 0228_0229.off 0228_0229.int 5 7 - - - -
multi_look 20120228.slc 20120228.slc.par 20120228.mli 20120228.mli.par 5 7
rasmph_pwr 0228_0229.int 20120228.mli 3311 1 1 0 1 1 - - - 0228_0229.int.bmp
base_orbit 20120228.slc.par 20120229.slc.par 0228_0229.base
base_perp 0228_0229.base 20120228.slc.par 0228_0229.off
fi 
#simulate sar image, lookup table, crop dem
gc_map 20120228.mli.par - shuanghu_ovs_swap.par shuanghu_ovs_swap seg.dem.par seg.dem dem_WGS_2_RDC.lt 4 4 wgs.sim.sar
rasshd seg.dem 6888 25 25 1 0 1 1 - - - seg.dem.bmp
rasmph dem_WGS_2_RDC.lt 6888 1 0 - - - - - dem_WGS_2_RDC.lt.bmp
raspwr wgs.sim.sar 6888 1 0 1 1 - - - wgs.sim.sar.bmp

#coregister simulated sar to TSX image, then refine lookup table
geocode dem_WGS_2_RDC.lt wgs.sim.sar 6888 sim.sar 3311 4341 1 0
raspwr sim.sar 3311 1 0 1 1 - - - sim.sar.bmp
create_diff_par 20120228.mli.par - 0228_DEMSim.diff.par 1
init_offsetm sim.sar 20120228.mli 0228_DEMSim.diff.par 1 1
offset_pwrm sim.sar 20120228.mli 0228_DEMSim.diff.par doffs dsnr 256 256 doffsets 2 24 24 9
offset_fitm doffs dsnr 0228_DEMSim.diff.par dcoffs dcoffsets 9 4
gc_map_fine dem_WGS_2_RDC.lt 6888 0228_DEMSim.diff.par dem_WGS_2_RDC-fine.lt 1
geocode_back 20120228.mli 3311 dem_WGS_2_RDC-fine.lt 20120228.wgs.mli 6888 8060 2 0
geocode dem_WGS_2_RDC-fine.lt seg.dem 6888 dem.hgt 3311 4341 1 0
rashgt dem.hgt 20120228.mli 3311 1 1 0 1 1 200 - - - dem.hgt.bmp
raspwr 20120228.wgs.mli 6888 1 0 1 1 - - - 20120228.wgs.mli.bmp

#simulate flat earth and topographic phase
phase_sim 20120228.slc.par 0228_0229.off 0228_0229.base dem.hgt dem.sim.unw 0 0 - - 0
rasrmg dem.sim.unw - 3311 - - - - - 1 - - - - dem.sim.unw.bmp

#differential processing
sub_phase 0228_0229.int dem.sim.unw 0228_DEMSim.diff.par 0228_0229.diff.int 1 0
rasmph_pwr 0228_0229.diff.int 20120228.mli 3311 1 1 0 1 1 - - 1 0228_0229.diff.int.bmp

#orbit error estimation
base_init 20120228.slc.par 20120229.slc.par 0228_0229.off 0228_0229.diff.int 0228_0229.base_res 4
base_add 0228_0229.base 0228_0229.base_res 0228_0229.base1 1
base_add 0228_0229.base1 0228_0229.base_res 0228_0229.base2 1
phase_sim 20120228.slc.par 0228_0229.off 0228_0229.base2 dem.hgt dem.sim.unw2 0 0 - - 0
sub_phase 0228_0229.int dem.sim.unw2 0228_DEMSim.diff.par 0228_0229.diff.int2 1 0
rasmph_pwr 0228_0229.diff.int2 20120228.mli 3311 1 1 0 1 1 - - 1 0228_0229.diff.int2.bmp

#unwrapping
tli_unwrap 0228.rslc 0229.rslc 0228_0229.diff.int2 3 1 
if false; then
adf 0228_0229.diff.int2 0228_0229.diff.int2.sm 0228_0229.diff.int2.smcc 3311 - - 7 8 0 0 0.25
rasmph_pwr 0228_0229.diff.int2.sm 20120228.mli 3311 1 1 0 1 1 - - 1 0228_0229.diff.int2.sm.bmp
rascc_mask 0228_0229.diff.int2.smcc 20120228.mli 3311 1 1 0 1 1 0.5 - 0.1 0.9 1 0.35 1 0228_0229.diff.int2.mask.ras
mcf 0228_0229.diff.int2.sm 0228_0229.diff.int2.smcc 0228_0229.diff.int2.mask.ras 0228_0229.diff.int2.sm.unw 3311 1 0 0 - - 1 1 - - - 1
rasrmg 0228_0229.diff.int2.sm.unw 20120228.mli 3311 1 1 0 1 1 0.5 - - - - 0228_0229.diff.int2.sm.unw.bmp
fi 
mv 
geocode_back 0228_0229.diff.int2.sm.unw 3311 dem_WGS_2_RDC-fine.lt 0228_0229.diff.int2.sm.wgs.unw 6888 8060 1 0


#transfer unwrapped image to height
#have to edit base2 file
hgt_map 0228_0229.diff.int2.sm.unw 20120228.slc.par 0228_0229.off 0228_0229.base2 0228_0229.hgt 0228_0229.grd
rashgt 0228_0229.hgt 20120228.mli 3311 1 1 0 1 1 20 - - - 0228_0229.hgt.bmp
geocode_back 0228_0229.hgt 3311 dem_WGS_2_RDC-fine.lt 0228_0229.wgs.hgt 6888 8060 1 0
rashgt 0228_0229.wgs.hgt 20120228.wgs.mli 6888 1 1 0 1 1 20 - - - 0228_0229.wgs.hgt.bmp


