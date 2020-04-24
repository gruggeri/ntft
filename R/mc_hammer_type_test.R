#' Test if single quiz or multiple quiz are done correctly
#'
#' @param my_quiz Quiz as a list
#' @param quiz_type MultipleChoiceQuizz or SingleChoiceQuizz, as character value
#'
#' @return
#'
#' @examples
mc_hammer_type_test <- function(my_quiz, quiz_type ){

  answers_lgls <- purrr::map_lgl(my_quiz$answers, "is_correct")

  switch(quiz_type,
         MultipleChoiceQuizz = assertthat::assert_that(any(answers_lgls),
                                                       msg = "A least one is_correct should be true"
         ),
         SingleChoiceQuizz = assertthat::assert_that(sum(answers_lgls) == 1,
                                                     msg = "Only one is_correct should be true"
         )
  )

}
