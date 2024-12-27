library(jsonlite)
source("database/sqlite.r")

add_cors_headers <- function() {
  return(list(
    "Access-Control-Allow-Origin" = "*",
    "Access-Control-Allow-Methods" = "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers" = "Content-Type"
  ))
}

handle_read_users <- function() {
  con <- get_db_connection()
  users <- dbGetQuery(con, "SELECT * FROM users")
  dbDisconnect(con)
  return(list(
    status = 200,
    headers = c("Content-Type" = "application/json", add_cors_headers()),
    body = jsonlite::toJSON(list(
      status = "OK",
      code = 200,
      data = users
    ), pretty = TRUE, auto_unbox = TRUE)
  ))
}

handle_create_user <- function(req) {
  body_raw <- req$rook.input$read_lines()
  if (length(body_raw) == 0 || body_raw == "") {
    return(list(
      status = 400,
      headers = c("Content-Type" = "application/json", add_cors_headers()),
      body = jsonlite::toJSON(list(
        status = "Bad Request",
        code = 400,
        errors = "Missing 'name' parameter"
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
  body <- utils::URLdecode(body_raw)
  body_pairs <- strsplit(body, "&")[[1]]
  parsed_body <- list()
  for (pair in body_pairs) {
    parts <- strsplit(pair, "=")[[1]]
    if (length(parts) == 2) {
      key <- parts[1]
      value <- parts[2]
      parsed_body[[key]] <- value
    }
  }
  if (is.null(parsed_body$name) || parsed_body$name == "+") {
    return(list(
      status = 400,
      headers = c("Content-Type" = "application/json", add_cors_headers()),
      body = jsonlite::toJSON(list(
        status = "Bad Request",
        code = 400,
        errors = "Missing 'name' parameter"
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
  con <- get_db_connection()
  dbExecute(con, "INSERT INTO users (name) VALUES (?)", params = list(parsed_body$name))
  dbDisconnect(con)
  return(list(
    status = 201,
    headers = c("Content-Type" = "application/json", add_cors_headers()),
    body = jsonlite::toJSON(list(
      status = "Created",
      code = 201
    ), pretty = TRUE, auto_unbox = TRUE)
  ))
}

handle_update_user <- function(req) {
  body_raw <- req$rook.input$read_lines()
  if (length(body_raw) == 0 || body_raw == "") {
    return(list(
      status = 400,
      headers = c("Content-Type" = "application/json", add_cors_headers()),
      body = jsonlite::toJSON(list(
        status = "Bad Request",
        code = 400,
        errors = "Missing 'id' or 'name' parameter"
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
  body <- utils::URLdecode(body_raw)
  body_pairs <- strsplit(body, "&")[[1]]
  parsed_body <- list()
  for (pair in body_pairs) {
    parts <- strsplit(pair, "=")[[1]]
    if (length(parts) == 2) {
      key <- parts[1]
      value <- parts[2]
      parsed_body[[key]] <- value
    }
  }
  if (is.null(parsed_body$name) ||
    parsed_body$name == "+" ||
    is.null(parsed_body$id) ||
    parsed_body$id == "+") {
    return(list(
      status = 400,
      headers = c("Content-Type" = "application/json", add_cors_headers()),
      body = jsonlite::toJSON(list(
        status = "Bad Request",
        code = 400,
        errors = "Missing 'id' or 'name' parameter"
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
  con <- get_db_connection()
  dbExecute(con, "UPDATE users SET name = ? WHERE id = ?", params = list(parsed_body$name, parsed_body$id))
  dbDisconnect(con)
  return(list(
    status = 200,
    headers = c("Content-Type" = "application/json", add_cors_headers()),
    body = jsonlite::toJSON(list(
      status = "OK",
      code = 200
    ), pretty = TRUE, auto_unbox = TRUE)
  ))
}

handle_delete_user <- function(req) {
  body_raw <- req$rook.input$read_lines()
  if (length(body_raw) == 0 || body_raw == "") {
    return(list(
      status = 400,
      headers = c("Content-Type" = "application/json", add_cors_headers()),
      body = jsonlite::toJSON(list(
        status = "Bad Request",
        code = 400,
        errors = "Missing 'id' parameter"
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
  body <- utils::URLdecode(body_raw)
  body_pairs <- strsplit(body, "&")[[1]]
  parsed_body <- list()
  for (pair in body_pairs) {
    parts <- strsplit(pair, "=")[[1]]
    if (length(parts) == 2) {
      key <- parts[1]
      value <- parts[2]
      parsed_body[[key]] <- value
    }
  }
  if (is.null(parsed_body$id) || parsed_body$id == "+") {
    return(list(
      status = 400,
      headers = c("Content-Type" = "application/json", add_cors_headers()),
      body = jsonlite::toJSON(list(
        status = "Bad Request",
        code = 400,
        errors = "Missing 'id' parameter"
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
  con <- get_db_connection()
  dbExecute(con, "DELETE FROM users WHERE id = ?", params = list(parsed_body$id))
  dbDisconnect(con)
  return(list(
    status = 200,
    headers = c("Content-Type" = "application/json", add_cors_headers()),
    body = jsonlite::toJSON(list(
      status = "OK",
      code = 200
    ), pretty = TRUE, auto_unbox = TRUE)
  ))
}

user_handler <- function(req) {
  path <- req$PATH_INFO
  if (path == "/users" || path == "/users/") {
    method <- req$REQUEST_METHOD
    if (method == "GET") {
      handle_read_users()
    } else if (method == "POST") {
      handle_create_user(req)
    } else if (method == "PUT") {
      handle_update_user(req)
    } else if (method == "DELETE") {
      handle_delete_user(req)
    } else if (method == "OPTIONS") {
      return(list(
        status = 200,
        headers = c("Content-Type" = "application/json", add_cors_headers()),
        body = ""
      ))
    } else {
      return(list(
        status = 405,
        headers = c("Content-Type" = "application/json", add_cors_headers()),
        body = jsonlite::toJSON(list(
          status = "Method Not Allowed",
          code = 405
        ), pretty = TRUE, auto_unbox = TRUE)
      ))
    }
  } else {
    return(list(
      status = 404,
      headers = c("Content-Type" = "application/json", add_cors_headers()),
      body = jsonlite::toJSON(list(
        status = "Not Found",
        code = 404
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
}
