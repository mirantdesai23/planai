source("ui/components/styles.R")      # Load styles
source("ui/components/header.R")      # Load header
source("ui/components/sidebar.R")     # Load sidebar
source("ui/auth/auth_module.R") 
source("ui/components/dashboard_body.R")
# Load authentication modules

# Create the UI
ui <- fluidPage(
  use_styles(),  # Apply styles
  
  tags$div(style = "position: absolute; top: -100px;",
           textOutput("clock")
  ),
  useShinyjs(),
  
  # Authentication panel
  auth_panel_ui,
  
  # Password reset panel
#  hidden(reset_password_ui()),
  
  # Main application
  hidden(
    div(
      id = "main-panel",
      dashboardPage(
        skin = "black-light",
        dashboard_header(),  # From header.R
        dashboard_sidebar(), # From sidebar.R
        dashboard_body()     # Composed of all tab modules
      )
    )
  )
)