assert_valid_matches_sequence <- function(tokens_matches) {
  if (!identical(unique(rle(tokens_matches)$lengths), 2L)) {
    stop("It looks like you have some unclosed",
         " or nested markdown tokens in a line.",
         " See matches below:\n",
         paste(tokens_matches, collapse = ", "))
  }
  tokens_matches
}

check_token_syntax <- function(txt_line_md, patterns) {
  rgxs_to_search <- purrr::map_chr(patterns, "rgx")
  grouped_rgx <- stringi::stri_c("(",rgxs_to_search,")") %>%
    stringi::stri_c(collapse = "|")

  tokens_matrix <- stringi::stri_match_all_regex(txt_line_md, grouped_rgx)[[1]]
  tokens_matches <- tokens_matrix[,1]
  if (all(is.na(tokens_matches))) {
    return(character(0))
  }
  assert_valid_matches_sequence(tokens_matches)

  last_non_na_col_per_row <- apply(tokens_matrix, 1, function(x) max(which(!is.na(x))))
  last_non_na_col_per_row_dedup <- last_non_na_col_per_row[seq(1, length(last_non_na_col_per_row), 2)]
  #positions_of_matches <- stringi::stri_locate_all_regex(txt_line_md, grouped_rgx)[[1]]
  content_of_matches <- stringi::stri_split_regex(txt_line_md, grouped_rgx)[[1]]

  non_plain <- data.frame(
    name = names(rgxs_to_search)[last_non_na_col_per_row_dedup - 1],
    #rgx = rgxs_to_search[last_non_na_col_per_row - 1],
    #matches = tokens_matches,
    stringsAsFactors = FALSE
  )

  plain <- data.frame(
    name = rep("plain", nrow(non_plain) + 1),
    stringsAsFactors = FALSE
  )

  dplyr::bind_rows(
    dplyr::mutate(plain, row_n = dplyr::row_number()),
    dplyr::mutate(non_plain, row_n = dplyr::row_number()),
    .id = "src_id"
  ) %>%
    dplyr::arrange(row_n, src_id) %>%
    dplyr::bind_cols(content = content_of_matches) %>%
    dplyr::select(-src_id, -row_n)
}

sym_to_fun <- function(txt_line_md, patterns) {
  token_to_search <- check_token_syntax(txt_line_md, patterns)

  txt_line_fun <- paste0("plain(", txt_line_md, ")")
  if (length(token_to_search) == 0)
    return(txt_line_fun)

  txt_line_fun <- list()
  if(token_to_search$start[1] > 0) {
    txt_line_fun <- stringi::stri_c(
      "plain(", stringi::stri_split(txt_line_md, )
    )
  }

  for(i in seq(1, 1:nrow(token_to_search), 2)) {

  }
}


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



text_colors <- list(
  darkblue = list(red=6, green=58, blue=109),
  medgrey = list(red=76, green=76, blue=76)
)





md_to_exp <- function(sentence) {
  md_bold <- list(md = "**",
                  rgx = "\\*\\*",
                  fun = "bold",
                  color = list(red=76, green=76, blue=76))
  md_italic <- list(md = "*",
                    rgx = "\\*",
                    fun = "italic",
                    color = list(red=76, green=76, blue=76))
  md_code <- list(md = "`",
                  rgx = "`",
                  fun = "bolditalic",
                  color = list(red=6, green=58, blue=109))

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