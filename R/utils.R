#' convert DSC configuration to ACE editor content string
#'
#' @param dsc_list dsc output list
#'
#' @export
dsc2ace = function (dsc_list) {
  dsc_conf = dsc_list$'.dscsrc'
  dsc_conf_ace = gsub('\\\\n', '\\\n',
                      substring(dsc_conf, 2L, nchar(dsc_conf) - 1L))
  dsc_conf_ace
}

#' get master table from dsc output
#'
#' @param dsc_list dsc output list
#'
#' @export
get_master = function (dsc_list) {

  # TODO: more reliable ways to get master table name
  master_idx = which(substring(names(dsc_list), 1L, 7L) == 'master_')
  master_table = dsc_list[[master_idx]]
  master_table

}

#' get block names from master table
#'
#' @param dsc_list dsc output list
#'
#' @export
get_blocks = function (dsc_list) {

  master_table = get_master(dsc_list)
  master_table_names = names(master_table)

  is_last_char_sth = function (str, sth) {
    n = nchar(sth) - 1L
    return(substring(str, nchar(str) - n, nchar(str)) == sth)
  }

  master_top_even = floor(length(master_table_names)/2) * 2

  idx = 1L
  true_idx = 0L
  while (idx <= master_top_even - 1L) {
    if ( (is_last_char_sth(master_table_names[idx], '_name') &
          is_last_char_sth(master_table_names[idx + 1L], '_id')) ) {
      idx = idx + 2L  # slide windows
      true_idx = true_idx + 2L  # record true index
    } else {
      break
    }
  }

  block_names_raw = master_table_names[seq(from = 2L, to = true_idx, by = 2L)]
  block_names = substring(block_names_raw, 1L, nchar(block_names_raw) - 3L)

  block_names

}

#' get executable names for blocks
#'
#' @param dsc_list dsc output list
#'
#' @return a list containing block names and their executable names
#'
#' @export
get_execs = function (dsc_list) {

  master_table = get_master(dsc_list)

  dsc_blocks = get_blocks(dsc_list)
  n_blocks = length(dsc_blocks)

  dsc_execs = vector('list', n_blocks)
  names(dsc_execs) = dsc_blocks

  for (i in 1L:n_blocks)
    dsc_execs[[i]] =
    levels(master_table[, paste0(dsc_blocks[i], '_name')])

  dsc_execs

}

#' get parameter names for executables
#'
#' @param dsc_list dsc output list
#'
#' @return a list containing block names, executable names, and parameter names
#'
#' @export
get_params = function (dsc_list) {

  master_table = get_master(dsc_list)

  dsc_blocks = get_blocks(dsc_list)
  n_blocks = length(dsc_blocks)

  dsc_execs = get_execs(dsc_list)

  dsc_params = vector('list', n_blocks)
  names(dsc_params) = dsc_blocks

  for (i in 1L:n_blocks) {

    dsc_params[[i]] = vector('list', length(dsc_execs[[i]]))
    names(dsc_params[[i]]) = dsc_execs[[i]]

    for (j in 1L:length(dsc_params[[i]])) {
      all_params = names(dsc_list[[dsc_execs[[i]][j]]])
      dsc_params[[i]][[j]] = setdiff(all_params,
                                     c('step_id', 'depends', 'return'))
    }

  }

  dsc_params

}
