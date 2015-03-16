PRO TLI_TEST_DISPLAY

   baselistfile='/mnt/ihiusa/mydata_TLI/chenfulong/PSI_TLI/base.list'
   outputfile=baselistfile+'.jpg'
   tbaseline=0
   TLI_PLOT_BASELINES, baselistfile, outputfile=outputfile, tbaseline=tbaseline

END