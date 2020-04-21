#' Putting quotes for lazy people
#'
#' @param my_quiz Quiz as a string
#'
#' @return
#' @export
#'
#' @examples
mc_lazy_quotes <- function(my_quiz){

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

  my_quiz

}
