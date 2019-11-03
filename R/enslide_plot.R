#' Create a slide from a chart
#'
#' @param plot
#' @param slide_caption
#' @param plot_res
#'
#' @return
#' @export
#'
#' @examples
enslide_plot <- function(plot,
                         slide_caption,
                         plot_res = 160) {
  fig <- magick::image_graph(width = 1600,
                             height = 790,
                             res = plot_res)
  print(plot)
  grDevices::dev.off()
  fig <- magick::image_shadow(
    fig,
    color = "black",
    bg = "#FAF8F2",
    geometry = "50x10+30+30",
    operator = "atop",
    offset = "+20+20"
  )

  sysfonts::font_paths(system.file("", package = "ntft"))
  sysfonts::font_add(family = "helveticaneue",
                     regular = "slidecaptionbold.ttf")

  slide <- magick::image_read(
    system.file("slide_template.png", package = "ntft"))

  #grDevices::quartzFonts(A = grDevices::quartzFont(rep("Helvetica Neue", 4)))

  slide <- magick::image_draw(slide)
  showtext::showtext_begin()
  graphics::text(
    x = magick::image_info(slide)$width / 2,
    y = magick::image_info(slide)$height - 100,
    labels = slide_caption,
    col = "#5E5E5E",
    #family = "A", # Refer to quartzfont fonts
    family = "helveticaneue",
    #font = 2, # bold
    cex = 3.7,
    adj = 0.5
  )
  showtext::showtext_end()
  grDevices::dev.off()

  out <- magick::image_composite(slide,
                                 fig,
                                 offset = "+130+110")
  out
}
