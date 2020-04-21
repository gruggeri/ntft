#' Convert JSON quiz to HTML
#'
#' @param my_quiz Quiz as a string in JSON format
#' @param quiz_id Unique quiz id as a string
#' @param quiz_type MultipleChoiceQuizz or SingleChoiceQuizz, as character value
#'
#' @return
#' @export
#'
#' @examples
mc_hammer <- function(my_quiz, quiz_id, quiz_type = c("MultipleChoiceQuizz", "SingleChoiceQuizz")) {

  quiz_type <- match.arg(quiz_type)

  my_quiz <-
    my_quiz %>%
    stringr::str_replace("question:", '"question":') %>%
    stringr::str_replace("answers:", '"answers":') %>%
    stringr::str_replace("success_message:", '"success_message":') %>%
    stringr::str_replace_all("text:", '"text":') %>%
    stringr::str_replace_all("hint:", '"hint":') %>%
    stringr::str_replace_all("is_correct:", '"is_correct":') %>%
    stringr::str_replace_all('“', '"') %>%
    stringr::str_replace_all('”', '"')

  quiz_list_test <- jsonlite::fromJSON(my_quiz, simplifyDataFrame = FALSE)

  assertthat::assert_that(
    assertthat::are_equal(0, length(setdiff(names(quiz_list_test), c(
      "question",
      "answers",
      "success_message"
    )))),
    msg = "Cannot find key: question, answers or
      success_message in your quiz!"
  )

  quiz_list_test %>%
    purrr::pluck("answers") %>%
    purrr::iwalk(
      ~ assertthat::assert_that(
        assertthat::are_equal(0, length(setdiff(
          names(.x),
          c("text", "hint", "is_correct")
        ))),
        msg = stringr::str_glue("Cannot find key (text, hint or is_correct) in answer {.y}!")
      )
    )

  assertthat::assert_that(quiz_list_test %>%
                            purrr::pluck("answers") %>%
                            purrr::map_lgl(~ is.logical(.x$is_correct)) %>%
                            all(), msg = "Some key=is_correct values are not boolean")

  assertthat::assert_that(quiz_list_test %>%
                            purrr::pluck("answers") %>%
                            purrr::map_lgl(~ is.character(.x$hint)) %>%
                            all(), msg = "Not all key=hints values are characters")

  assertthat::assert_that(quiz_list_test %>%
                            purrr::pluck("answers") %>%
                            purrr::map_lgl(~ is.character(.x$text)) %>%
                            all(), msg = "Not all key= text values are character")


  answers_lgls <- purrr::map_lgl(quiz_list_test$answers, "is_correct")

  switch(quiz_type,
         MultipleChoiceQuizz = assertthat::assert_that(any(answers_lgls),
                                                       msg = "A least one is_correct should be true"
         ),
         SingleChoiceQuizz = assertthat::assert_that(sum(answers_lgls) == 1,
                                                     msg = "Only one is_correct should be true"
         )
  )

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


  quiz_list <- jsonlite::fromJSON(my_quiz, simplifyDataFrame = FALSE) %>%
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

