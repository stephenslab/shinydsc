DSC_220D5D6DAE <- readRDS("dsc_result/datamaker.R_13.rds")
input <- DSC_220D5D6DAE$data

mixcompdist <- 'normal'
library(ashr)
ash.wrapper=function(input,args=NULL){
  if(is.null(args)){
    args=list(mixcompdist="halfuniform",method="fdr")
  }
  res = do.call(ash, args=c(list(betahat=input$betahat,sebetahat=input$sebetahat),args))
  return(res)
}
ash_data = ash.wrapper(input$input, list(mixcompdist = mixcompdist, optmethod = "mixEM"))
beta_est <- ash_data$PosteriorMean
pi0_est <- ashr::get_pi0(ash_data)
saveRDS(list(ash_data=ash_data, beta_est=beta_est, pi0_est=pi0_est), 'dsc_result/datamaker.R_13_runash.R_1.rds')

