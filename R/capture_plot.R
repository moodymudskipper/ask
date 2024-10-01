#' Capture plot
#'
#' Capture current plot (can be a base plot, a ggplot2 plot or anything else)
#' and saves it into a temp png file whose path is returned. meant to be used
#' with the `image` argument of `ask*()` functions.
#'
#' @param width image width
#' @param height image height
#'
#' @return The path to the created file
#' @export
capture_plot <- function(width = 800, height = 600) {
  #rec_plot <- recordPlot()
  file <- tempfile(fileext = ".png")
  dev.copy(png, file = file, width = width, height = height)
  dev.off()
  file
}
