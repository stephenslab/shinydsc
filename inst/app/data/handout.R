> out = ""
> length(res)
[1] 2
> for (i in 1:length(res)) out = paste0(out, ' ', "'", paste(res[[i]], collapse='&&'), "'")
> out

res = unlist(strsplit('.sos/.dsc/dsc_result.pi0_score.shinymeta.rds','[.]'))

> res[length(res)-2]

dsc settings.dsc --extract pi0_score:result shrink:beta_est shrink:pi0_est --extract_from pi0_score --tags "An && ash_n" "An && ash_nu" -v0 —extract_to /path/to/your/project/pi0_score.rds



## to compose this sentence


paste("dcs settings.dsc --extract", )