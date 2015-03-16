;+ 
; Name:
;    TLI_POLYFIT
; Purpose:
;    Do Poly fit in 2-D .
; Calling Sequence:
;    Result= TLI_POLYFIT(offsets, degree=degree)
; Inputs:
;    offsets        :  Offsets of each points. contains 5 columns:[Master_x, Master_y, Slave_x, Slave_y, coefficients]
; Keyword Input Parameters:
;    Degree         :  Degree of Polynomia. Omitted is 1.
; Outputs:
;    Coefficients.6 columns * 2lines.
; Commendations:
;    None.
; Example:
;    offsetsfile='D:\ISEIS\Data\Img\'
; Modification History:
;    05/07/2012        : Written by T.Li @ InSAR Team in SWJTU & CUHK
;    02/12/2013        : Delete the backup option for input offsets.
;- 

Function TLI_POLYFIT, offsets, degree=degree
  
  COMPILE_OPT idl2
  
  sz= SIZE(offsets,/DIMENSIONS)
  IF sz[0] NE 5 THEN BEGIN
    Message, 'Result must contain 5 columns!'
  ENDIF
  
  IF ~N_elements(degree) Then degree=1
  
  IF degree GE 3 THEN Message, 'Degree of greater than 3 is not supported!'
  master_s= offsets[0, *]; 主影像列坐标
  master_l = offsets[1, *]; 主影像行坐标
  slave_s = offsets[2, *]; 从影像列坐标
  slave_l= offsets[3, *]; 主影像行坐标
  cc = offsets[4, *];相关系数
  ;Least squares
  ; Ss= ca0+ca1*Ms+ca2*Ml+ca3*Ms*Ml+ca4*Ms^2+ca5*Ml^2
  ; Sl= ca0'+ca1'*Ms+ca2'*Ml+ca3'*Ms*Ml+ca4'*Ms^2+ca5'*Ml^2
  ca0= REPLICATE(1, 1, SIZE(master_s,/N_ELEMENTS))
  ca1= master_s
  ca2= master_l
  ca3= master_s*master_l
  ca4= master_s^2
  ca5= master_l^2;b=a0+a1*ca1+a2*ca2+a3*ca3+a4*ca4+a5*ca5
      
  result= DBLARR(6,2)
  Case Degree OF
    0: BEGIN
      result=[[MEAN(slave_s-master_s),1,0,0,0,0],[MEAN(slave_l-master_l),0,1,0,0,0]]
      result= DOUBLE(result)
      RETURN, result
    END
    1: BEGIN
      a=[ca0,ca1,ca2,ca3]
      coefx= TRANSPOSE(LA_LEAST_SQUARES(a, slave_s))
      coefy= TRANSPOSE(LA_LEAST_SQUARES(a, slave_l));- LS poly . slave(xs, ys)=F(xm, ym)
      result= [[coefx,0,0], [coefy,0,0]]
      RETURN, result
    END
    2: BEGIN
      a= [ca0,ca1,ca2,ca3,ca4,ca5]
      coefx= TRANSPOSE(LA_LEAST_SQUARES(a, slave_s))
      coefy= TRANSPOSE(LA_LEAST_SQUARES(a, slave_l));- LS poly . slave(xs, ys)=F(xm, ym)
      result= [[coefx], [coefy]]
      RETURN, result
    END
    ELSE:
  ENDCASE
END