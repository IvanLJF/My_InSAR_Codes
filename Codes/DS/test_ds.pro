PRO TEST_DS

  workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen/'
  dspath=workpath+'DS_20/'
  logfile=dspath+'log.txt'
  dslkupfile=dspath+'dsc.lookup'
  dsmaskfile=dspath+'dsc.mask'
  start_sectionfile=dspath+'start_section'
  end_sectionfile=dspath+'end_section'
  dslistfile=dspath+'dsclist'
  imlistfile=workpath+'im_list'
  piecepath=workpath+'piece/'
  diffpath=workpath+'diff_all/'
  itabfile=workpath+'itab'
  sarlistfile=workpath+'SLC_tab'
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  
  masterfile=piecepath+'20091113.rslc'
  slavefile=piecepath+'20090327.rslc'
  master=TLI_READDATA(masterfile, samples=finfo.range_samples, format=finfo.image_format,/swap_endian)
  slave=TLI_READDATA(slavefile, samples=finfo.range_samples, format=finfo.image_format,/swap_endian)
  
  intfile=master*CONJ(slave)
  
inputfile=temp.mli
format='float'


inputfile=temp.slc
format='fcomplex'
tli_ds_filter,inputfile, dspath, outputfile=outputfile, logfile=logfile, discard_nonds=discard_nonds, $
    samples=samples, lines=lines, format=format, swap_endian=swap_endian

END