# Main database module
# Import all database modules and expose their functions

# Load individual database modules
source("database/db_init.R")
source("database/db_auth.R")
source("database/db_files.R")
source("database/db_notes.R")
source("database/db_planning.R")
source("database/db_utils.R")

# Initialize the database on load
setup_database()