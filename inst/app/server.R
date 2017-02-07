library('shiny')
library('shinydsc')
library('plotly')

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

  ####################### the following are for the output the tables and this part is just for dsc Omega
  rv = reactiveValues()

  open_proj_message <- eventReactive(input$open_proj, {
    crt_path = getwd()
    data_path = paste0(crt_path,"/data")
    open_path = paste0(data_path,"/",input$project_name)
    dir.create(open_path)
    # restore this path
    # the further action should be inside of this current path.
    rv$crt_path = open_path
    paste("You have open a dsc project",input$project_name,"in",open_path)
  })

  output$open_proj_note <- renderText({
    #rv$pi_0 = readRDS("data/ashr_pi0_1.rds")
    # open a project and indicate the directory
    open_proj_message()
  })

  #### tag add system
  inserted <- c()

  observeEvent(input$insertBtn, {
    btn <- input$insertBtn
    id <- paste0('tag_', btn)
    insertUI(
      selector = '#placeholder',
      ## wrap element in a div with id for ease of removal
      ui = tags$div(
        selectizeInput(inputId  = id,
                            label    = paste('tag id is:', id),
                            choices  = rv$dsc_meta$tags,
                            multiple = TRUE),
        id = id
      )
    )
    inserted <<- c(id, inserted)
  })

  observeEvent(input$removeBtn, {
    removeUI(
      ## pass in appropriate div id
      selector = paste0('#', inserted[length(inserted)])
    )
    inserted <<- inserted[-length(inserted)]
  })

  # try to get the dsc_working directory
  output$dsc_work_dir_note = renderText({
    paste("your working dsc dirctory is :", parseDirPath(volumes, input$dsc_directory))
  })

  volumes <- c(Root = '~' )
  shinyDirChoose(input, 'dsc_directory', roots=volumes, session=session, restrictions=system.file(package='base'))
  output$dsc_directorypath <- renderPrint({
    dsc_dir = parseDirPath(volumes, input$dsc_directory)
    meta_folder = paste0(dsc_dir,"/.sos/.dsc")
    #tag_file = list.files(meta_folder)[sapply(list.files(meta_folder),function(x){grepl("shinymeta",x) })][1]
    tag_file = input$meta_file
    # note here that the file is a data frame so i need the $v1 thing
    dsc_meta = readRDS(paste0(meta_folder,"/",tag_file))
    rv$dsc_meta = dsc_meta
    parseDirPath(volumes, input$dsc_directory)
  })

  # this is to choose the different type of meta file
  output$meta_file <- renderUI({
    # read_tag()
    dsc_dir = parseDirPath(volumes, input$dsc_directory)
    meta_folder = paste0(dsc_dir,"/.sos/.dsc")
    tag_file = list.files(meta_folder)[sapply(list.files(meta_folder),function(x){grepl("shinymeta",x) })]
    selectizeInput(inputId  = "meta_file",
                   label    = paste('meta file:'),
                   choices  = tag_file,
                   multiple = TRUE)
  })

  # add the meta
  output$meta_output <- renderUI({
    # read_tag()
    selectizeInput(inputId  = "meta_var",
                   label    = paste('output configuration:'),
                   choices  = rv$dsc_meta$variables,
                   multiple = TRUE)
  })

  # this is just for test
  output$tagged_dsc_note <- renderText({
    tagged_command()
  })

  # try to read the annotation from the list
  tagged_command = eventReactive(input$apply_annotation,{
    rv$app_dir = getwd()
    dsc_dir = parseDirPath(volumes, input$dsc_directory)
    tag_list = names(input)[sapply(names(input),function(x){grepl("tag_",x) })]
    tag_index = which(sapply(names(input),function(x){grepl("tag_",x) }))
    # to restore the index of tag in the input
    rv$tag_index = tag_index
    ### TODO think about then the index in empty
    tag_list
    tag_content = list()
    for(i in 1:length(tag_list)){
      tag_content[[i]] = c(input[[tag_list[i]]])
    }
    # compose tag part
    tag_part = ""
    for (i in 1:length(tag_content)) tag_part = paste0(tag_part, ' ', "'", paste(tag_content[[i]], collapse='&&'), "'")
    # tag_part
    # read the meta content
    meta_part = ""
    for(i in 1:length(input$meta_var)) meta_part = paste(meta_part,input$meta_var[[i]])
    # name part
    meta_folder = paste0(dsc_dir,"/.sos/.dsc")
    # meta_file_name = list.files(meta_folder)[sapply(list.files(meta_folder),function(x){grepl("shinymeta",x) })]
    meta_file_name = input$meta_file
    name_part_vec = unlist(strsplit(meta_file_name,'[.]'))
    name_part = name_part_vec[length(name_part_vec)-2]
    system_command = paste("dsc settings.dsc --extract",meta_part,"--extract_from",name_part,"--tags",tag_part, "-v0","--extract_to", paste0(rv$crt_path,"/",name_part,".rds"))
    setwd(dsc_dir)
    try({
      system(system_command)
    })
    setwd(rv$app_dir)
    system_command
  })


  ######## here are for the visualization
  output$result_folder <- renderUI({
    # read_tag()
    data_dir = paste0(getwd(),"/data")
    res_file = list.files(data_dir)# [sapply(list.files(data_dir),function(x){grepl("rds",x) })]
    selectizeInput(inputId  = "meta_folder_out",
                   label    = paste('View Folder:'),
                   choices  = res_file,
                   multiple = TRUE)
  })

  result_file = eventReactive(input$meta_folder_out,{
    result_folder = paste0(getwd(),"/data/",input$meta_folder_out)
    tag_file = list.files(result_folder)[sapply(list.files(result_folder),function(x){grepl("rds",x) })]
    selectizeInput(inputId  = "meta_file_out",
                   label    = paste('meta file:'),
                   choices  = tag_file,
                   multiple = TRUE)
  })


  output$meta_file_out <- renderUI({
    result_file()
  })


  read_result = eventReactive(input$meta_file_out,{
    result_folder = paste0(getwd(),"/data/",input$meta_folder_out,"/",input$meta_file_out)
    RDS_file = readRDS(result_folder)
  })

  # this is for the box plot
  output$box_content <- renderUI({
    result_list = read_result()
    res_file = names(result_list)
    selectizeInput(inputId  = "box_content",
                   label    = paste('choose the component:'),
                   choices  = res_file,
                   multiple = TRUE)
  })

  output$violin_content <- renderUI({
    result_list = read_result()
    res_file = names(result_list)
    selectizeInput(inputId  = "violin_content",
                   label    = paste('choose the component:'),
                   choices  = res_file,
                   multiple = TRUE)
  })

  box_data = eventReactive(input$box_content,{
    result_list = read_result()
    n_col = length(input$box_content)
    scores = c()
    score_type = c()
    for(i in 1:n_col){
      scores = c(scores,unlist(result_list[(input$box_content)[i]]))
      score_type = c(score_type, rep((input$box_content)[i],length( unlist(result_list[(input$box_content)[i]]))))
    }
    data_mat = cbind(scores,score_type)
    colnames(data_mat) = c("values","Type")
    data_df = data.frame(data_mat)
    data_df
  })

  violin_data = eventReactive(input$violin_content,{
    result_list = read_result()
    n_col = length(input$violin_content)
    scores = c()
    score_type = c()
    for(i in 1:n_col){
      scores = c(scores,unlist(result_list[(input$violin_content)[i]]))
      score_type = c(score_type, rep((input$violin_content)[i],length( unlist(result_list[(input$violin_content)[i]]))))
    }
    data_mat = cbind(scores,score_type)
    colnames(data_mat) = c("values","Type")
    data_df = data.frame(data_mat)
    data_df
  })



  output$pi_0_plot_1 = renderPlot({
    dat = violin_data()
    library(ggplot2)
    p <- ggplot(dat, aes(x=Type, y=values)) +
      geom_violin() +
      geom_dotplot(binaxis='y', stackdir='center', dotsize = .5, binwidth = 1/100)
    p
  })

  output$pi_0_plot_2 = renderPlotly({
    dat = box_data()
    library(plotly)
    p <- plot_ly(dat, y = ~ values, x = ~ Type, type = "box")
    p
  })



})
