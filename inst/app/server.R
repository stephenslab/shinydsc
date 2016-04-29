library('shiny')

shinyServer(function(input, output, session) {

  observe({
    if (input$learnmore != 0L) {
      updateTabsetPanel(session, 'mainnavbar', selected = 'Help')
    }
  })

})
