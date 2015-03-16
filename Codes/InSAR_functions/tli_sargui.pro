; Create a framework to map all functions I have coded.
;
; - T.LI @ ISEIS

; Before it works, compile every pro and function to be used.

PRO TLI_SARGUI_EVENT, event

  ;  widget_control,event.top,get_uvalue=pstate
  ;uname=widget_info(event.id,/uname)
  ;
  ;
  ;   WIDGET_CONTROL, event.top, GET_UVALUE=uval
  ;   uname=WIDGET_INFO(event.id,/UNAME)

  WIDGET_CONTROL, event.id, GET_UVALUE=uval
  
  IF TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    WIDGET_CONTROL,event.top,/destroy
    RETURN
  ENDIF
  
  uval=STRLOWCASE(uval)
  Case uval OF
    'io'  : BEGIN
      Case STRLOWCASE(event.value) OF
        'read whole slc'                 : TLI_FINDPRO, 'tli_readslc'
        'read slc block'                 : TLI_FINDPRO, 'subsetslc'
        'sarlist'                        : TLI_FINDPRO, 'tli_readtxt'
        'itab'                           : TLI_FINDPRO, 'tli_readmyfiles'
        'plist'                          : TLI_FINDPRO, 'tli_readdata'
        'pint'                           : TLI_FINDPRO, 'tli_readdata'
        'pdiff'                          : TLI_FINDPRO, 'tli_readdata'
        'tli_plist'                      : TLI_FINDPRO, 'tli_readmyfiles'
        'tli_pdiff'                      : TLI_FINDPRO, 'tli_readmyfiles'
        'tli_arcs'                       : TLI_FINDPRO, 'tli_readmyfiles'
        'tli_dvddh'                      : TLI_FINDPRO, 'tli_readmyfiles'
        'tli_vdh'                        : TLI_FINDPRO, 'tli_readmyfiles'
        'tli_nonlinear'                  : TLI_FINDPRO, 'tli_readmyfiles'
        'read binary files'              : TLI_FINDPRO, 'tli_readdata'
        'read ascii files'               : TLI_FINDPRO, 'tli_readtxt'
        'write files'                    : TLI_FINDPRO, 'tli_write'
        ELSE:
      ENDCASE
    END
    'general': BEGIN
    
      Case STRLOWCASE(event.value) OF
        
      
      ENDCASE
      
      
      
    END
    
    
    
    
    
    
    
    ELSE:
    
    
    
    
    
  ENDCASE
  
END



PRO TLI_SARGUI

  wid_base      = WIDGET_BASE(TITLE='My functions - T. LI @ SASMAC', $
    MBAR=bar, UVALUE='base', $
    TLB_frame_attr=1,/column, $
    /TLB_KILL_REQUEST_EVENTS)
    
  io_menu     = WIDGET_BUTTON(bar, VALUE=' IO ', /MENU)
  general_menu  = WIDGET_BUTTON(bar, VALUE=' General ', /MENU)
  sar_menu      = WIDGET_BUTTON(bar, VALUE=' SAR ', /MENU)
  polar_menu    = WIDGET_BUTTON(bar, VALUE=' PolSAR ', /MENU)
  insar_menu    = WIDGET_BUTTON(bar, VALUE=' InSAR' , /MENU )
  polinsar_menu = WIDGET_BUTTON(bar, VALUE=' PolInSAR ', /MENU)
  ; subap_menu    = WIDGET_BUTTON(bar, VALUE=' SubAp' , /MENU )
  help_menu     = WIDGET_BUTTON(bar, VALUE=' Help', /MENU, /HELP)
  
  desc_io_menu=[ '4\Read GAMMA Files',$
    '1\Common Files', $
    '1\SLC', $
    '0\Read whole SLC', $
    '0\Read SLC Block', $
    '2\Read SLC Using a Structure', $
    '1\IPTA Files',$
    '0\sarlist', $
    '0\itab', $
    '0\plist', $
    '0\pint', $
    '2\pdiff', $
    '2\',$
    '1\Read My Files', $
    '0\tli_plist', $
    '0\tli_pdiff', $
    '0\tli_arcs', $
    '0\tli_dvddh', $
    '0\tli_vdh', $
    '2\tli_nonlinear',$
    '2\', $
    '0\Read Binary Files', $
    '0\Read ASCII Files', $
    '4\Write Files'$
    ]
    
    
  desc_general_menu =[ '4\Parameter Information', $
    '0\Complex -> Amplitude' , $
    '0\Complex -> Phase' $
    ]
  desc_sar_menu = [ '5\Inspect'   , $
    '0\Point target', $
    '0\Distributed target',$
    '2\Calculate # of looks',$
    '0\RFI filter'   , $
    '5\Speckle filter'   , $
    '0\Boxcar'      , $
    '0\Lee'         , $
    '0\Refined Lee' , $
    '0\IDAN-LLMMSE'      , $
    '0\Gamma-MAP' , $
    '0\Sigma',      $
    '0\Median'      , $
    '0\Gauss'      , $
    '0\Kuan' , $
    '2\Frost' , $
    '1\Edge detection' , $
    '0\RoA'     , $
    '0\Lee-RoA'     , $
    '0\MSP-RoA'     , $
    '0\Canny'     , $
    '4\Sobel'     , $
    '2\Roberts'   , $
    '1\Texture' , $
    '0\Variation coefficient'   , $
    '0\Texture inhomogenity'   , $
    '2\Co-occurence features'   , $
    '1\Geometry'  , $
    '2\Slant range -> ground range', $
    '1\Amplitude'  , $
    '2\Remove range antenna pattern', $
    
    '1\Multitemporal' ,$
    '1\Coregistration' ,$
    '0\Coarse (global offset)' ,$
    '2\Warping' ,$
    '1\Change-detection' ,$
    '0\Band ratio' , $
    '0\Band difference', $
    '0\Propability of change', $
    '2\Band entropy' ,$
    '2\Recombine to single file', $
    
    '5\Spectral tools'  , $
    '0\watch spectra',$
    '0\CDA sidelobe cancellation', $
    '2\modify spectal weights',$
    '1\Time-frequency'  , $
    '1\Generate', $
    '0\Subaperture channels in x', $
    '0\Subaperture channels in y', $
    '0\Subaperture channels in x and y', $
    '2\Subaperture covariance matrix', $
    '2', $
    '5\Calculate', $
    '0\Span image', $
    '0\Amplitude ratio', $
    '0\Interchannel phase difference', $
    '2\Interchannel correlation', $
    '1\Transform'  , $
    '0\Amplitude <-> Intensity',$
    '2\SLC -> Amplitude Image',  $
    '5\Wizard mode', $
    '2\Speckle filtering' $
    ]
  desc_polar_menu = [ $
    '5\Inspect'   , $
    '0\Polarimetric scatterer analysis', $
    '0\Point target', $
    '0\Distributed target',$
    '0\Calculate PolSAR SNR',$
    '2\Calculate # of looks',$
    '1\Calibration',$
    '0\Phase and amplitude imbalance',$
    '0\Cross-talk (Quegan)',$
    '0\Cross-talk (Ainsworth)',$
    '2\Cross-polar symmetrisation',$
    '0\RFI filter'   , $
    '5\Speckle filter'   , $
    '0\Boxcar'      , $
    '0\Lee'      , $
    '0\Refined Lee'      , $
    '0\IDAN-LLMMSE'      , $
    '2\Simulated Annealing'      , $
    '1\Edge detection', $
    '2\Polarimetric CFAR', $
    '1\Basis transforms', $
    '0\-> HV', $
    '0\-> circular', $
    '0\-> linar at 45 deg', $
    '2\Others', $
    '5\Parameters', $
    '0\SERD / DERD',$
    '0\Entropy / Alpha / Anisotropy',$
    '0\Delta / Tau (Scattering mechanism / Orientation randomness)', $
    '2\Alpha / Beta / Gamma / Delta angles',$
    '1\Decompositions', $
    '0\Pauli decomposition', $
    '0\Eigenvalue / Eigenvector', $
    '0\Freeman-Durden', $
    '0\TVSM',$
    ;   '0\Cameron', $
    '0\Moriyama', $
    '2\Sphere / Diplane / Helix', $
    '1\Classification', $
    '0\K-means Wishart (general)', $
    '0\K-means Wishart (H/a/A)', $
    '0\Expectation maximisation EM-PLR', $
    '0\Expectation maximisation selfinit', $
    '0\Lee category preserving', $
    '0\H/a segmentation', $
    '0\H/a/A segmentation', $
    '0\Physical classification', $
    '2\Number of sources', $
    '1\Post-classification', $
    '0\Median filter', $
    '0\Freeman Durden Palette', $
    '2\Resort clusters', $
    '5\Spectral tools'  , $
    '2\watch spectra',$
    '1\Time-frequency'  , $
    '1\Generate', $
    '0\Subaperture channels in x', $
    '0\Subaperture channels in y', $
    '0\Subaperture channels in x and y', $
    '2\Subaperture covariance matrix', $
    '0\Covarince matrix for every subaperture', $
    '6\Nonstationarity analysis', $
    '5\Calculate', $
    '0\Span image', $
    '0\Amplitude ratio', $
    '0\Interchannel phase difference', $
    '2\Interchannel correlation', $
    '1\Transform', $
    '0\Vector -> Matrix', $
    '0\Matrix -> Vector', $
    '2\[C] <--> [T]', $
    '5\Wizard mode', $
    '0\Speckle filtering'      , $
    '0\Scattering vector -> Entropy/Alpha/Anisotropy',$
    '2\Scattering vector -> Wishart classification'$
    ]
  desc_polinsar_menu = [ $
    '5\Inspect'   , $
    '0\Classical SB-coherence analysis', $
    '0\MB coherence optimization analysis', $
    '0\MB polarimetric scatterer analysis', $
    ;                  '0\MB parameter inversion analysis', $
    '2\Calculate # of looks',$
    '1\Calibration',$
    '5\Not recommended', $
    '0\Enforcing reflection symmetry', $
    '0\Enforcing polarimetric stationarity', $
    '2\Enforcing Freeman volume power', $
    '2\Cross-polar symmetrisation', $
    '0\RFI filter'   , $
    '5\Remove topography',$
    '0\Maximum likelihood estimation (MLE)', $
    '2\Digital elevation model (DEM)', $
    '1\Spectral filtering', $
    '0\Range (standard)', $
    '2\Range (adaptive)', $
    '1\Remove flat-earth',$
    '0\Linear',$
    '2\From file',$
    '5\Speckle filter'   , $
    '0\Boxcar'      , $
    '0\Lee'      , $
    '0\Refined Lee'      , $
    '0\IDAN-LLMMSE'      , $
    '2\Simulated Annealing'      , $
    ;   '1\Edge detection', $
    ;   '2\Polarimetric CFAR', $
    '1\Basis transforms', $
    '0\--> HV', $
    '0\--> Circular', $
    '0\--> Linar at 45 deg', $
    '0\Others', $
    '6\Individually per pixel', $
    '5\Coherence estimation', $
    '0\Boxcar', $
    '2\Region Growing', $
    '1\Coherence optimisation', $
    '0\Multibaseline multiple SMs   (MB-MSM)', $
    '0\Multibaseline equal SMs      (MB-ESM)', $
    '4\Single-baseline multiple SMs (SB-MSM)', $
    '0\Single-baseline equal SMs    (SB-ESM)', $
    '6\Anisotropy parameters', $
    ;   '2\Information', $
    '1\Phase optimisation', $
    '0\ESPRIT', $
    '2\Phase diversity', $
    '1\Correlation', $
    '0\Total', $
    '0\Over baselines', $
    '6\Incoherent MB stationarity', $
    '5\Parameters', $
    '0\Entropy / Alpha / Anisotropy',$
    '0\Mean Alpha / Beta / Gamma / Delta angles',$
    '2\All Alpha / Beta / Gamma / Delta angles',$
    '1\Decompositions', $
    '0\Pauli decomposition', $
    '0\Lexicographic (default)', $
    '0\Freeman-Durden', $
    '2\Sphere / Diplane / Helix', $
    ;     '5\Decompositions', $
    ;     '2\Pauli decomposition', $
    '1\Classification',$
    '0\K-means Wishart (general)', $
    '0\K-means Wishart (H/a/A)', $
    '0\Expectation maximisation EM-PLR', $
    ;                  '0\Expectation maximisation selfinit', $
    '2\A1/A2 LFF parameters', $
    '1\Post-classification', $
    '0\Freeman Durden Palette', $
    '2\Resort clusters', $
    '5\Spectral tools'  , $
    '2\watch spectra',$
    '1\Time-frequency'  , $
    '1\Generate', $
    '0\Subaperture channels in x', $
    '0\Subaperture channels in y', $
    '0\Subaperture channels in x and y', $
    '2\Subaperture covariance matrix', $
    '0\Covarince matrix for every subaperture', $
    '6\Nonstationarity analysis', $
    '5\PolDInSAR', $
    '0\Differential phases', $
    '2\Differential heights', $
    '5\Extract', $
    '0\Complex interferograms', $
    ;   '0\Interferometric amplitudes', $
    '0\Interferometric phases', $
    '0\SAR image', $
    '0\PolSAR image', $
    '0\InSAR image', $
    '2\SB-PolInSAR image', $
    '1\Transform', $
    '0\Vector -> Matrix', $
    '0\Matrix -> Vector', $
    '0\[C] <--> [T]', $
    '2\Matrix normalization', $
    '5\Wizard mode', $
    '0\Speckle filtering', $
    '2\POLINSAR data -> HaA-Wishart classification' $
    ;                '5\For developers',$
    ;                '2\Data info' $
    ]
    
  desc_insar_menu = [ $
    '5\Coregistration', $
    '0\Orbit (global)', $
    '0\Coarse (global)'   , $
    '0\Subpixel (global)' , $
    '2\Array of patches' , $
    '1\Spectral filtering', $
    '0\Range (standard)', $
    '2\Range (adaptive)', $
    '1\Remove flat-earth', $
    '0\linear', $
    '0\from geometry', $
    '2\from file', $
    '1\Coherence',  $
    '0\Boxcar', $
    '0\Gauss', $
    '2\Region growing', $
    '1\Phase noise filter', $
    '0\Boxcar'      , $
    '0\Goldstein'      , $
    '2\GLSME'      , $
    '1\Phase Unwrapping', $
    '0\Least-Squares', $
    '1\Branch Cuts', $
    '0\Branch cuts unwrapping', $
    '0\Identify residues', $
    '2\Calculate branch cuts', $
    '4\Rewrap phase', $
    '2\Calculate difference map', $
    '0\Shaded relief', $
    '5\Airborne case', $
    '0\Parameter information',$
    '2\Remove flat-earth phase',$
    ;     '0\Remove topographic phase',$
    ;     '0\Range adaptative filter',$
    ;     '2\Phase2height conversion',$
    '5\Spectral tools'  , $
    '2\watch spectra',$
    '5\Transform'    , $
    '0\Image pair -> interferogram' , $
    '0\Extract amplitude' , $
    '2\Extract phase'  $
    ]
  desc_help_menu = [ $
    '4\RAT User Guide', $
    '4\Contact', $
    '0\License', $
    '6\About RAT' $
    ]
    
  m_io       = CW_PDMENU(io_menu, desc_io_menu,/MBAR,/RETURN_FULL_NAME, UVALUE='io')
  m_general  = CW_PDMENU(general_menu,desc_general_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'general')
  m_sar      = CW_PDMENU(sar_menu,desc_sar_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'sar')
  m_polar    = CW_PDMENU(polar_menu,desc_polar_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'polsar')
  m_polinsar = CW_PDMENU(polinsar_menu,desc_polinsar_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'polinsar')
  m_insar    = CW_PDMENU(insar_menu,desc_insar_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'insar')
  m_help     = CW_PDMENU(help_menu,desc_help_menu,/MBAR,/RETURN_FULL_NAME,UVALUE = 'help')
  
  
  WIDGET_CONTROL, /REALIZE, wid_base , XOFFSET=200
  
  if float(strmid(!version.release,0,3)) lt 6.2 then begin
    error = DIALOG_MESSAGE(["Sorry, IDL / IDL virtual machine version >= 6.2 required!",$
      "Enjoy the errors which will occur... (most things will work)"], DIALOG_PARENT = wid.base, TITLE='Error')
  endif
  
  XMANAGER, 'tli_sargui', wid_base,/no_block
END