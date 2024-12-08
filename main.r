library(httpuv)
source("handlers/user.r")

api <- function(req) {
  path <- req$PATH_INFO

  if (path == "/users" || path == "/users/") {
    return(user_handle(req))
  } else {
    return(list(
      status = 404,
      headers = list("Content-Type" = "application/json"),
      body = jsonlite::toJSON(list(
        status = "Not Found",
        code = 404
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
}

initialize_db()

server <- startServer("0.0.0.0", 6011, list(call = api))