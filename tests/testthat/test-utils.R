test_that("group_list works with named lists", {
  l_to_group <- list(
    a = list(x = 34, y = 45),
    b = list(x = 98, y = 45),
    c = list(x = 34, y = 78)
  )

  l_by_x <- list(
    "34" = list(
      a = list(x = 34, y = 45),
      c = list(x = 34, y = 78)
    ),
    "98" = list(
      b = list(x = 98, y = 45)
    )
  )
  l_by_y <- list(
    "45" = list(
      a = list(x = 34, y = 45),
      b = list(x = 98, y = 45)
    ),
    "78" = list(
      c = list(x = 34, y = 78)
    )
  )

  expect_equal(group_list(l_to_group, "x"), l_by_x)
  expect_equal(group_list(l_to_group, "y"), l_by_y)
})

test_that("group_list works with unnamed lists", {
  l_to_group_unnamed <- list(
    a = list(x = 34, y = 45),
    list(x = 40, y = 78),
    b = list(x = 98, y = 45),
    list(x = 34, y = 78)
  )

  l_by_x <- list(
    "34" = list(
      a = list(x = 34, y = 45),
      list(x = 34, y = 78)
    ),
    "40" = list(
      list(x = 40, y = 78)
    ),
    "98" = list(
      b = list(x = 98, y = 45)
    )
  )
  l_by_y2 <- list(
    "45" = list(
      a = list(x = 34, y = 45),
      b = list(x = 98, y = 45)
    ),
    "78" = list(
      list(x = 40, y = 78),
      list(x = 34, y = 78)
    )
  )

  expect_equal(group_list(l_to_group_unnamed, "x"), l_by_x)
  expect_equal(group_list(l_to_group_unnamed, "y"), l_by_y2)
})
