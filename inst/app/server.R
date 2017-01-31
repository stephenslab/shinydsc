library('shiny')
library('shinydsc')

shinyServer(function(input, output, session) {

  observe({
    if (input$learnmore != 0L) {
      updateTabsetPanel(session, 'mainnavbar', selected = 'Help')
    }
  })

  load_dsc_rds = reactive({

    if (input$data_type == 'upload' & (!is.null(input$dsc_output_upload))) {

      dsc_raw = readRDS(file = input$dsc_output_upload$datapath)

    } else if (input$data_type == 'example') {

      # defensive programming on file name
      if (input$dsc_example %in% c('one_sample_location',
                                   'second_sample',
                                   'yet_another_example')) {
        dsc_raw = readRDS(file = paste0('data/', input$dsc_example, '.rds'))
      } else {
        dsc_raw = NULL
      }

    } else {
      dsc_raw = NULL
    }

    return(dsc_raw)

  })

  observe({
    dsc_raw = load_dsc_rds()
    if (!is.null(dsc_raw)) {
      dsc_ace = dsc2ace(dsc_raw)
      updateAceEditor(session, 'ace_upload', value = dsc_ace)
    }
  })

  observe({
    dsc_raw = load_dsc_rds()
    if (!is.null(dsc_raw)) {
      dsc_ace = dsc2ace(dsc_raw)
      updateAceEditor(session, 'ace_filter', value = dsc_ace)
    }
  })

  output$dsc_blocks_ui = renderUI({

    dsc_raw = load_dsc_rds()
    dsc_blocks = get_blocks(dsc_raw)
    dsc_execs = get_execs(dsc_raw)

    n_blocks = length(dsc_blocks)
    blocks_ui_list = vector('list', n_blocks)

    for (i in 1L:n_blocks) {
      blocks_ui_list[[i]] =
        selectizeInput(inputId  = paste0('execs_', dsc_blocks[i]),
                       label    = dsc_blocks[i],
                       choices  = c("NULL", dsc_execs[[dsc_blocks[i]]]),
                       multiple = TRUE)
    }
    # this is a list of render UI
    blocks_ui_list

  })

  output$dsc_params_ui = renderUI({

    dsc_raw = load_dsc_rds()
    dsc_blocks = get_blocks(dsc_raw)
    dsc_execs  = get_execs(dsc_raw)
    dsc_params = get_params(dsc_raw)

    params_ui_list = NULL

    params_ui_list = list(params = dsc_params)
    "params_ui_list"

  })



  ############### testing to get the table out
  # just test what in the uiblock
  output$input_type_text <- renderText({
    dsc_raw = load_dsc_rds()
    dsc_blocks = get_blocks(dsc_raw)
    dsc_execs = get_execs(dsc_raw)

    n_blocks = length(dsc_blocks)
    AA = (unlist(reactiveValuesToList(input)[paste0('execs_', dsc_blocks[1:n_blocks])]))
    # paste("you choose", AA)
    length(AA)
  })

  # just to test the output of the table
  output$filtered_master_table = renderDataTable({
    dsc_raw = load_dsc_rds()
    dsc_blocks = get_blocks(dsc_raw)
    dsc_execs = get_execs(dsc_raw)

    n_blocks = length(dsc_blocks)
    # AA = (unlist(reactiveValuesToList(input)[paste0('execs_', dsc_blocks[1:n_blocks])]))
    current_result = dsc_raw$master_mse
    # filter_result = dplyr::filter(current_result, simulate_name == "rnorm.R")
  })

  ####################### the following are for the output the tables and
# system('dsc settings.dsc --extract result --extract_from pi0_score --extract_to ashr_pi0_1.rds     --tags "An && ash_n" "An && ash_nu" -f')
  output$text1 <- renderText({
    getwd()
  })



})
