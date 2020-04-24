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

  my_quiz <- stringr::str_squish(my_quiz)

  my_quiz <- jsonlite::fromJSON(my_quiz, simplifyDataFrame = FALSE)

  mc_hammer_test(my_quiz)

  mc_hammer_type_test(my_quiz, quiz_type)

  mc_hammer_list(my_quiz, quiz_id, quiz_type)
}

