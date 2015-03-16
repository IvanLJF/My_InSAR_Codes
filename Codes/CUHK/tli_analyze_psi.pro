PRO TLI_ANALYZE_PSI
  
  resultpath='/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Kowloon/testforCUHK'
  vdhfile= resultpath+'/vdh'
  
  vdh= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
  
  v_max= MAX(vdh[4, *], v_ind)
  Print, 'Max v:', v_max, 'index & (x, y):', vdh[0:2, v_ind]
  
  v_min= MIN(vdh[4, *], v_ind)
  Print, 'Min v:', v_min, 'index & (x, y):', vdh[0:2, v_ind]

END