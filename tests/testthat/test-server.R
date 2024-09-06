test_that("Correctly serializes a server message", {
  msg <- format_message(list(type = "foo"))
  serialized <- '{"sender":"server","target":"scene","type":"foo","data":{}}'

  expect_equal(as.character(msg), serialized)
})

