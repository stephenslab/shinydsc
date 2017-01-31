DSC_LMERGE <-
function(x, y, ...)
{
  if(length(x) == 0)
    return(y)
  if(length(y) == 0)
    return(x)
  for (i in 1:length(names(y)))
    x[names(y)[i]] = y[i]
  return(x)
}

DSC_BDBA8F78D7 <- list()
input.files <- c('dsc_result/datamaker.R_11.rds', 'dsc_result/datamaker.R_11_runash.R_1.rds')
for (i in 1:length(input.files)) DSC_BDBA8F78D7 <- DSC_LMERGE(DSC_BDBA8F78D7, readRDS(input.files[i]))
est <- DSC_BDBA8F78D7$beta_est
truth <- DSC_BDBA8F78D7$true_beta
score = function(est, truth){
  return(sqrt(mean((est-truth)^2)))
}
result = score(est, truth)
saveRDS(list(result=result), 'dsc_result/datamaker.R_11_runash.R_1_score_beta_1.rds')

