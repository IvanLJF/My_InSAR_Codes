PRO TEST_YATOU

Print, SOURCEROOT()
  a=[5.0825, 4.2844, 0.3475, 0.2172, 0.1694]
  b=[15.0818, 5.8886, 0.0992, 0.3286, 1.1428]
  mean_err= MEAN(ABS(b-a))
  Print, 'Mean error:', mean_err
  
  Print, 'Sdandard error:', SQRT(TOTAL((b-a)^2)/5)
END
