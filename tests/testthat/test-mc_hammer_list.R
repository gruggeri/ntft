


my_valid_quiz_list <- list(
  question = "Enter Question",
  answers = list(
    list(text = "Hint 1 ",
         hint = "<<Enter Hint>>",
         is_correct = FALSE),
    list(text = "Hint 2",
         hint = "<<Enter Hint>>",
         is_correct = FALSE),
    list(text = "Sol`ut`ion",
         hint = "Enter Hint",
         is_correct = TRUE)
  ),
  success_message = "Enter Success Message"
)


mywrongquizlist <- list(
  question = "Enter Question",
  answers = list(
    list(hint = "<<Enter Hint>>",
         is_correct = FALSE),
    list(text = "Hint 2",
         hint = "<<Enter Hint>>",
         is_correct = FALSE),
    list(text = "Sol`ut`

         ion",
         hint = "Enter Hint",
         is_correct = TRUE)
  ),
  success_message = "Enter Success Message"
)



test_that("wrong  list quiz throw error", {
  expect_error(mc_hammer_list(mywrongquizlist, quiz_id= "hammerit", quiz_type = "MultipleChoiceQuizz"))
})


testthat::test_that("valid list quiz passes", {
  testthat::expect_equal(as.character(mc_hammer_list(my_valid_quiz_list, quiz_id = "hammerthemall", quiz_type = "MultipleChoiceQuiz")),
               '<div data-type="MultipleChoiceQuizz" data-permanent-id="hammerthemall" data-json="{&quot;description_md&quot;:&quot;Enter Question&quot;,&quot;answers_attributes&quot;:[{&quot;text_md&quot;:&quot;Hint 1 &quot;,&quot;hint_md&quot;:&quot;&lt;&lt;Enter Hint&gt;&gt;&quot;,&quot;correct&quot;:false,&quot;permanent_id&quot;:1},{&quot;text_md&quot;:&quot;Hint 2&quot;,&quot;hint_md&quot;:&quot;&lt;&lt;Enter Hint&gt;&gt;&quot;,&quot;correct&quot;:false,&quot;permanent_id&quot;:2},{&quot;text_md&quot;:&quot;Sol`ut`ion&quot;,&quot;hint_md&quot;:&quot;Enter Hint&quot;,&quot;correct&quot;:true,&quot;permanent_id&quot;:3}],&quot;success_message_md&quot;:&quot;Enter Success Message&quot;}"></div>')
})
