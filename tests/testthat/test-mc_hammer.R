
my_valid_quiz <- '
{
"question": "Which function do we usually use to load shapes?",
"answers": [
{"text": "`read_st()`",
"hint": "",
"is_correct": false},
{"text": "`read_csv()`",
"hint": "Nope. Usually shapes are not stored into .csv files, although this might happen sometimes.",
"is_correct": false},
{"text": "`st_read()`",
"hint": "Bravo.",
"is_correct": true},
{"text": "`st_read_csv()`",
"hint": "Nope.",
"is_correct": false},
{"text": "`raster()`",
"hint": "Nope. This function is used to load rasters, not shapes.",
"is_correct": false}
],
"success_message": "Good job!"
}

'

my_wrong_quiz <- '
{
"question": "Which function do we usually use to load shapes?",
"answers": [
{"text": "`read_st()`",
"hint": "",
"is_correct": false},
{"text": "`read_csv()`",
"hint": "Nope. Usually shapes are not stored into .csv files, although this might happen sometimes.",
"is_correct": false},
{"text": "`st_read()`",
"hint": "Bravo.",
"is_correct": false},
{"text": true,
"hint": "Nope.",
"is_correct": true},
{"text": "`raster()`",
"hint": "Nope. This function is used to load rasters, not shapes.",
"is_correct": false}
],
"success_message": "Good job!"
}

'



test_that("wrong quiz throw error", {
  expect_error(mc_hammer(my_wrong_quiz, quiz_id= "hammerit", quiz_type = "MultipleChoiceQuizz"))
})

test_that("valid quiz passes", {
  expect_equal(as.character(mc_hammer(my_valid_quiz, quiz_id= "hammerit", quiz_type = "MultipleChoiceQuizz")),
              '<div data-type="MultipleChoiceQuizz" data-permanent-id="hammerit" data-json="{&quot;description_md&quot;:&quot;Which function do we usually use to load shapes?&quot;,&quot;answers_attributes&quot;:[{&quot;text_md&quot;:&quot;`read_st()`&quot;,&quot;hint_md&quot;:&quot;&quot;,&quot;correct&quot;:false,&quot;permanent_id&quot;:1},{&quot;text_md&quot;:&quot;`read_csv()`&quot;,&quot;hint_md&quot;:&quot;Nope. Usually shapes are not stored into .csv files, although this might happen sometimes.&quot;,&quot;correct&quot;:false,&quot;permanent_id&quot;:2},{&quot;text_md&quot;:&quot;`st_read()`&quot;,&quot;hint_md&quot;:&quot;Bravo.&quot;,&quot;correct&quot;:true,&quot;permanent_id&quot;:3},{&quot;text_md&quot;:&quot;`st_read_csv()`&quot;,&quot;hint_md&quot;:&quot;Nope.&quot;,&quot;correct&quot;:false,&quot;permanent_id&quot;:4},{&quot;text_md&quot;:&quot;`raster()`&quot;,&quot;hint_md&quot;:&quot;Nope. This function is used to load rasters, not shapes.&quot;,&quot;correct&quot;:false,&quot;permanent_id&quot;:5}],&quot;success_message_md&quot;:&quot;Good job!&quot;}"></div>')
})

