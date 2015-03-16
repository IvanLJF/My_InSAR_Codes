@tli_plot_linear_def_gamma
Pro TestGoogleEarth


  workpath='/mnt/data_tli/ForExperiment/Lemon_gg/TSX_PS_SH_OP/'
  geocodepath=workpath
  
  plistfile_gamma=geocodepath+'plistupdate_gamma'
  vdhfile=workpath+'HPA/vdh'

  
  pmapllfile=plistfile_gamma+'.ll'
  kmlfile=plistfile_gamma+'.kml'
  phgtfile=geocodepath+'pdem'
  vacuate=1
  npt_final=9000
  
;  minv=-34
;  maxv=0
;  cptfile=geocodepath+'g.cpt'
  colortable_name='tli_def'
  colorbarfile=geocodepath+'colorbar_tli_def.jpg'
  TLI_DEFINGOOGLE,pmapllfile, vdhfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
    maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
    refine_data=refine_data,delta=delta,refined_data=refined_data,/randomu, cptfile=cptfile,colorbarfile=colorbarfile
END