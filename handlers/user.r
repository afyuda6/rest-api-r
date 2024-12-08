source("database/sqlite.r")

handle_read_users <- function() {
  con <- get_db_connection()
  users <- dbGetQuery(con, "SELECT * FROM users")
  dbDisconnect(con)
  return(users)
}

handle_create_user <- function(name) {
  con <- get_db_connection()
  dbExecute(con, "INSERT INTO users (name) VALUES (?)", params = list(name))
  dbDisconnect(con)
  return(list(message = message))
}

handle_update_user <- function(name, id) {
  con <- get_db_connection()
  dbExecute(con, "UPDATE users SET name = ? WHERE id = ?", params = list(name, id))
  dbDisconnect(con)
  return(list(message = message))
}

handle_delete_user <- function(id) {
  con <- get_db_connection()
  dbExecute(con, "DELETE FROM users WHERE id = ?", params = list(id))
  dbDisconnect(con)
  return(list(message = message))
}

user_handle <- function(req) {
  method <- req$REQUEST_METHOD

  if (method == "GET") {
    users <- handle_read_users()
    return(list(
      status = 200,
      headers = list("Content-Type" = "application/json"),
      body = jsonlite::toJSON(list(
        status = "OK",
        code = 200,
        data = users
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  } else if (method == "POST") {
    body_raw <- req$rook.input$read_lines()
    if (length(body_raw) == 0 || body_raw == "") {
      return(list(
        status = 400,
        headers = list("Content-Type" = "application/json"),
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
        headers = list("Content-Type" = "application/json"),
        body = jsonlite::toJSON(list(
          status = "Bad Request",
          code = 400,
          errors = "Missing 'name' parameter"
        ), pretty = TRUE, auto_unbox = TRUE)
      ))
    }

    handle_create_user(parsed_body$name)
    return(list(
      status = 201,
      headers = list("Content-Type" = "application/json"),
      body = jsonlite::toJSON(list(
        status = "Created",
        code = 201
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  } else if (method == "PUT") {
    body_raw <- req$rook.input$read_lines()
    if (length(body_raw) == 0 || body_raw == "") {
      return(list(
        status = 400,
        headers = list("Content-Type" = "application/json"),
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

    if (is.null(parsed_body$name) || parsed_body$name == "+" || is.null(parsed_body$id) || parsed_body$id == "+") {
      return(list(
        status = 400,
        headers = list("Content-Type" = "application/json"),
        body = jsonlite::toJSON(list(
          status = "Bad Request",
          code = 400,
          errors = "Missing 'id' or 'name' parameter"
        ), pretty = TRUE, auto_unbox = TRUE)
      ))
    }

    handle_update_user(parsed_body$name, parsed_body$id)
    return(list(
      status = 200,
      headers = list("Content-Type" = "application/json"),
      body = jsonlite::toJSON(list(
        status = "OK",
        code = 200
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  } else if (method == "DELETE") {
    body_raw <- req$rook.input$read_lines()
    if (length(body_raw) == 0 || body_raw == "") {
      return(list(
        status = 400,
        headers = list("Content-Type" = "application/json"),
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
        headers = list("Content-Type" = "application/json"),
        body = jsonlite::toJSON(list(
          status = "Bad Request",
          code = 400,
          errors = "Missing 'id' parameter"
        ), pretty = TRUE, auto_unbox = TRUE)
      ))
    }

    handle_delete_user(parsed_body$id)
    return(list(
      status = 200,
      headers = list("Content-Type" = "application/json"),
      body = jsonlite::toJSON(list(
        status = "OK",
        code = 200
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  } else {
    return(list(
      status = 405,
      headers = list("Content-Type" = "application/json"),
      body = jsonlite::toJSON(list(
        status = "Method Not Allowed",
        code = 405
      ), pretty = TRUE, auto_unbox = TRUE)
    ))
  }
}
