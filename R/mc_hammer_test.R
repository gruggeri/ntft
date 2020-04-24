#' Test parameters of the list are correct
#'
#' @param my_test_quiz Quiz as a list
#'
#' @return
#'
#' @examples
mc_hammer_test <- function(my_test_quiz){

  assertthat::assert_that(
    assertthat::are_equal(0, length(setdiff(names(my_test_quiz), c(
      "question",
      "answers",
      "success_message"
    )))),
    msg = "Cannot find key: question, answers or
      success_message in your quiz!"
  )

  my_test_quiz %>%
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

  assertthat::assert_that(my_test_quiz %>%
                            purrr::pluck("answers") %>%
                            purrr::map_lgl(~ is.logical(.x$is_correct)) %>%
                            all(), msg = "Some key=is_correct values are not boolean")

  assertthat::assert_that(my_test_quiz %>%
                            purrr::pluck("answers") %>%
                            purrr::map_lgl(~ is.character(.x$hint)) %>%
                            all(), msg = "Not all key=hints values are characters")

  assertthat::assert_that(my_test_quiz %>%
                            purrr::pluck("answers") %>%
                            purrr::map_lgl(~ is.character(.x$text)) %>%
                            all(), msg = "Not all key= text values are character")




}