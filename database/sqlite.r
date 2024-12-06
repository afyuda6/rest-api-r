library(DBI)
library(RSQLite)

initialize_db <- function() {
  con <- dbConnect(RSQLite::SQLite(), dbname = "rest_api_r.db")

  dbExecute(con, "
    DROP TABLE IF EXISTS users
  ")

  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    )
  ")

  dbDisconnect(con)
}

get_db_connection <- function() {
  dbConnect(RSQLite::SQLite(), dbname = "rest_api_r.db")
}
