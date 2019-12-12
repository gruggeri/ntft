md_sym <- list(
  md_bold = list(
    md = "**",
    rgx = "\\*\\*",
    fun = "bold",
    color = "medgrey"
  ),
  md_italic = list(
    md = "*",
    rgx = "\\*",
    fun = "italic",
    color = "medgrey"
  ),
  md_code = list(
    md = "`",
    rgx = "`",
    fun = "bolditalic",
    color = "darkblue"
  ),
  md_underline = list(
    md = "§",
    rgx = "§",
    fun = "underline",
    color = "darkblue"
  )
)

test_that("parse_token_syntax find patterns", {
  expect_error(parse_token_syntax("Hello **bla** test*r", md_sym))
  expect_equal(parse_token_syntax("Hello bla testr", md_sym), character(0))
  expect_equal(parse_token_syntax("Hello **bla** testr *bla*, §test§ zui **hope**", md_sym),
               data.frame(
                 name = c("plain", "md_bold", "plain", "md_italic",
                          "plain", "md_underline", "plain", "md_bold", "plain"),
                 content = c("Hello ", "bla",
                             " testr ", "bla", ", ", "test", " zui ", "hope", ""),
                 stringsAsFactors = FALSE
               ))
  expect_equal(parse_token_syntax("Hello **bla** testr **bla**, §test§ zui **hope**", md_sym),
               data.frame(
                 name = c("plain", "md_bold", "plain", "md_bold",
                          "plain", "md_underline", "plain", "md_bold", "plain"),
                 content = c("Hello ", "bla",
                             " testr ", "bla", ", ", "test", " zui ", "hope", ""),
                 stringsAsFactors = FALSE
               ))
})

test_that("sym_to_fun works", {
  expect_equal(sym_to_fun("Hello bla testr", md_sym), "plain(Hello bla testr)")
  # expect_error(sym_to_fun("Hello **bla** testr `bla`, §test§ zui **hope**", md_sym))
})
