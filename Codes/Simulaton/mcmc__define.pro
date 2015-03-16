;+ ; PURPOSE:
; This class defines an interface for running Markov Chain Monte
; Carlo simulations. The code is based on the opening chapters of
; "Markov Chain Monte Carlo in Practice" by Gilks et al. The code in
; this file sets up the logic for running an MCMC simulation using
; the Metropolis Hastings algorithm. To actually use these functions,
; a subclass must be defined, and the selectTrial and
; logTargetDistribution methods must be overridden. Each of these
; methods is problem-specific, and cannot be coded in advance.
;
; CATEGORY:
; statistics
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
; October 2 2009: Modified run procedure to avoid unnecessary calls
; to logTargetDistribution
; October 3 2009: Added THIN keyword and state variable
;-
;+
; PURPOSE:
; This procedure runs the Markov Chain
;
; CATEGORY:
; statistics
;
; COMMON BLOCKS:
; mcmc_common: Holds the seed variable for calls to randomu
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
; Oct 3 2009: Optimized so that logTargetDistribution is only ever
; evaluated once per link
;-
pro mcmc::run, verbose = verbose
  compile_opt idl2
  common mcmc_common, seed
  ;- save the random seed value
  current = *self.seed 
  currentValue = self->logTargetDistribution(current)
  nsuccess = 0 & nfail = 0
  thinStep = 0
  cr = string(13B)
  for i = 0, self.nstep - 1, 1 do begin
    if keyword_set(verbose) then print, 1. * i / self.nstep, cr, format='($, e0.2, a)'
    ;- pick a new trial link
    trial = self->selectTrial(current, transitionRatio = transitionRatio)
    newValue = self -> logTargetDistribution(trial)
    ;- determine acceptance probability via MH algorithm
    alpha = exp(newValue - currentValue) * transitionRatio
    u = randomu(seed)
    if u lt alpha then begin
      ;- new trial accepted
      current = trial
      currentValue = newValue
      nsuccess++
    endif else nfail++
    ;- new trial rejected
    if (++thinStep) eq self.thin then begin
      thinStep = 0
      (*self.chain)[i / self.thin] = current
      (*self.logf)[i / self.thin] = currentValue
    endif
  endfor
  self.nsuccess = nsuccess & self.nfail = nfail
end
;+
; PURPOSE:
; This function generates a new trial link in the markov chain,
; given the current link. It is not implemented by default, and must
; be overridden. This function must also return the ratio of the
; transition probabilities between the old and new links (i.e.,
; q(old | new) / q(new | old) ). This ratio is needed by the
; Metropolis Hastings algorithm implemented in
; getTransitionProbability.
;
; CATEGORY:
; statistics
;
; INPUTS:
; current: The current link in the chain. This can be any kind of
; scalar (number, structure, object, etc), as long as the
; implementing class knows how to handle it.
;
; KEYWORD PARAMETERS:
; transitionRatio: This must be set to a named variable that will
; hold, on output, the transition ratio
; q(current | next) / q(next | current)
;
; OUTPUTS:
; The next link in the chain to try.
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
;-
function mcmc::selectTrial, current, transitionRatio = transitionRatio
  message, 'Method is not implemented, and must be overrided by a subclass!'
  return, !values.d_nan
end
;+
; PURPOSE:
; This function calculates the (unnormalized) logarithm of the target
; distribution that the Marcov Chain aims to sample from. It is usually a
; likelihood or posterior distribution, but the function is not
; implemented in this interface. We use the logarithm of the
; function, since its values may often be very small.
;
; CATEGORY:
; statistics
;
; INPUTS:
; link: The point at which to evaluate the target distribution.
;
; OUTPUTS:
; The log of the target distribution, evaluated at link.
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
;-
function mcmc::logTargetDistribution, link
  message, 'Method is not implemented, and must be overridden by a subclass!'
  return, !values.d_nan
end
;+
; PURPOSE:
; This function returns the markov chain
;
; CATEGORY:
; statistics
;
; OUTPUTS:
; The Markov Chain
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
;-
function mcmc::getChain, logf = logf
  logf = *self.logf
  return, *self.chain
end
;+
; PURPOSE:
; This function returns the number of successes and failures (that
; is, acceptances and rejections of the proposal link) in the Markov
; chain.
;
; CATEGORY:
; statistics
;
; KEYWORD PARAMETERS:
; nfail: Set to a named variable to hold the number of failures
;
; OUTPUTS:
; The number of successes
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
;-
function mcmc::getNSuccess, nfail = nfail
  nfail = self.nfail
  return, self.nsuccess
end
;+
; PURPOSE:
; This method returns the MCMC object's data, if any
;
; CATEGORY:
; statistics
;
; OUTPUTS:
; the data
;-
function mcmc::getData
  return, *self.data
end
;+
; PURPOSE:
; This function returns the seed link
;
; CATEGORY:
; statistics
;
; OUTPUTS:
; the seed link
;-
function mcmc::getSeed
  return, *self.seed
end
;+
; PURPOSE:
; This function initializes the MCMC object
;
; CATEGORY:
; statistics
;
; INPUTS:
; seed: The initial point to start the chain at. Can be any scalar,
; as long as it is correctly handeled by the other MCMC methods
; nstep: The number of links in the desired Markov Chain.
; data: Any data relevant to the process
;
; KEYWORD PARAMETERS:
; thin: Set to a number to avoid storing every step of the
; chain. This is useful for long chains which might otherwise take up
; lots of memory. If set, then only every THIN'th link will be
; saved to the chain. Should be less than the correlation length of
; the chain.
;
; OUTPUTS:
; 1 for success
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
;-
function mcmc::init, seed, nstep, data, thin = thin
  compile_opt idl2
  on_error, 2
  ;- check inputs
  if n_params() ne 3 then begin
    print, 'mcmc::init calling sequence:'
    print, "obj = obj_new('mcmc', seed, nstep, data, [thin = thin])"
    return, -1
  endif
  if n_elements(thin) ne 0 && thin le 0 then $
    message, 'thin keyword must be positive'
  self.thin = keyword_set(thin) ? thin : 1
  self.seed = ptr_new(seed)
  self.data = ptr_new(data)
  self.chain = ptr_new(replicate(seed, nstep / self.thin))
  self.logf = ptr_new(dblarr(nstep / self.thin))
  self.nstep = nstep
  return, 1
end
;+
; PURPOSE:
; Free memory when we are finished
;
; CATEGORY:
; statistics
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
;-
pro mcmc::cleanup
  ptr_free, self.seed
  ptr_free, self.chain
  ptr_free, self.data
  ptr_free, self.logf
  return
end
;+
; PURPOSE:
; define the mcmc data structure
;
; CATEGORY:
; statistics
;
; MODIFICATION HISTORY:
; September 2009: Written by Chris Beaumont
; Oct 2010: Added logf field
;-
pro mcmc__define
  data = {mcmc, $ seed : ptr_new(), $ ;- the first link in the chain
    chain : ptr_new(), $ ;- all of the links
    logf : ptr_new(), $ ;- logTargetDistribution, evaluated at chain links
    data : ptr_new(), $ ;- any data needed
    nsuccess : 0L, $ ;- number of accepted trial links
    nfail : 0L, $ ;- number of rejected trial links
    nstep : 0L, $ ;- number of links in the chain
    thin : 0L $ ;- number of links to skip between storage
    }
end