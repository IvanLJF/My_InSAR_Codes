PRO TLI_ALL_MY_KML
  
   shanghai_tsx_par='/mnt/data_tli/Data/SLCs/TSX_SH_Coregto20090920/20090920-20090920/20090920.rslc.par'
   tianjin_tsx_par='/mnt/data_tli/Data/SLCs/TSX_TJ_Coregto20091113/20091113-20091113/20091113.rslc.par'
   hk_envisat_par='/mnt/data_tli/Data/SLCs/ENVISAT_HK/20041014.slc.par'
   angkor_tsx_par='/mnt/data_tli/Data/SLCs/TSX_Angkor/20130510.slc.par'
   
   tianjin_palsar_par1='/mnt/ihiusa/Software/Data/Original_Data/PALSAR_jinghu_Original/447_74_slc_org/20091025.slc.par'
   tianjin_palsar_par2='/mnt/data_tli/Data/SLCs/PALSAR_Jinghu/447_77/20081022.slc.par'
   tianjin_palsar_par3='/mnt/data_tli/Data/SLCs/PALSAR_Jinghu/448_79/20080923.slc.par'
   
   
   hk_cosmo_par='it determines.'
   hk_tsx_par='it determines.'
   
   
   resultpath='/mnt/data_tli/kml/'
   TLI_SLC_RANGE, shanghai_tsx_par, outputfile=resultpath+'Shanghai_tsx.kml', annotation='No. of images: 18.'
   TLI_SLC_RANGE, tianjin_tsx_par, outputfile=resultpath+'Tianjin_tsx.kml', annotation='No. of images: 40.'
   TLI_SLC_Range, hk_envisat_par, outputfile=resultpath+'HK_envisat.kml', annotation='No. of images: 44.'
   TLI_SLC_RANGE, angkor_tsx_par, outputfile=resultpath+'Angkor_tsx.kml', annotation='No. of images: 42.'+STRING(13b)+STRING(13b)+$
                  "Images are from: Chen Fulong, Institute of Remote Sensing and Digital Earth, CAS."
   
   
   TLI_SLC_RANGE, tianjin_palsar_par1, outputfile=resultpath+'Tianjin_palsar_447_74.kml', annotation='No. of images: 16.'
   TLI_SLC_RANGE, tianjin_palsar_par2, outputfile=resultpath+'Tianjin_palsar_447_77.kml', annotation='No. of images: 17.'
   TLI_SLC_RANGE, tianjin_palsar_par3, outputfile=resultpath+'Tianjin_palsar_448_79.kml', annotation='No. of images: 7.'
   
   TLI_SLC_RANGE, hk_tsx_par, outputfile=resultpath+'hk_tsx.kml', annotation='No. of images: '
   
   
END