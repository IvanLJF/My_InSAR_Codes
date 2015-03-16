function pix2tr,pixel
;some constant used in the function    
rsr2x=1.920768D*2.0e7                        ;get from the head file of ASAR data
                                              ;two times of range sample rate(Hz)
                                              ;RANGE_SAMP_RATE
t_range1=5514940D/2.0e9                      ;get from the head file of ASAR data
                                              ;one way time (s) to first range pixel
                                              ;FIRST_LINE_TIE_POINTS_SLANT_RANGE_TIMES_1 
                                              ;be care of the unit
pix2tr=t_range1+(pixel-1.0)/rsr2x
return,pix2tr
end

function pix2range,pixel
SOL=299792458.0D                           ;[m/s] speed of light
pix2tr=pix2tr(pixel)
pix2range=SOL*pix2tr
return,pix2range
end

PRO CreateConfig4Unwrap
;paremeters by user input
  configfile='D:/unwrap.conf'
  mode='TOPO'                              ;can be set to TOPO, DEFO, SMOOTH, or NOSTATCOSTS
  outfile='D:/ISEIS/master_slave.uint'     ;out file path
  corrfile='D:/ISEIS/master_slave.coh'     ;input correlation file
  initmethod='MST'                         ;algorithm used for initialization of wrapped phase value
                                           ;can be set to MCF or MST
;paremeters from former process
  nlooksrange='2'                          ;from earlier input, multilook parameter in range direction
  nlooksaz='10'                            ;from earlier input, multilook parameter in azimuth direction
;fixed for ENVISAT
  lambda='0.0562356000'                    ;wavelength(double, meters),Fixed for certain satellite platform
                                           ;this value is for ENVISAT ASAR
  rbw=1.6e7                                ;[Hz] for ASAR    
                                           ;bandwidth_tot_bw_range
                                           ;get from the ASAR head file
  rsr2x=1.920768D*2.0e7                    ;get from the head file of ASAR data
                                           ;two times of range sample rate(Hz)
                                           ;RANGE_SAMP_RATE
  abw=1316                                 ;pulse repetition frequency for EnviSAT
                                           ;from the head file
  prf=1652.416                             ;pulse repetition frequency for EnviSAT
                                           ;from the head file
  
; the following from slcimg.cc only for ENVISAT                                         
;    if (abs(wavelength-0.0562356) > 0.01)
;      WARNING.print("wavelength seems to deviates more than 1 cm from ASAR nominal.");
;    if (abs(prf-1652.0) > 100.0)
;      WARNING.print("prf deviates more than 100 Hz from ASAR nominal.");
;    if (abs(rsr2x - 19.207680*2.0e6) > 100000.0)
;      WARNING.print("rsr deviates more than 0.1 MHz from ASAR nominal.");
;    if (abs(abw-1316.0) > 100)
;      WARNING.print("ABW deviates more than 100 Hz from ASAR nominal?");
;    if (abs(rbw-16.0e6) > 1000)
;      WARNING.print("RBW deviates more than 1 kHz from ASAR nominal?");
                                           
                                           
                                         
;need to be completed by Zhao-------------------------------------------
 
  baseline='249.34'                        ;baseline parameter from earlier step, orbit information
  baselineangle_deg='-12.24'               ;baseline parameter from earlier step, orbit information
  orbitradius='7159596.70'
  earthradius='6371245.29'
  DA='45.7069688625'
;azres='5.7391269466'
  
;need to be completed by Zhao-------------------------------------------
                                        
  ;corrfileformat='FLOAT_DATA'             ;FIXED IN THE SYSTEM
  ;logfile='unwrap.log'                    ;FIXED IN THE SYSTEM
  ;verbose='TRUE'                          ;FIXED IN THE SYSTEM
  ;infileformate='COMPLEX_DATA'            ;FIXED IN THE SYSTEM
  ;                                        ;input file formate=complex
  ;outfileformate='ALT_LINE_DATA'          ;FIXED IN THE SYSTEM
                                           ;output data formate=hgt
  ;transmitmode='REPEATPASS'               ;FIXED IN THE SYSTEM
  ;norrlooks='23.8'                        ;FIXED IN THE SYSTEM
  ;ncorrlooksrange='3'                     ;FIXED IN THE SYSTEM
  ;ncorrlooksaz='15'                       ;FIXED IN THE SYSTEM
  
  ;---block for Tile.CONTROL: only for SNAPHU; defaults for single CPU---
  ntilerow          = 1; // number of tiles in range
  ntilecol          = 1; // number of tiles in azimuth
  rowovrlp          = 0; // overlap between tiles in rng
  colovrlp          = 0; // overlap between tiles in az
  nproc             = 1; // no.cpus or nodes on load
                       ; // balancing cluster
  tilecostthresh   = 500; // cost threshold boundaries of reliable regions


;--------------------------------------------------------------
;NO USE
;  x= 5
;  result= 'X='+STRING(x)
;  result2= 'Y='+STRING(x)
;  PRINTF, lun, result
;  PRINTF, lun, result2  
;--------------------------------------------------------------
  pixlo=1                                   ;first pixel (w.r.t. original_master)
                                            ;how to define this if there is a crop operating?
 ;pixhi=                                    ;last pixel
 ;linelo=                                   ;first line
 ;linehi=                                   ;last line
 
  nearrange=pix2range(pixlo)
  tempparameter1=pixlo+1.0
  nearrange2=pix2range(tempparameter1)
  DR=double(nlooksrange)*(nearrange2-nearrange)                                          
  ranges=(rsr2x/2/rbw)*(DR/double(nlooksrange))
  azres=(float(DA)/float(nlooksaz))*(prf/abw)
  
  OPENW, lun, configfile,/GET_LUN
  
    Printf, lun, '#Create a configure file for unwrap moudle                    ',$
    '#Written by Xiao Ruya, Version1.0 for test                                 ',$
    '#Thanks Mr. Li Tao for his help                                            ',$
    '#The Chinese University of Hong Kong                                       ',$    
    '#--------------------------------------------------------------------------',$
    '#snaphu configuration file                                                 ',$
    '#Lines with fewer than two fields and lines whose first non-whitespace     ',$
    '#characters are not alphnumeric are ignored.  For the remaining lines,     ',$
    '#anything after the first two fields (delimited by whitespace) is          ',$
    '#also ignored.  Inputs are converted in the order they appear in the file; ',$
    '#if multiple assignments are made to the same parameter, the last one      ',$
    '#given is the one used.  Parameters in this file will be superseded by     ',$
    '#parameters given on the command line after the -f flag specifying this    ',$
    '#file.  Multiple configuration files may be given on the command line.     ',$
    '#                                                                          ',$
    '#CONFIG FOR SNAPHU                                                         ',$
    '#--------------------------------------------------------------------------',$
    '#                                                                          ',$
    '#Created by CUHK INSAR software                                            ',$
    '#Example: snaphu  -f snaphu.conf Outdata/master_slave.cint.filtered 2597'   ,$
    '#--------------------------------------------------------------------------',$
    '# Statistical-cost mode (TOPO, DEFO, SMOOTH, or NOSTATCOSTS)               ',$
    'STATCOSTMODE     '+ STRING(mode)                                            ,$
    '                                                                           ',$
    '# Output file name                                                         ',$
    'OUTFILE     '+ STRING(outfile)                                              ,$
    '                                                                           ',$
    '# Correlation file name                                                    ',$
    'CORRFILE     '+ STRING(corrfile)                                            ,$
    '                                                                           ',$
    '# Correlation file format                                                  ',$
    'CORRFILEFORMAT        FLOAT_DATA                                           ',$
    '                                                                           ',$
    '# Text file to which runtime parameters will be logged.  The format of     ',$
    '# that file will be suitable so that it can also be used as a              ',$
    '# configuration file.                                                      ',$    
    'LOGFILE               snaphu.log                                           ',$
    '                                                                           ',$
    '# Algorithm used for initialization of wrapped phase values.  Possible     ',$
    '# values are MST and MCF.                                                  ',$
    'INITMETHOD      '+string(initmethod)                                        ,$
    '                                                                           ',$
    '# Verbose-output mode (TRUE or FALSE)                                      ',$
    'VERBOSE         TRUE                                                       ',$
    '                                                                           ',$
    '                                                                           ',$
    '################'                                                           ,$
    '# File formats #                                                           ',$
    '################                                                           ',$
    '# Input file format                                                        ',$
    'INFILEFORMAT          COMPLEX_DATA                                         ',$
    '                                                                           ',$
    '# Output file format (almost hgt)                                          ',$
    'OUTFILEFORMAT         ALT_LINE_DATA                                        ',$
    '                                                                           ',$
    '                                                                           ',$
    '###############################                                            ',$
    '# SAR and geometry parameters #                                            ',$
    '###############################                                            ',$
    '# Orbital radius (double, meters) or altitude (double, meters).  The       ',$
    '# radius should be the local radius if the orbit is not circular.  The     ',$
    '# altitude is just defined as the orbit radius minus the earth radius.     ',$
    '# Only one of these two parameters should be given.                        ',$
    '#ORBITRADIUS             7153000.0 (example)                               ',$
    'ORBITRADIUS             '+STRING(orbitradius)                               ,$
    '#ALTITUDE               775000.0                                           ',$
    '# Local earth radius (double, meters).  A spherical-earth model is         ',$
    '# used.                                                                    ',$
    '#EARTHRADIUS             6378000.0 (example)                               ',$
    'EARTHRADIUS             '+STRING(earthradius)                               ,$
    '                                                                           ',$
    '# The baseline parameters are not used in deformation mode, but they       ',$
    '# are very important in topography mode.  The parameter BASELINE           ',$
    '# (double, meters) is the physical distance (always positive) between      ',$
    '# the antenna phase centers.  The along-track componenet of the            ',$
    '# baseline is assumed to be zero.  The parameter BASELINEANGLE_DEG         ',$
    '# (double, degrees) is the angle between the antenna phase centers         ',$
    '# with respect to the local horizontal.  Suppose the interferogram is      ',$
    '# s1*conj(s2).  The baseline angle is defined as the angle of antenna2     ',$
    '# above the horizontal line extending from antenna1 towards the side       ',$
    '# of the SAR look direction.  Thus, if the baseline angle minus the        ',$
    '# look angle is less than -pi/2 or greater than pi/2, the topographic      ',$
    '# height increases with increasing elevation.  The units of                ',$
    '# BASELINEANGLE_RAD are radians.                                           ',$
    '#BASELINE                150.0 (example)                                   ',$
    '#BASELINEANGLE_DEG       225.0 (example)                                   ',$
    '#BASELINEANGLE_RAD      3.92699 (example)                                  ',$
    'BASELINE                           '+STRING(baseline)                       ,$
    'BASELINEANGLE_DEG                  '+STRING(baselineangle_deg)              ,$
    '                                                                           ',$
    '# Slant range from platform to first range bin in input data file          ',$
    '# (double, meters).  Be sure to modify this parameter if the input         ',$
    '# file is extracted from a larger scene.  The parameter does not need      ',$
    '# to be modified is snaphu is unwrapping only a subset of the input file.  ',$
    '#NEARRANGE       831000.0 (example)                                        ',$
    'NEARRANGE            '+STRING(nearrange)                                    ,$
    '                                                                           ',$
    '# Slant range and azimuth pixel spacings of input interferogram after      ',$
    '# any multilook averaging.  This is not the same as the resolution.        ',$
    '# (double, meters).                                                        ',$
    '#DR              8.0 (example)                                             ',$
    '#DA              20.0 (example)                                            ',$
    'DR                          '+STRING(DR)                                    ,$
    'DA                             '+STRING(DA)                                 ,$
    '                                                                           ',$
    '# Single-look slant range and azimuth resolutions.  This is not the        ',$
    '# same as the pixel spacing.  (double, meters).                            ',$
    '#RANGERES        10.0 (example)                                            ',$
    '#AZRES           6.0 (example)                                             ',$
    'RANGERES                    '+STRING(ranges)                                ,$
    'AZRES                           '+STRING(azres)                             ,$
    '                                                                           ',$   
    '# Wavelength (double, meters).                                             ',$
    '#LAMBDA          0.0565647 (example)                                       ',$
    'LAMBDA                   '+STRING(lambda)                                   ,$
    '                                                                           ',$
    '# Number of real (not necessarily independent) looks taken in range and    ',$
    '# azimuth to form the input interferogram (long).                          ',$
    '                                                                           ',$
    'NLOOKSRANGE                            '+STRING(nlooksrange)                ,$
    'NLOOKSAZ                               '+STRING(nlooksaz)                   ,$
    '                                                                           ',$
    '# Equivalent number of independent looks (double, dimensionless) that were ',$
    '# used to generate correlation file if one is specified.  This parameter   ',$
    '# is ignored if the correlation data are generated by the interferogram    ',$
    '# and amplitude data.                                                      ',$
    '## The equivalent number of independent looks is approximately equal to the',$
    '# real number of looks divided by the product of range and azimuth         ',$
    '# resolutions, and multiplied by the product of the single-look range and  ',$
    '# azimuth pixel spacings.  It is about 0.53 times the number of real looks ',$
    '# for ERS data processed without windowing.                                ',$
    '# (taken from Curtis example config file.)                                 ',$
    'NCORRLOOKS               23.8                                              ',$
    '                                                                           ',$
    '# Number of looks that should be taken in range and azimuth for estimating ',$
    '# the correlation coefficient from the interferogram and the amplitude     ',$
    '# data.  These numbers must be larger than NLOOKSRANGE and NLOOKSAZ.       ',$
    '# The actual numbers used may be different since we prefer odd integer     ',$
    '# multiples of NLOOKSRANGE and NLOOKSAZ (long).  These numbers are ignored ',$
    '# if a separate correlation file is given as input.                        ',$
    '# (taken from Curtis example config file.)                                 ',$
    'NCORRLOOKSRANGE          3                                                 ',$
    'NCORRLOOKSAZ             15                                                ',$
    '                                                                           ',$   
    '################                                                           ',$
    '# Tile control #                                                           ',$
    '################                                                           ',$
    '# Parameters in this section describe how the input files will be          ',$
    '# tiled.  This is mainly used for tiling, in which different               ',$
    '# patches of the interferogram are unwrapped separately.                   ',$
    '                                                                           ',$   
    '# Number of rows and columns of tiles into which the data files are        ',$
    '# to be broken up.                                                         ',$   
    'NTILEROW                                       '+STRING(ntilerow)           ,$
    'NTILECOL                                       '+STRING(ntilecol)           ,$
    '                                                                           ',$      
    '# Overlap, in pixels, between neighboring tiles.                           ',$
    'ROWOVRLP                                       '+STRING(rowovrlp)           ,$
    'COLOVRLP                                       '+STRING(colovrlp)           ,$
    '                                                                           ',$     
    '# Maximum number of child processes to start for parallel tile             ',$
    '# unwrapping.                                                              ',$
    'NPROC                                          '+STRING(nproc)              ,$
    '                                                                           ',$
    '# Cost threshold to use for determining boundaries of reliable regions     ',$
    '# (long, dimensionless; scaled according to other cost constants).         ',$
    '# Larger cost threshold implies smaller regions---safer, but               ',$
    '# more expensive computationally.                                          ',$
    'TILECOSTTHRESH                                 '+STRING(tilecostthresh)     ,$
    '                                                                           ',$
    '# Minimum size (long, pixels) of a reliable region in tile mode.           ',$
    '# MINREGIONSIZE             100                                            ',$
    '                                                                           ',$
    '# Extra weight applied to secondary arcs on tile edges.                    ',$
    '# TILEEDGEWEIGHT    2.5                                                    ',$
    '                                                                           ',$
    '# Maximum flow magnitude (long) whose cost will be stored in the secondary ',$
    '# cost lookup table.  Secondary costs larger than this will be approximated',$
    '# by a quadratic function.                                                 ',$
    '# SCNDRYARCFLOWMAX  8                                                      ',$
    '                                                                           ',$
    '# The program will remove temporary tile files if this is set.             ',$
    '# RMTMPTILE                 FALSE                                          ',$
    '                                                                           ',$
    '# If this is set to anything besides FALSE, the program will skip          ',$
    '# the unwrapping step and only assemble temporary tile files from a previous ',$
    '# invocation saved in the directory whose name is given here.  The tile size ',$
    '# parameters and file names must be the same.                              ',$
    '# ASSEMBLEONLY              tiledir                                        ',$
    '# End of snaphu configuration file                                         '
    
  FREE_LUN, lun
  
END