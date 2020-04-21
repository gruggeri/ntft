my_old_test <- '
{
question: "How many pairs of coordinates (points) are used to draw Switzerland?",
answers: [
{text: "25",
hint: "",
is_correct: false},
{text: "26",
hint: "Nope.",
is_correct: false},
{text: "21",
hint: "Nope.",
is_correct: false},
{text: "44",
hint: "Nope.",
is_correct: false},
{text: "24",
hint: "Correct!",
is_correct: true}
],
success_message: "Good job! If you use `filter(SOVEREIGNT == "Switzerland") %>% select(SOVEREIGNT)` you can find explore the geometry as it is the first argument of the list."
}

'

my_new_test <- '
{
"question": "How many pairs of coordinates (points) are used to draw Switzerland?",
"answers": [
{"text": "25",
"hint": "",
"is_correct": false},
{"text": "26",
"hint": "Nope.",
"is_correct": false},
{"text": "21",
"hint": "Nope.",
"is_correct": false},
{"text": "44",
"hint": "Nope.",
"is_correct": false},
{"text": "24",
"hint": "Correct!",
"is_correct": true}
],
"success_message": "Good job! If you use `filter(SOVEREIGNT == "Switzerland") %>% select(SOVEREIGNT)` you can find explore the geometry as it is the first argument of the list."
}

'




test_that("the test has been made lazy proof", {
  expect_equal(mc_lazy_quotes(my_old_test), my_new_test)
})
