test_that("Correctly serializes a server message", {
  msg <- server_message("foo", list(bar = c("baz", "bal"), group = NA))
  serialized <- '{"sender":"server","type":"foo","data":{"bar":["baz","bal"],"group":[null]}}'
  expect_equal(as.character(msg), serialized)
})

test_that("Correctly handles selection message from client", {

  cases <- split(0:31, factor(floor(31:0 / 4)))
  msg <- list(data = cases)
  output <- list(`Group 1` = 1:4,
                 `Group 2` = 5:8,
                 `Group 3` = 9:12,
                 `Group 4` = 13:16,
                 `Group 1 Transient` = 17:20,
                 `Group 2 Transient` = 21:24,
                 `Group 3 Transient` = 25:28,
                 `Group 4 Transient` = 29:32)

  expect_equal(message_handlers$selected(msg), output)
})

?expect_condition()
