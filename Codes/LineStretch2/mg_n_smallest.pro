;+
; Finds the n smallest elements of a data array. This algorithm works fastest on
; uniformly distributed data. The worst case for it is a single smallest data
; element and all other elements with another value. This will be nearly
; equivalent to just sorting all the elements and choosing the first n elements.
;
; @returns index array
;
; @param data {in}{required}{type=numeric array} data array of any numeric type
;        (except complex/dcomplex)
; @param n {in}{required}{type=integer} number of smallest elements to find
; @keyword largest {in}{optional}{type=boolean} set to find n largest elements
;-
function mg_n_smallest, data, n, largest=largest
    compile_opt strictarr
    on_error, 2

    ; both parameters are required
    if (n_params() ne 2) then begin
        message, 'required parameters are missing'
    endif

    ; use histogram to find a set with more elements than n of smallest elements
    nData = n_elements(data)
    nBins = nData / n
    h = histogram(data, nbins=nBins, reverse_indices=ri, /nan)

    ; set parameters based on whether finding smallest or largest elements
    if (keyword_set(largest)) then begin
        startBin = nBins - 1L
        endBin = 0L
        inc = -1L
    endif else begin
        startBin = 0L
        endBin = nBins - 1L
        inc = 1L
    endelse

    ; loop through the bins until we have n or more elements
    nCandidates = 0L
    for bin = startBin, endBin, inc do begin
        nCandidates += h[bin]
        if (nCandidates ge n) then break
    endfor

    ; get the candidates and sort them
    candidates = keyword_set(largest) ? $
                 ri[ri[bin] : ri[nBins] - 1L] : $
                 ri[ri[0] : ri[bin + 1L] - 1L]
    sortedCandidates = sort(data[candidates])
    if (keyword_set(largest)) then sortedCandidates = reverse(sortedCandidates)

    ; return the proper n of them
    return, (candidates[sortedCandidates])[0:n-1L]
end
