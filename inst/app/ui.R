library('shiny')

shinyUI(
  navbarPage(
    title = 'shinydsc',
    id = 'mainnavbar',
    theme = 'uchicago.css',
    inverse = FALSE,
    windowTitle = 'shinydsc - Explore Dynamic Statistical Comparison',
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

    tabPanel(title = 'Upload'

    ),

    tabPanel(title = 'Filter'

    ),

    tabPanel(title = 'Visualize'

    ),

    tabPanel(title = 'Help',
             fluidRow(
               column(width = 10, offset = 1,
                      includeMarkdown('include/help.md')
               )
             ))

  )
)
