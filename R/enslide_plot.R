setup_fonts <- function() {
  sysfonts::font_paths(system.file("", package = "ntft"))
  sysfonts::font_add(family = "helveticaneue",
                     regular = "slidecaptionbold.ttf")
  sysfonts::font_add(family = "merriserif",
                     regular = "Merriweather-Regular.ttf",
                     bold = "MerriweatherSans-ExtraBold.ttf",
                     italic = "Merriweather-Italic.ttf",
                     bolditalic = "FiraCode-Bold.ttf")
  sysfonts::font_add(family = "merrisans",
                     regular = "MerriweatherSans-Regular.ttf",
                     bold = "Merriweather-Black.ttf",
                     italic = "MerriweatherSans-Italic.ttf",
                     bolditalic = "FiraCode-Bold.ttf")
}

rep_sym_w_fun <- function(sentence, pattern) {
  md_positions <- str_locate_all(sentence, pattern$rgx)[[1]]

  if(nrow(md_positions) > 0) {
    for(i in 1:(nrow(md_positions)/2)) {
      md_positions <- str_locate_all(sentence, pattern$rgx)[[1]]
      str_sub(sentence, md_positions[1,1], md_positions[1,2]) <- paste0(pattern$fun, "(")
      shift_pos <- nchar(pattern$fun) + 1 - nchar(pattern$md)
      str_sub(sentence,
              md_positions[2,1] + shift_pos,
              md_positions[2,2] + shift_pos) <- ")"
    }
  }

  sentence
}

md_to_exp <- function(sentence) {
  md_bold <- list(
    md = "**",
    rgx = "\\*\\*",
    fun = "bold"
  )
  md_italic <- list(
    md = "*",
    rgx = "\\*",
    fun = "italic"
  )
  md_code <- list(
    md = "`",
    rgx = "`",
    fun = "bolditalic"
  )

  sentence %>%
    rep_sym_w_fun(md_bold) %>%
    rep_sym_w_fun(md_italic) %>%
    rep_sym_w_fun(md_code) %>%
    str_replace_all("bold\\((.*?)\\)", "', bold('\\1\'),'") %>%
    str_replace_all("bolditalic\\((.*?)\\)", "', bolditalic('\\1\'),'") %>%
    str_replace_all("(?<!bold)italic\\((.*?)\\)", "', italic('\\1\'),'") %>% {
      str_glue("expression(paste('{.}'))")
    }
}

caption_template <-
  function(slide,
           caption,
           x_pos,
           y_pos,
           adj = 0.5,
           cex = 3.7,
           alpha = 1,
           font_family = "helveticaneue") {
    slide <- magick::image_draw(slide)
    rgb_grey_text <- rgb(76, 76, 76, alpha = alpha * 255, maxColorValue = 255)
    rgb_blue_code <- rgb(6, 58, 109, alpha = alpha * 255, maxColorValue = 255)
    showtext::showtext_begin()

    exp_label <- md_to_exp(caption)
    exp_label_non_code <- str_replace_all(exp_label,
                                          "bolditalic\\(.*?\\)",
                                          "phantom(\\0)")

    graphics::text(
      x = x_pos,
      y = y_pos,
      labels = eval(parse(text = exp_label)),
      col = ifelse(alpha == 1, rgb_blue_code, rgb_grey_text),
      family = font_family,
      cex = cex,
      adj = adj
    )


    if (alpha == 1) {
      graphics::text(
        x = x_pos,
        y = y_pos,
        labels = eval(parse(text = exp_label_non_code)),
        col = rgb_grey_text,
        family = font_family,
        cex = cex,
        adj = adj
      )
    }
    showtext::showtext_end()
    grDevices::dev.off()
    slide
  }

prepare_template <- function(caption, template_path = "slide_template.png") {
  slide <- magick::image_read(system.file(template_path, package = "ntft"))

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
  list(obj = slide,
       coord = slide_coord)
}

prepare_fig <-
  function(plot,
           slide,
           margins,
           plot_pct_width,
           slide_caption,
           plot_res) {
    plot_max_width  <- slide$coord$width - margins$right - margins$left
    plot_max_height <-
      slide$coord$height - margins$top - margins$bottom
    plot_width <- plot_max_width * plot_pct_width

    plot_pct_height <- 1 # Currently cst
    slide_caption_line_length <-
      stringi::stri_count_regex(slide_caption, "\n")

    if (length(slide_caption_line_length) == 0) {
      plot_height <- plot_max_height * plot_pct_height
    } else {
      plot_height <-
        (plot_max_height * plot_pct_height) - (20 * (slide_caption_line_length + 1))
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

calculate_left_offset <-
  function(slide_width, margins, plot_width, align) {
    switch (
      align,
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
  margins <- list(
    top = 100,
    right = 195,
    bottom = 170,
    left = 115
  )

  slide <- prepare_template(caption = slide_caption)
  fig <- prepare_fig(
    plot = plot,
    slide = slide,
    margins = margins,
    plot_pct_width = plot_pct_width,
    slide_caption = slide_caption,
    plot_res = plot_res
  )

  offset_left <-
    calculate_left_offset(
      slide_width = slide$coord$width,
      margins = margins,
      plot_width = magick::image_info(fig)$width,
      align = plot_align
    )
  offset_top  <- margins$top
  offset_plot <- paste0("+", offset_left, "+", offset_top)
  out <- magick::image_composite(slide$obj,
                                 fig,
                                 offset = offset_plot)
  out
}

split_blist_items <- function(bullet_md_list) {
  stringi::stri_trim(bullet_md_list) %>%
    stringi::stri_split(regex = "\n?([:digit:]\\.) ") %>%
    unlist() %>%
    stringi::stri_subset(regex = "^$", negate = TRUE)
}

split_on_line_break <- function(text) {
  stringi::stri_split(text, regex = "\n")
}

write_list <- function(slide, list, font_pct_size, highlight, font_family = "merriserif") {
  items <- split_blist_items(list)
  sub_items <- sapply(items, split_on_line_break)
  items_n_lines <- sapply(sub_items, length)

  base_line_height <- switch(font_family,
                             helveticaneue = 55,
                             merriserif = 65,
                             merrisans = 65)

  line_height <- base_line_height * font_pct_size
  font_size   <- 3.7 * font_pct_size
  inter_item_height <- line_height * 0.5
  items_height <- items_n_lines * line_height + inter_item_height
  slide_height <- magick::image_info(slide)$height
  start_y_pos_item <- (slide_height / 2) - (sum(items_height) / 2)

  for (i in 1:length(items)) {
    if (i == 1) {
      # Write title
      slide <- caption_template(
        slide,
        caption = items[i],
        x_pos = magick::image_info(slide)$width / 2,
        y_pos = start_y_pos_item,
        cex = font_size * 1.5,
        adj = 0.5,
        font_family = "helveticaneue"
      )
    } else {
      # Write number
      slide <- caption_template(
        slide,
        caption = paste0(i-1, " "),
        x_pos = 300,
        y_pos = start_y_pos_item,
        adj = c(1, 1),
        cex = font_size * 1.5,
        font_family = font_family,
        alpha = ifelse(i == (highlight + 1) ||
                         is.null(highlight), 1, .2)
      )

      start_y_pos_sub_item <- start_y_pos_item
      for (j in 1:length(sub_items[[i]])) {
        # Write text line by line
        slide <- caption_template(
          slide,
          caption = sub_items[[i]][j],
          x_pos = 300,
          y_pos = start_y_pos_sub_item,
          adj = c(0, 1),
          cex = font_size,
          font_family = font_family,
          alpha = ifelse(i == (highlight + 1) ||
                           is.null(highlight), 1, .2)
        )
        start_y_pos_sub_item <- start_y_pos_sub_item + line_height
      }

    }
    start_y_pos_item <- start_y_pos_item + items_height[i]
  }
  slide
}



#' Generate a slide with a list of items
#'
#' @param list
#' @param highlight
#' @param slide_caption
#' @param font_pct_size
#'
#' @return
#' @export
#'
#' @examples
enslide_list <- function(list,
                         highlight,
                         slide_caption,
                         font_pct_size,
                         font_family = "merriserif") {
  setup_fonts()
  margins <- list(
    top = 100,
    right = 195,
    bottom = 170,
    left = 115
  )
  template <- prepare_template(caption = slide_caption)
  slide <- write_list(template$obj, list, font_pct_size, highlight, font_family)
  slide
}



#' Generate a General Knowledge slide
#'
#' @param text
#' @param font_pct_size
#'
#' @return
#' @export
#'
#' @examples
gk_slide <- function(text, font_pct_size = 1) {
  setup_fonts()
  margins <- list(
    top = 100,
    right = 195,
    bottom = 170,
    left = 115
  )
  template <- prepare_template(caption = "",
                               template_path = "slide_template_general_k.png")

  text_lines <- sapply(text, split_on_line_break)[[1]]
  slide <- template$obj
  start_y_pos <- template$coord$center_height - (length(text_lines) * 65 * font_pct_size / 2)
  for(i in 1:length(text_lines)) {
    slide <- caption_template(
      slide,
      caption = text_lines[i],
      x_pos = template$coord$width - margins$right,
      y_pos = start_y_pos + (i - 1) * 65 * font_pct_size,
      cex = 3.7 * font_pct_size,
      font_family = "merriserif",
      adj = c(1,0)
    )
  }
  slide
}
