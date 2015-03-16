; docformat = 'rst'

;+
; Initializes GPULib if it is present.
;
; :Returns:
;    1 if GPULib is present, 0 if not
;
; :Params:
;    devId: in, optional, type=numtype
;       id of the GPU device to be used for GPU computations
;
; :Keywords:
;    _ref_extra : in, optional, type=keywords
;       keywords to GPUINIT
;-
function gpu_detect, devId, _ref_extra=e
  compile_opt strictarr
  
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, 0
  endif
  
;  gpuinit, devId, _extra
  gpuinit
  
  return, 1
end
