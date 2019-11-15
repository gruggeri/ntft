rep_sym_w_fun <- function(sentence, pattern) {
  md_positions <- str_locate_all(sentence, pattern$rgx)[[1]]

  if (nrow(md_positions) > 0) {
    for (i in 1:(nrow(md_positions) / 2)) {
      md_positions <- str_locate_all(sentence, pattern$rgx)[[1]]
      str_sub(sentence, md_positions[1, 1], md_positions[1, 2]) <-
        paste0(pattern$fun, "(")
      shift_pos <- nchar(pattern$fun) + 1 - nchar(pattern$md)
      str_sub(sentence,
              md_positions[2, 1] + shift_pos,
              md_positions[2, 2] + shift_pos) <- ")"
    }
  }

  sentence
}

md_to_exp <- function(sentence) {
  md_bold <- list(md = "**",
                  rgx = "\\*\\*",
                  fun = "bold")
  md_italic <- list(md = "*",
                    rgx = "\\*",
                    fun = "italic")
  md_code <- list(md = "`",
                  rgx = "`",
                  fun = "bolditalic")

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
    # Set text colors
    rgb_grey_prose <-
      rgb(76, 76, 76, alpha = alpha * 255, maxColorValue = 255)
    rgb_blue_code  <-
      rgb(6, 58, 109, alpha = alpha * 255, maxColorValue = 255)

    slide <- magick::image_draw(slide)

    showtext::showtext_begin()

    exp_label <- md_to_exp(caption)
    exp_label_non_code <- str_replace_all(exp_label,
                                          "bolditalic\\(.*?\\)",
                                          "phantom(\\0)")

    graphics::text(
      x = x_pos,
      y = y_pos,
      labels = eval(parse(text = exp_label)),
      col = ifelse(alpha == 1, rgb_blue_code, rgb_grey_prose),
      family = font_family,
      cex = cex,
      adj = adj
    )


    if (alpha == 1) {
      graphics::text(
        x = x_pos,
        y = y_pos,
        labels = eval(parse(text = exp_label_non_code)),
        col = rgb_grey_prose,
        family = font_family,
        cex = cex,
        adj = adj
      )
    }

    showtext::showtext_end()
    grDevices::dev.off()
    slide
  }