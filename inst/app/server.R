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
                       choices  = dsc_execs[[dsc_blocks[i]]],
                       multiple = TRUE)
    }

    blocks_ui_list

  })

  output$dsc_params_ui = renderUI({

    dsc_raw = load_dsc_rds()
    dsc_blocks = get_blocks(dsc_raw)
    dsc_execs  = get_execs(dsc_raw)
    dsc_params = get_params(dsc_raw)

    params_ui_list = NULL

    params_ui_list

  })

})
