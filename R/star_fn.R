#' Title
#'
#' @param fn_name
#' @param pkg_name
#' @param toolbox_type
#'
#' @return
#' @export
#'
#' @examples
star_fn <- function(fn_name, pkg_name, top_caption = NULL, toolbox_type, highlight = NULL, tweak_fn_size = 1) {
  setup_fonts()
  margins <- list(
    top = 100,
    right = 195,
    bottom = 120,
    left = 115
  )

  template_path <- switch(toolbox_type,
                          shiny = "star_fn_shiny.png")
  slide <- prepare_template(caption = NULL,
                            template_path = template_path)

  fn_name <- stringr::str_remove(fn_name, "\\(\\)") %>% paste0("()")
  if(!is.null(highlight)) {
    highlighted_fn_name <- stringr::str_replace_all(fn_name,
                                                    stringr::str_glue("`{highlight}`") %>%
                                                      purrr::set_names(highlight))
  }
  slide$obj <- write_on_slide(slide$obj,
                              highlighted_fn_name,
                          x_pos = 1500,
                          y_pos = 400,
                          adj = 1,
                          cex = 11 * tweak_fn_size,
                          alpha = 1,
                          prose_family = "firacode",
                          prose_color = "black",
                          code_color = rgb(162, 0, 4, alpha = 255, maxColorValue = 255))

  wrapped_pkg_name <- paste0("From the {", pkg_name, "} package")
  slide$obj <- write_on_slide(slide$obj,
                              wrapped_pkg_name,
                              x_pos = 1500,
                              y_pos = 530,
                              adj = 1,
                              cex = 4.5,
                              alpha = 1,
                              prose_family = "kalam")

  slide$obj <- write_on_slide(slide$obj,
                              toupper(top_caption),
                              x_pos = 1600,
                              y_pos = 85,
                              adj = 1,
                              cex = 4.5,
                              alpha = 1,
                              prose_family = "kelson",
                              prose_color = rgb(100, 100, 100, alpha = 255, maxColorValue = 255))

  slide$obj
}