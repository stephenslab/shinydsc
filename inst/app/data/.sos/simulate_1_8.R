set.seed(3)
args <- list()
args$betahatsd <- 1
args$g <- ashr::normalmix(c(1/4,1/4,1/3,1/6),c(-2,-1,0,1),c(2,1.5,1,1))
args$max_pi0 <- 1
args$min_pi0 <- 0
args$nsamp <- 1000
library('ashr')
rnormmix_datamaker = function(args){
  #here is the meat of the function that needs to be defined for each dsc to be done
  pi0 = runif(1,args$min_pi0,args$max_pi0) #generate the proportion of true nulls randomly
  k = ncomp(args$g)
  comp = sample(1:k,args$nsamp,mixprop(args$g),replace=TRUE) #randomly draw a component
  isnull = (runif(args$nsamp,0,1) < pi0)
  beta = ifelse(isnull, 0,rnorm(args$nsamp,comp_mean(args$g)[comp],comp_sd(args$g)[comp]))
  sebetahat = args$betahatsd
  betahat = beta + rnorm(args$nsamp,0,sebetahat)
  meta=list(beta=beta,pi0=pi0)
  input=list(betahat=betahat,sebetahat=sebetahat)
  #end of meat of function
  data = list(meta=meta,input=input)
  return(data)
}
data = rnormmix_datamaker(args)
true_beta <- data$meta$beta
true_pi0 <- data$meta$pi0
saveRDS(list(data=data, true_beta=true_beta, true_pi0=true_pi0), 'dsc_result/datamaker.R_9.rds')

