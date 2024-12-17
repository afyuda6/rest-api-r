library(httpuv)
source("handlers/user.r")

initialize_db()
server <- startServer("0.0.0.0", 6011, list(call = user_handler))