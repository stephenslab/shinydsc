#' Run shinydsc app
#'
#' Run shinydsc app
#'
#' @param display.mode shiny app display mode parameter
#'
#' @importFrom shiny runApp
#'
#' @examples
#' \donttest{shinydsc()}
#'
#' @export shinydsc

shinydsc = function(display.mode = 'normal') {

  appdir = system.file("app", package = "shinydsc")

  if (appdir == '') {
    stop('Could not find the app. Please try re-installing `shinydsc`.',
         call. = FALSE)
  }

  runApp(appdir, display.mode = display.mode)

}
