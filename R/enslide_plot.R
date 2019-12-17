setup_fonts <- function() {
  sysfonts::font_paths(system.file("", package = "ntft"))
  sysfonts::font_add(family = "helveticaneue",
                     regular = "slidecaptionbold.ttf")
}

caption_template <- function(slide, caption, x_pos, y_pos) {
  slide <- magick::image_draw(slide)
  showtext::showtext_begin()
  graphics::text(
    x = x_pos,
    y = y_pos,
    labels = caption,
    col = "#5E5E5E",
    family = "helveticaneue",
    cex = 3.7,
    adj = 0.5
  )
  showtext::showtext_end()
  grDevices::dev.off()
  slide
}

prepare_template <- function(caption, template_path = "slide_template.png") {

  slide <- magick::image_read(
    system.file(template_path, package = "ntft"))

  slide_coord <- list(
    width  = magick::image_info(slide)$width,
    height = magick::image_info(slide)$height
  )
  slide_coord$center_width  <- slide_coord$width / 2
  slide_coord$center_height <- slide_coord$height / 2

  slide <- caption_template(slide,
                            caption,
                            x_pos = slide_coord$center_width,
                            y_pos = slide_coord$height - 100)
  list(
    obj = slide,
    coord = slide_coord
  )
}

prepare_fig <- function(plot, slide, margins, plot_pct_width, slide_caption, plot_res) {
  plot_max_width  <- slide$coord$width - margins$right - margins$left
  plot_max_height <- slide$coord$height - margins$top - margins$bottom
  plot_width <- plot_max_width * plot_pct_width

  plot_pct_height <- 1 # Currently cst
  slide_caption_line_length <- stringi::stri_count_regex(slide_caption, "\n")

  if(length(slide_caption_line_length) == 0) {
    plot_height <- plot_max_height * plot_pct_height
  } else {
    plot_height <- (plot_max_height * plot_pct_height) - (20 * (slide_caption_line_length + 1))
  }

  fig <- magick::image_graph(width = plot_width,
                             height = plot_height,
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
  fig
}

calculate_left_offset <- function(slide_width, margins, plot_width, align) {
  switch (align,
          right = slide_width - margins$right - plot_width,
          left  = margins$left,
          center = (slide_width - plot_width) / 2
  )
}

#' Create a slide from a chart
#'
#' @param plot
#' @param slide_caption
#' @param plot_res
#' @param plot_pct_width
#' @param plot_align
#'
#' @return
#' @export
#'
#' @examples
enslide_plot <- function(plot,
                         slide_caption,
                         plot_res = 160,
                         plot_pct_width = 1,
                         plot_align = "center") {
  setup_fonts()
  margins <- list(top=100, right=195, bottom=170, left=115)

  slide <- prepare_template(caption = slide_caption)
  fig <- prepare_fig(plot = plot,
                     slide = slide,
                     margins = margins,
                     plot_pct_width = plot_pct_width,
                     slide_caption = slide_caption,
                     plot_res = plot_res)

  offset_left <- calculate_left_offset(slide_width = slide$coord$width,
                                       margins = margins,
                                       plot_width = magick::image_info(fig)$width,
                                       align = plot_align)
  offset_top  <- margins$top
  offset_plot <- paste0("+", offset_left, "+", offset_top)
  out <- magick::image_composite(slide$obj,
                                 fig,
                                 offset = offset_plot)
  out
}


