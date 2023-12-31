#' Fit Ball-Berry type models of stomatal conductance
#' @description Fits one of three versions of the Ball-Berry type stomatal conductance models to 
#' observations of stomatal conductance (gs), photosynthesis (A), atmospheric CO2 concentration (Ca) 
#' and vapour pressure deficit (VPD). 
#' @details Note that unlike in some publications (e.g. Leuning et al. 1995), the models fit here do not include the CO2 compensation point. This correction may be necessary but can be added by the user (by replacing Ca with the corrected term).
#' 
#' Note that all models use atmospheric CO2 concentration (Ca) instead of, as sometimes argued, intercellular CO2 concentration (Ci). Using the latter makes these models far more difficult to use in practice, and we have found no benefit of using Ci instead of Ca (and Ca arises from an optimization argument, see Medlyn et al. 2011). The idea that we should use Ci because 'stomata sense Ci, not Ca' is probably not valid (or at least, not sufficient), and note that Ci plays a central role in the steady-state solution to stomatal conductance anyway (see \code{\link{Photosyn}}). 
#' 
#' To fit the Ball-Berry models for each group in a dataframe, for example species, see the \code{\link{fitBBs}} function. 
#' @return A list with several components, most notably \code{fit}, the object returned by \code{nls}. If the user needs more information on the goodness of fit etc, please further analyze this object. For example, use the \pkg{broom} package for quick summaries. Or use \code{\link{confint}} to calculate confidence intervals on the fitted parameters.
#' 
#' @param data Input dataframe, containing all variables needed to fit the model.
#' @param varnames List of names of variables in the input dataframe. Relative humidity (RH) is only 
#' needed when the original Ball-Berry model is to be fit.
#' @param gsmodel One of BBOpti (Medlyn et al. 2011), BBLeuning (Leuning 1995), BallBerry (Ball et al. 1987), or BBOptiFull (Medlyn et al. 2011 but with an extra parameter gk, see Duursma et al. 2013)
#' @param fitg0 If TRUE, also fits the intercept term (g0, the 'residual conductance'). Default is FALSE.
#' @param D0 If provided, fixes D0 for the BBLeuning model. Otherwise is estimated by the data. 
#' @export
#' @references 
#' Ball, J.T., Woodrow, I.E., Berry, J.A., 1987. A model predicting stomatal conductance and its contribution to the control of photosynthesis under different environmental conditions., in: Biggins, J. (Ed.), Progress in Photosynthesis Research. Martinus-Nijhoff Publishers, Dordrecht, the Netherlands, pp. 221-224.
#' 
#' Leuning, R. 1995. A critical-appraisal of a combined stomatal-photosynthesis model for C-3 plants. Plant Cell and Environment. 18:339-355.
#'
#' Medlyn, B.E., R.A. Duursma, D. Eamus, D.S. Ellsworth, I.C. Prentice, C.V.M. Barton, K.Y. Crous, P. De Angelis, M. Freeman and L. Wingate. 2011. Reconciling the optimal and empirical approaches to modelling stomatal conductance. Global Change Biology. 17:2134-2144.
#' 
#' Duursma, R.A., Payton, P., Bange, M.P., Broughton, K.J., Smith, R.A., Medlyn, B.E., Tissue, D.T., 2013. Near-optimal response of instantaneous transpiration efficiency to vapour pressure deficit, temperature and [CO2] in cotton (Gossypium hirsutum L.). Agricultural and Forest Meteorology 168, 168-176. doi:10.1016/j.agrformet.2012.09.005
#' 
#' @importFrom stats nls
#' @importFrom stats coef
#' @importFrom stats residuals
#' @importFrom stats median
#' @importFrom stats nls.control
#' @rdname fitBB
#' @examples 
#' 
#' \dontrun{
#' # If 'mydfr' is a dataframe with 'Photo', 'Cond', 'VpdL' and 'CO2S', you can do:
#' myfit <- fitBB(mydfr, gsmodel = "BBOpti")
#' 
#' # Coefficients and a message:
#' myfit
#' 
#' # Coefficients only
#' coef(myfit)
#' 
#' # If you have a species variable, and would like to fit the model for each species,
#' # use fitBBs (see its help page ?fitBBs)
#' myfits <- fitBBs(mydfr, "species")
#' }
fitBB <- function(data, 
                  varnames=list(ALEAF="Photo", GS="Cond", VPD="VpdL", Ca="CO2S",RH="RH"),
                  gsmodel=c("BBOpti","BBLeuning","BallBerry","BBOptiFull"),
                  fitg0=FALSE,
                  D0=NULL){
  
  gsmodel <- match.arg(gsmodel)

  check_has <- function(this, there){
    if(!this %in% names(data)){
      Stop(this, " column not in data provided.")
    }
  }
  invisible(sapply(varnames, check_has))

  gs <- data[,varnames$GS]  
  vpd <- data[,varnames$VPD]
  aleaf <- data[,varnames$ALEAF]  
  ca <- data[,varnames$Ca]
  
  if(gsmodel == "BallBerry"){
    
    if(!("RH" %in% names(varnames))){
      Stop("To fit Ball-Berry you must include RH and specify it in varnames.")
    }
      
    rh <- data[,varnames$RH]
    if(max(rh, na.rm=TRUE) > 1){
      message("RH provided in % converted to relative units.")
      rh <- rh / 100
    }
  }
  
  if(gsmodel == "BBOpti"){
    if(!fitg0){
      fit <- try(nls(gs ~ 1.6*(1 + g1/sqrt(vpd))*(aleaf/ca), start=list(g1=4)) )
    } else {
      fit <- try(nls(gs ~ g0 + 1.6*(1 + g1/sqrt(vpd))*(aleaf/ca), start=list(g1=4, g0=0.005)) )
    }
  }
  if(gsmodel == "BBOptiFull"){
    if(!fitg0){
      fit <- try(nls(gs ~ 1.6*(1 + g1/vpd^(1-gk))*(aleaf/ca), start=list(g1=4, gk=0.5)) )
    } else {
      fit <- try(nls(gs ~ g0 + 1.6*(1 + g1/vpd^(1-gk))*(aleaf/ca), start=list(g1=4, g0=0.005, gk=0.5)) )
    }
  }
  if(gsmodel == "BBLeuning"){
    if(is.null(D0)){
      if(!fitg0){
        fit <- try(nls(gs ~ aleaf*g1/ca/(1 + vpd/D0), start=list(g1=4, D0=1.5)))
      } else {
        fit <- try(nls(gs ~ g0 + aleaf*g1/ca/(1 + vpd/D0), start=list(g1=4, D0=1.5, g0=0.005)))
      }
    }
    else if(is.numeric(D0)){
      if(!fitg0){
        fit <- try(nls(gs ~ aleaf*g1/ca/(1 + vpd/D0), start=list(g1=4)))
      } else {
        fit <- try(nls(gs ~ g0 + aleaf*g1/ca/(1 + vpd/D0), start=list(g1=4, g0=0.005)))
      }
    }
  }
  if(gsmodel == "BallBerry"){
    if(!fitg0){
      fit <- try(nls(gs ~ g1*aleaf*rh/ca, start=list(g1=4)))
    } else {
      fit <- try(nls(gs ~ g0 + g1*aleaf*rh/ca, start=list(g1=4, g0=0.005)))
    }
  }

l <- list()
l$gsmodel <- gsmodel
l$varnames <- varnames
l$fitg0 <- fitg0
l$data <- data
l$success <- !inherits(fit, "try-error")
l$coef <- if(l$success){
  if(fitg0){
    rev(coef(fit))
  } else {
    c(g0=0, coef(fit))
  }
}
else {
  NA
}
l$fit <- fit
l$n <- length(residuals(fit))
class(l) <- "BBfit"

return(l)  
}



#' @method coef BBfit
#' @export
coef.BBfit <- function(object, ...){
  
  object$coef
  
}

#' @method print BBfit
#' @export
print.BBfit <- function(x, ...){
  
  cat("Result of fitBB.\n")
  cat("Model : ", x$gsmodel, "\n")
  if(x$fitg0){
    cat("Both g0 and g1 were estimated.\n\n")
  } else {
    cat("Only g1 was estimated (g0 = 0).\n\n")
  }
  
  if(x$gsmodel != "BBOptiFull"){
    cat("Coefficients:\n")
    cat("g0  g1\n")
    cat(signif(coef(x)[1],3), signif(coef(x)[2],3), "\n")
  } else {
    cat("Coefficients:\n")
    cat("g0  g1  gk\n")
    cat(signif(coef(x)[1],3), signif(coef(x)[2],3), signif(coef(x)[3],3), "\n")
  }
  cat("\nFor more details of the fit, look at summary(myfit$fit)\n")
  cat("To return coefficients, do coef(myfit).\n")
  cat("(where myfit is the name of the object returned by fitBB)\n")
}


