
# Function to save a note
save_note <- function(username, title, content, category = NULL) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    # Check if note with this title already exists for this user
    result <- dbGetQuery(db,
                         "SELECT COUNT(*) as count FROM notes WHERE username = ? AND title = ?",
                         params = list(username, title)
    )
    
    if (result$count > 0) {
      # Update existing note
      dbExecute(db,
                "UPDATE notes SET content = ?, category = ?, updated_at = CURRENT_TIMESTAMP 
               WHERE username = ? AND title = ?",
                params = list(content, category, username, title)
      )
      return(list(success = TRUE, message = "Note updated successfully"))
    } else {
      # Insert new note
      dbExecute(db,
                "INSERT INTO notes (username, title, content, category) VALUES (?, ?, ?, ?)",
                params = list(username, title, content, category)
      )
      return(list(success = TRUE, message = "Note saved successfully"))
    }
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(list(success = FALSE, message = paste("Error saving note:", e$message)))
  })
}

# Function to load all notes for a user
load_notes <- function(username) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    result <- dbGetQuery(db,
                         "SELECT id, title, category, created_at, updated_at FROM notes 
                        WHERE username = ? ORDER BY updated_at DESC",
                         params = list(username)
    )
    
    return(result)
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(data.frame())
  })
}

# Function to get a specific note
get_note <- function(id, username) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    result <- dbGetQuery(db,
                         "SELECT * FROM notes WHERE id = ? AND username = ?",
                         params = list(id, username)
    )
    
    if (nrow(result) == 1) {
      return(result)
    }
    return(NULL)
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(NULL)
  })
}

# Function to delete a note
delete_note <- function(id, username) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    dbExecute(db,
              "DELETE FROM notes WHERE id = ? AND username = ?",
              params = list(id, username)
    )
    return(list(success = TRUE, message = "Note deleted successfully"))
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(list(success = FALSE, message = paste("Error deleting note:", e$message)))
  })
}






# Database setup function
setup_database <- function() {
  tryCatch({
    # Connect to SQLite database
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    # Check if tables exist
    tables_exist <- dbListTables(db)
    
    # Create users table if it doesn't exist
    if (!"users" %in% tables_exist) {
      dbExecute(db, "
        CREATE TABLE users (
          username TEXT PRIMARY KEY,
          password TEXT NOT NULL,
          email TEXT,
          role TEXT DEFAULT 'user',
          last_login TIMESTAMP,
          stripe_customer_id TEXT,
          chargebee_customer_id TEXT,
          subscription_id TEXT,
          subscription_status TEXT DEFAULT 'inactive',
          subscription_end_date TEXT
        )
      ")
      
      # Create initial admin user
      dbExecute(db, "
        INSERT INTO users (username, password, email, role, subscription_status)
        VALUES (?, ?, ?, ?, ?)",
                params = list(
                  "admin",
                  "admin123",
                  "admin@example.com",
                  "admin",
                  "active"  # Admin always has active subscription
                )
      )
    } else {
      # Check if subscription columns exist, add them if not
      column_info <- dbGetQuery(db, "PRAGMA table_info(users)")
      
      # Add missing columns if needed
      if (!"chargebee_customer_id" %in% column_info$name) {
        dbExecute(db, "ALTER TABLE users ADD COLUMN chargebee_customer_id TEXT")
      }
      if (!"subscription_id" %in% column_info$name) {
        dbExecute(db, "ALTER TABLE users ADD COLUMN subscription_id TEXT")
      }
      if (!"subscription_status" %in% column_info$name) {
        dbExecute(db, "ALTER TABLE users ADD COLUMN subscription_status TEXT DEFAULT 'inactive'")
      }
      if (!"subscription_end_date" %in% column_info$name) {
        dbExecute(db, "ALTER TABLE users ADD COLUMN subscription_end_date TEXT")
      }
    }
    
    
    # Create password_reset table if it doesn't exist
    if (!dbExistsTable(db, "password_reset")) {
      dbExecute(db, "
      CREATE TABLE password_reset (
        token TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP,
        used INTEGER DEFAULT 0,
        FOREIGN KEY (username) REFERENCES users(username)
      )
    ")
    }
    
    # Create strategy_data table if it doesn't exist
 # Create strategy_data table if it doesn't exist
if (!dbExistsTable(db, "strategy_data")) {
  dbExecute(db, "
      CREATE TABLE strategy_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        name TEXT NOT NULL,
        company_data TEXT,
        industry_data TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (username) REFERENCES users(username)
      )
    ")
}

# Create pitch_deck_data table if it doesn't exist
if (!dbExistsTable(db, "pitch_deck_data")) {
  dbExecute(db, "
      CREATE TABLE pitch_deck_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        name TEXT NOT NULL,
        mission_data TEXT,
        product_data TEXT,
        competitor_data TEXT,
        market_data TEXT,
        unit_economics TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (username) REFERENCES users(username)
      )
    ")
}

# Create business_model_canvas table if it doesn't exist
if (!dbExistsTable(db, "business_model_canvas")) {
  dbExecute(db, "
      CREATE TABLE business_model_canvas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        name TEXT NOT NULL,
        key_partners TEXT,
        key_activities TEXT,
        key_resources TEXT,
        value_propositions TEXT,
        customer_relationships TEXT,
        channels TEXT,
        revenue_streams TEXT,
        cost_structure TEXT,
        customer_segments TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (username) REFERENCES users(username)
      )
    ")
}
    # Create ai_strategy_analyses table if it doesn't exist
    if (!dbExistsTable(db, "ai_strategy_analyses")) {
      dbExecute(db, "
    CREATE TABLE ai_strategy_analyses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      name TEXT NOT NULL,
      analysis_type TEXT NOT NULL,
      analysis_content TEXT,
      company_data TEXT,
      industry_data TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (username) REFERENCES users(username)
    )
  ")
    }
    
    # Create ai_pitch_deck_analyses table if it doesn't exist
    if (!dbExistsTable(db, "ai_pitch_deck_analyses")) {
      dbExecute(db, "
    CREATE TABLE ai_pitch_deck_analyses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      name TEXT NOT NULL,
      analysis_type TEXT NOT NULL,
      analysis_content TEXT,
      source_data TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (username) REFERENCES users(username)
    )
  ")
    }
    
    # Create ai_bmc_analyses table if it doesn't exist
    if (!dbExistsTable(db, "ai_bmc_analyses")) {
      dbExecute(db, "
    CREATE TABLE ai_bmc_analyses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      name TEXT NOT NULL,
      analysis_content TEXT,
      source_data TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (username) REFERENCES users(username)
    )
  ")
    }
    
    if (!dbExistsTable(db, "notes")) {
      dbExecute(db, "
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT,
      category TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (username) REFERENCES users(username)
    )
  ")
    }
    
    
    
    # Create files table if it doesn't exist
    if (!dbExistsTable(db, "files")) {
      dbExecute(db, "
      CREATE TABLE files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        filename TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER,
        mime_type TEXT,
        upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (username) REFERENCES users(username)
      )
    ")
    }
    
    # Add to the setup_database() function in app11.r
    if (!dbExistsTable(db, "issues")) {
      dbExecute(db, "
    CREATE TABLE issues (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      issue_id TEXT NOT NULL,
      username TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      status TEXT NOT NULL,
      priority TEXT NOT NULL,
      assigned_to TEXT,
      created_date TEXT NOT NULL,
      due_date TEXT,
      resolution TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (username) REFERENCES users(username)
    )
  ")
    }
    
    # Add to setup_database() function in your database setup section:
    if (!dbExistsTable(db, "refined_strategy_analyses")) {
      dbExecute(db, "
    CREATE TABLE refined_strategy_analyses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      name TEXT NOT NULL,
      analysis_type TEXT NOT NULL,
      original_analysis_id INTEGER,
      refined_content TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (username) REFERENCES users(username),
      FOREIGN KEY (original_analysis_id) REFERENCES ai_strategy_analyses(id)
    )
  ")
    }
    
    # Add to setup_database() function in your database setup section:
    if (!dbExistsTable(db, "refined_pitch_deck_analyses")) {
      dbExecute(db, "
    CREATE TABLE refined_pitch_deck_analyses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      name TEXT NOT NULL,
      analysis_type TEXT NOT NULL,
      original_analysis_id INTEGER,
      refined_content TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (username) REFERENCES users(username),
      FOREIGN KEY (original_analysis_id) REFERENCES ai_pitch_deck_analyses(id)
    )
  ")
    }
    
    if (!dbExistsTable(db, "user_sessions")) {
      dbExecute(db, "
    CREATE TABLE user_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      session_id TEXT NOT NULL,
      state_json TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (username) REFERENCES users(username)
    )
  ")
    }
    
    
    # Create a directory for file storage if it doesn't exist
    if (!dir.exists("file_uploads")) {
      dir.create("file_uploads")
    }
    
    # Similarly for other tables...
    
    return(TRUE)
  }, error = function(e) {
    print(paste("Database setup error:", e$message))
    return(FALSE)
  })
}

# Initialize database
setup_database()

# Update function to include subscription ID
update_user_subscription <- function(username, status, subscription_id = NULL, end_date = NULL) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    # Build the query based on available params
    if (!is.null(subscription_id) && !is.null(end_date)) {
      dbExecute(db,
                "UPDATE users SET subscription_status = ?, subscription_id = ?, subscription_end_date = ? WHERE username = ?",
                params = list(status, subscription_id, end_date, username)
      )
    } else if (!is.null(subscription_id)) {
      dbExecute(db,
                "UPDATE users SET subscription_status = ?, subscription_id = ? WHERE username = ?",
                params = list(status, subscription_id, username)
      )
    } else if (!is.null(end_date)) {
      dbExecute(db,
                "UPDATE users SET subscription_status = ?, subscription_end_date = ? WHERE username = ?",
                params = list(status, end_date, username)
      )
    } else {
      dbExecute(db,
                "UPDATE users SET subscription_status = ? WHERE username = ?",
                params = list(status, username)
      )
    }
    return(TRUE)
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(FALSE)
  })
}

# Update Chargebee customer ID
update_chargebee_customer_id <- function(username, chargebee_customer_id) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    dbExecute(db,
              "UPDATE users SET chargebee_customer_id = ? WHERE username = ?",
              params = list(chargebee_customer_id, username)
    )
    return(TRUE)
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(FALSE)
  })
}


# Simple user management functions
check_user <- function(username, password) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    result <- dbGetQuery(db,
                         "SELECT * FROM users WHERE username = ? AND password = ?",
                         params = list(username, password)
    )
    
    if (nrow(result) == 1) {
      dbExecute(db,
                "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE username = ?",
                params = list(username)
      )
      return(result[1,])
    }
    return(NULL)
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(NULL)
  })
}

create_user <- function(username, password, email) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    # Check if username exists
    result <- dbGetQuery(db, 
                         "SELECT COUNT(*) as count FROM users WHERE username = ?", 
                         params = list(username)
    )
    
    if (result$count > 0) {
      return(FALSE)
    }
    
    dbExecute(db,
              "INSERT INTO users (username, password, email) VALUES (?, ?, ?)",
              params = list(username, password, email)
    )
    return(TRUE)
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(FALSE)
  })
}

# Function to save strategy data
save_strategy_data <- function(username, name, company_data, industry_data) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    # Check if name already exists for this user
    result <- dbGetQuery(db,
                         "SELECT COUNT(*) as count FROM strategy_data WHERE username = ? AND name = ?",
                         params = list(username, name)
    )
    
    if (result$count > 0) {
      # Update existing record
      dbExecute(db,
                "UPDATE strategy_data SET company_data = ?, industry_data = ?, updated_at = CURRENT_TIMESTAMP WHERE username = ? AND name = ?",
                params = list(company_data, industry_data, username, name)
      )
      return(list(success = TRUE, message = "Strategy data updated successfully"))
    } else {
      # Insert new record
      dbExecute(db,
                "INSERT INTO strategy_data (username, name, company_data, industry_data) VALUES (?, ?, ?, ?)",
                params = list(username, name, company_data, industry_data)
      )
      return(list(success = TRUE, message = "Strategy data saved successfully"))
    }
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(list(success = FALSE, message = paste("Error saving strategy data:", e$message)))
  })
}

# Function to save pitch deck data
save_pitch_deck_data <- function(username, name, mission_data, product_data, competitor_data, market_data, unit_economics) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    # Check if name already exists for this user
    result <- dbGetQuery(db,
                         "SELECT COUNT(*) as count FROM pitch_deck_data WHERE username = ? AND name = ?",
                         params = list(username, name)
    )
    
    if (result$count > 0) {
      # Update existing record
      dbExecute(db,
                "UPDATE pitch_deck_data SET mission_data = ?, product_data = ?, competitor_data = ?, market_data = ?, unit_economics = ?, updated_at = CURRENT_TIMESTAMP WHERE username = ? AND name = ?",
                params = list(mission_data, product_data, competitor_data, market_data, unit_economics, username, name)
      )
      return(list(success = TRUE, message = "Pitch deck data updated successfully"))
    } else {
      # Insert new record
      dbExecute(db,
                "INSERT INTO pitch_deck_data (username, name, mission_data, product_data, competitor_data, market_data, unit_economics) VALUES (?, ?, ?, ?, ?, ?, ?)",
                params = list(username, name, mission_data, product_data, competitor_data, market_data, unit_economics)
      )
      return(list(success = TRUE, message = "Pitch deck data saved successfully"))
    }
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(list(success = FALSE, message = paste("Error saving pitch deck data:", e$message)))
  })
}

# Function to save business model canvas data
save_business_model_canvas <- function(username, name, key_partners, key_activities, key_resources, value_propositions, customer_relationships, channels, revenue_streams, cost_structure, customer_segments) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    # Check if name already exists for this user
    result <- dbGetQuery(db,
                         "SELECT COUNT(*) as count FROM business_model_canvas WHERE username = ? AND name = ?",
                         params = list(username, name)
    )
    
    if (result$count > 0) {
      # Update existing record
      dbExecute(db,
                "UPDATE business_model_canvas SET key_partners = ?, key_activities = ?, key_resources = ?, value_propositions = ?, customer_relationships = ?, channels = ?, revenue_streams = ?, cost_structure = ?, customer_segments = ?, updated_at = CURRENT_TIMESTAMP WHERE username = ? AND name = ?",
                params = list(key_partners, key_activities, key_resources, value_propositions, customer_relationships, channels, revenue_streams, cost_structure, customer_segments, username, name)
      )
      return(list(success = TRUE, message = "Business model canvas updated successfully"))
    } else {
      # Insert new record
      dbExecute(db,
                "INSERT INTO business_model_canvas (username, name, key_partners, key_activities, key_resources, value_propositions, customer_relationships, channels, revenue_streams, cost_structure, customer_segments) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                params = list(username, name, key_partners, key_activities, key_resources, value_propositions, customer_relationships, channels, revenue_streams, cost_structure, customer_segments)
      )
      return(list(success = TRUE, message = "Business model canvas saved successfully"))
    }
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(list(success = FALSE, message = paste("Error saving business model canvas:", e$message)))
  })
}

# Function to load saved strategy data
load_strategy_data <- function(username) {
  tryCatch({
    db <- dbConnect(RSQLite::SQLite(), "users.db")
    on.exit(dbDisconnect(db))
    
    result <- dbGetQuery(db,
                         "SELECT id, name, created_at, updated_at FROM strategy_data WHERE username = ? ORDER BY updated_at DESC",
                         params = list(username)
    )
    
    return(result)
  }, error = function(e) {
    print(paste("Database error:", e$message))
    return(data.frame())
  })
}
