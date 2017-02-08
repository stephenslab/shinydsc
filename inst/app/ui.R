library('shiny')
library('shinyFiles')
library('shinydsc')
library('shinyAce')
library('dplyr')
library('plotly')
library('DT')
library('shinyjs')

shinyUI(
  navbarPage(
    title   = 'shinydsc',
    id      = 'mainnavbar',
    theme   = 'uchicago.css',
    inverse = FALSE,
    windowTitle = 'shinydsc - Explore Dynamic Statistical Comparison',
    ## TODO: add Google Analytics
    # header = tags$head(includeScript('google-analytics.js')),

    tabPanel(title = 'Home',

             fluidRow(
               column(width = 10, offset = 1,
                      div(class = 'jumbotron',
                          h1('shinydsc'),
                          h3('Explore dynamic statistical comparisons, interactively.'),
                          br(),
                          actionButton('learnmore', 'Learn More', icon('search'), class = 'btn-primary')
                      ),

                      tags$blockquote('“Enhance scientific discovery through statistical methods development, analysis, and cultural change.”',
                                      tags$small('Matthew Stephens, Professor, Department of Statistics and Human Genetics, University of Chicago'))

               )),

             fluidRow(
               column(width = 10, offset = 1,
                      includeMarkdown('include/footer.md')
               )
             )

    ),

    tabPanel(title = 'Setting Up',

             fluidRow(

               column(width = 10, offset = 1,
                      sidebarPanel(width = 12,
                                   radioButtons('data_type', label = 'Use example data or upload your data:',
                                                choices = list('Load example DSC output' = 'example',
                                                               'Upload your own DSC output' = 'upload'),
                                                selected = 'example'),
                                   conditionalPanel(
                                     condition = "input.data_type == 'example'",
                                     p('Download the example data from', a('this link', href = 'https://github.com/.../upload.md', target = '_blank'), '.'),
                                     selectizeInput('dsc_example', 'Choose example DSC output:',
                                                    choices = list('one_sample' = 'one_sample_location',
                                                                   'Second Sample'       = 'second_sample',
                                                                   'Yet Another Example' = 'yet_another_example'))
                                   ),
                                   conditionalPanel(
                                     condition = "input.data_type == 'upload'",
                                     p('Read a detailed explanation about the ', a('upload data format', href = 'https://stephenslab.github.io/dsc2-omega/dsc-script.html', target = '_blank'), '.'),
                                     fileInput('dsc_output_upload', label = 'Upload .rds file:')
                                   )
                      )

               ),

               column(width = 10, offset = 1,
                      mainPanel(width = 12,
                                tabsetPanel(
                                  tabPanel('DSC Configuration Overview',
                                           aceEditor('ace_upload',
                                                     value = 'Please upload your DSC output or select an example output',
                                                     mode = 'yaml', theme = 'tomorrow', fontSize = 14, readOnly = TRUE))
                                )
                      )
               )

             )

    ),

    tabPanel(title = 'Customize',

             fluidRow(

               column(width = 5, offset = 1,

                      tabsetPanel(
                        tabPanel('DSC Configuration Overview',
                                 aceEditor('ace_filter',
                                           value = 'Please upload your DSC output or select an example output',
                                           mode = 'yaml', theme = 'tomorrow', fontSize = 14, readOnly = TRUE))
                      )

               ),

               column(width = 5,
                      sidebarPanel(width = 12,
                                   h4('Please select executables from blocks:'),
                                   uiOutput('dsc_blocks_ui'),
                                   verbatimTextOutput("input_type_text")
                      ),

                      sidebarPanel(width = 12,
                                   h4('Please select parameters from executables:'),
                                   uiOutput('dsc_params_ui')
                      )
               )

             ),

             fluidRow(

               column(width = 10, offset = 1,

                      tabsetPanel(
                        tabPanel('Filtered Table',
                                 dataTableOutput('filtered_master_table'))
                      )

               )

             )

    ),

    tabPanel(title = 'Preview',
             shinyjs::useShinyjs(),
             textOutput("text1"),
             fluidRow(

               column(width = 5,

                      sidebarPanel(width = 9,

                                   a(id = "step_1", "step 1", href = "#"),
                                   shinyjs::hidden(
                                     div(id = "step_1_load",
                                         textInput("project_name", label = h3("Type a Project Name"),
                                                   value = ""),
                                         actionButton("open_proj", "Open",class = 'btn-primary'),
                                         textOutput("open_proj_note")
                                     )
                                   ),

                                   a(id = "step_2", "step 2", href = "#"),
                                   shinyjs::hidden(
                                     div(id = "step_2_load",
                                         shinyDirButton('dsc_directory', 'select your DSC', 'Please select a folder',class = 'btn-primary'),
                                         uiOutput("meta_file"),
                                         uiOutput("meta_output")
                                     )
                                   ),

                                   a(id = "step_3", "step 3", href = "#"),
                                   shinyjs::hidden(
                                     div(id = "step_3_load",
                                         actionButton('insertBtn', 'add tag',class = 'btn-primary'),
                                         actionButton('removeBtn', 'remove tag',class = 'btn-primary'),
                                         tags$div(id = 'placeholder')
                                     )
                                   ),

                                   a(id = "step_4", "step 4", href = "#"),
                                   shinyjs::hidden(
                                     div(id = "step_4_load",
                                         actionButton('apply_annotation', 'Apply!',class = 'btn-primary'),
                                         textOutput("tagged_dsc_note")
                                     )
                                   )


                      )
               )

             )

    ),

    tabPanel(title = 'Visualize',
             fluidPage(
             sidebarLayout(
               # column(width = 9,

                      sidebarPanel(width = 6,
                                   h4('Please select the score you want:'),
                                   uiOutput("result_folder"),
                                   uiOutput("meta_file_out")
                                   ),
                      mainPanel(
                        tabsetPanel(
                          tabPanel("Box Plot",
                                   uiOutput("box_content"),
                                   plotlyOutput("pi_0_plot_2")
                                   ),
                          tabPanel("violin Plot",
                                   uiOutput("violin_content"),
                                   plotOutput("pi_0_plot_1")
                                   )
                        )
                      )
                      # )
             ))

    ),

    tabPanel(title = 'Help',
             fluidRow(
               column(width = 10, offset = 1,
                      includeMarkdown('include/help.md')
               )
             ))

  )
)
