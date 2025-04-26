Load libraries...


# Load environment variables
load_dot_env()


#==============================================================================
# Source module files
#==============================================================================

# Core modules
source("database/database.R")           # Database connections and operations
source("database/auth.R")               # Authentication functionality

# Feature modules
source("functions/analysis.R")         # Strategy analysis
source("functions/api.R")             # APIs
source("functions/auth-google.R")     # Google Auth Functions
#source("functions/authpanel-ui.R")         # Financial analysis
source("functions/chargebee.R")       # Payments

# UI components
source("ui/auth-ui.R")         # Login/registration UI
source("ui/dashboard-ui.R")    # Main dashboard UI


# Server components
source("server/server.R")         # Authentication server logic


# Utilities
source("webhooks/plumberapi.R")      # External API integration


shinyApp(ui = ui, server = server)
