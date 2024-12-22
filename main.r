library(httpuv)
source("handlers/user.r")

port <- as.integer(Sys.getenv("PORT", "6011"))
initialize_db()
server <- startServer("0.0.0.0", port, list(call = user_handler))

repeat {
  service()
  Sys.sleep(0.01)
}
