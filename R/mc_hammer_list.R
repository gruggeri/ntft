#' Convert R list quiz to HTML
#'
#' @param my_quiz Quiz as a list
#' @param quiz_id Unique quiz id as a string
#' @param quiz_type MultipleChoiceQuizz or SingleChoiceQuizz, as character value
#'
#' @return
#' @export
#'
#' @examples
mc_hammer_list <- function(my_quiz, quiz_id,
                           quiz_type = c("MultipleChoiceQuizz", "SingleChoiceQuizz")) {


  quiz_type <- match.arg(quiz_type)

  mc_hammer_test(my_quiz)
  mc_hammer_type_test(my_quiz, quiz_type)

  rename_patterns_1 <- list(
    question = "description_md",
    answers = "answers_attributes",
    success_message = "success_message_md"
  )

  rename_patterns_2 <- list(
    text = "text_md",
    hint = "hint_md",
    is_correct = "correct",
    permanent_id = "permanent_id"
  )


  quiz_list <- my_quiz %>%
    purrr::modify_at("answers", ~ purrr::imap(
      .x,
      ~  purrr::list_modify(.x, permanent_id = .y)
    )) %>%
    rlang::set_names(~ unlist(magrittr::extract(rename_patterns_1, .))) %>%
    purrr::modify_at(
      "answers_attributes",
      ~ purrr::imap(
        .x,
        ~ rlang::set_names(.x, ~ unlist(magrittr::extract(rename_patterns_2, .)))
      )
    )

  quiz_list <-
    htmltools::div(
      "data-type" = quiz_type,
      "data-permanent-id" = quiz_id,
      "data-json" = jsonlite::toJSON(quiz_list, auto_unbox = TRUE)
    )

  quiz_list
}