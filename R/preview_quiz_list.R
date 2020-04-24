#' Include an image to preview quiz
#'
#' @param my_quiz Quiz as a string
#'
#' @return
#' @export
#'
#' @examples
preview_quiz_list <- function(my_quiz) {

  qz_list$answers %>%
    dplyr::mutate(text = forcats::fct_inorder(text) %>% forcats::fct_rev()) %>%
    ggplot2::ggplot(ggplot2::aes(x = 1, y = text)) +
    ggplot2::geom_label(ggplot2::aes(label = text, fill = is_correct), alpha = 0.6) +
    ggplot2::scale_fill_manual(values = c("red", "green"), guide = FALSE) +
    ggplot2::labs(
      title = "Quiz Preview",
      subtitle = stringr::str_wrap(qz_list$question)
    ) +
    ggraph::theme_graph()
}