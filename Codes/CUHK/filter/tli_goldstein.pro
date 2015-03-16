;+ 
; Name:
;    tli_goldstein.pro
; Purpose:
;    Do goldstein filter.
; Calling Sequence:
;    result= TLI_GOLDSTEIN( ph, n_win=n_win, alpha=alpha)
; Inputs:
;    ph: phase.
; Optional Input Parameters:
;    None
; Keyword Input Parameters:
;    n_win: filter window.
;    alpha: The larger the serious filtered.
; Outputs:
;    Phase after filter.
; Commendations:
;    n_win: 32
;    alpha: 1.8
; Example:
;    master='/mnt/software/ForExperiment/TSX_TJ_500/20090327.rslc'
;    slave='/mnt/software/ForExperiment/TSX_TJ_500/20090407.rslc'
;    mslc= OPENSLC(master)
;    sslc= OPENSLC(slave)
;    int= mslc*CONJ(sslc)
;    phase= ATAN(int,/PHASE)
;    filtered= tli_goldstein(phase)
; Modification History:
;    07/03/2012: Written by T.Li @ inSAR Team in CUHK & SWJTU.
;-

FUNCTION TLI_GOLDSTEIN, ph, n_win=n_win, alpha=alpha

  IF ~KEYWORD_SET(n_win) THEN n_win=32
  IF ~KEYWORD_SET(alpha) THEN alpha=0.8
  IF n_win LT 6 THEN MESSAGE, 'n_win must >=6 '
  IF ~(n_win MOD 2) THEN BEGIN
    PRINT, 'n_win must be even.'
    PRINT, 'I change it to CEIL(n_win)'
    n_win= n_win+1
  ENDIF
  IF alpha LT 0 THEN BEGIN
    PRINT,'alpha can not be less than 0.'
    RETURN, -1
  ENDIF
  ;--------------------------------Initialization Done-------------------
  n_pad=ROUND(n_win*0.25)
  n_i=(size(ph,/DIMENSIONS))[0];
  n_j=(size(ph,/DIMENSIONS))[1];
n_inc=floor(n_win/4);
n_win_i=ceil(n_i/n_inc)-3;
n_win_j=ceil(n_j/n_inc)-3;
ph_out=FLTARR(size(ph,/DIMENSIONS));
x=FINDGEN(n_win/2)+1
temp=INDEXARR(x=TRANSPOSE(x),y=TRANSPOSE(x))
xx= REAL_PART(temp)
yy= IMAGINARY(temp)
X=xx+yy
wind_func=[X,ROTATE(X,5)];
wind_func=[[wind_func],[ROTATE(wind_func, 7)]]
dd= ~WHERE(FINITE(ph))
IF dd(0) NE -1 THEN ph[dd]=0
B= ([0.0439,0.2494,0.7066,1.0,0.7066,0.2494,0.0439])
B=TRANSPOSE(B)##B
ph_bit=FLTARR(n_win+n_pad,n_win+n_pad);

for ix1=1,n_win_i DO BEGIN;;;;;;;;;;;;;;;;;;;
    wf=wind_func;
    i1=(ix1-1)*n_inc+1-1;
    i2=i1+n_win-1;
    if i2 GT n_i-1 THEN BEGIN ;;;;;;;;;;;;;;;;;;;;;;
        i_shift=i2-n_i+1;
        i2=n_i-1;
        i1=n_i-n_win+1-1;
        wf=[FLTARR(i_shift,n_win),wf(0:n_win-i_shift-1,*)];
    endIF
    for ix2=1,n_win_j DO BEGIN;;;;;;;;;;;;;;;;;;;;
        wf2=wf;
        j1=(ix2-1)*n_inc+1;
        j2=j1+n_win-1;
        if (j2 GT n_j-1)  THEN BEGIN;;;;;;;;;;;;;;;;;;;;;;;;;;;
           j_shift=j2-n_j+1;
           j2=n_j-1;
           j1=n_j-n_win+1-1;
           wf2=[[FLTARR(n_win,j_shift)],[wf2(*,0:n_win-j_shift-1)]];
        endIF
        ph_bit[0:n_win-1,0:n_win-1]=ph[i1:i2,j1:j2];
        ph_fft=FFT(ph_bit,-1);
        H=abs(ph_fft);
        temp= CONVOL(H, B,/EDGE_WRAP)
        H= ABS(FFT(temp,1))
;        H=ifftshift(filter2(B,fftshift(H))); % smooth response
        meanH=median(H);
        if meanH NE 0 THEN        H=H/meanH;
        H=H^alpha;
        ph_filt=FFT(ph_fft*H,1);    
        ph_filt=ph_filt(0:n_win-1,0:n_win-1)*wf2;;;;;;;;;;;;;;;;;;;;
        if ~FINITE(ph_filt(0,0)) THEN BEGIN
            PRINT, 'filtered phase contains NaNs in goldstein_filt'
        endif
        ph_out[i1:i2,j1:j2]=ph_out[i1:i2,j1:j2]+ph_filt;
    endFOR
endFOR
RETURN, ph_out
END