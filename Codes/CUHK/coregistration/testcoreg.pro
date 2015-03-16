PRO TESTCOREG
  FOR i=0,4 DO BEGIN
    master= 'D:\ISEIS\Data\Img\ASAR-20070726.slc'
    slave= 'D:\ISEIS\Data\Img\ASAR-20060601.slc'
    s_offset=17
    l_offset=12
    MNS=5195
    MNL=27313
    SNS=5195
    SNL=27316
    c_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.coff'+STRCOMPRESS(i)
    off_outfile = FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.coff.pts'+STRCOMPRESS(i)
    outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(slave, '.slc')+'.rslc'+STRCOMPRESS(i)
    CASE i OF
      0: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=200,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls1,ccp_s=17,ccp_l=17)
        f_offset= c_outfile      
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      1: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=400,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls1,ccp_s=17,ccp_l=17)
        f_offset= c_outfile
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      2: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=600,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls1,ccp_s=17,ccp_l=17)
        f_offset= c_outfile      
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      3: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=200,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls2,ccp_s=17,ccp_l=17)
        f_offset= c_outfile      
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      4: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=400,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls2,ccp_s=17,ccp_l=17)
        f_offset= c_outfile      
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      5: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=200,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls1,ccp_s=37,ccp_l=37)
        f_offset= c_outfile      
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      6: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=200,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls1,ccp_s=44,ccp_l=44)
        f_offset= c_outfile
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      7: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=800,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls1,ccp_s=44,ccp_l=44)
        f_offset= c_outfile
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      8: BEGIN
        result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                              winsearch=30,winsub=800,mns=MNS, mnl=MNL, $
                              sns=SNS, snl=SNL,/ls2,ccp_s=44,ccp_l=44)
        f_offset= c_outfile
        result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL)
      END
      else:
    ENDCASE
  ENDFOR                          
END