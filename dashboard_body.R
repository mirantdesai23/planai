# modules/components/dashboard_body.R

# Source all the necessary modules
source("ui/planning/research_module.R")
source("ui/planning/bmc_module.R")
source("ui/planning/strategy_module.R")
source("ui/planning/pitch_deck_module.R")
source("ui/process/notes_module.R")
source("ui/process/reports_module.R")
source("ui/process/tutorials_module.R")
source("ui/process/upload_module.R")
source("ui/assessment/financials_module.R")
source("ui/assessment/valuations_module.R")
source("ui/resources/issue_log_module.R")
#source("modules/ui/dashboard/activity_module.R")
source("ui/dashboard/dashboard_module.R")
source("ui/settings/user_settings.R")


# ... and so on for all modules

dashboard_body <- function() {
  dashboardBody(
    tabItems(
      get_dashboard_ui(),
      get_mrc_tab(),
      get_bmc_tab(),
      get_strat_ui(),
      get_pitd_ui(),
      get_notes_ui(),
      get_reports_ui(),
      get_tutorials_ui(),
      get_upload_tab_ui(),
      get_financials_ui(),
      get_valuations_ui(),
      get_issue_log_ui(),
      get_settings_ui()
      # ... and so on for all tabs
    )
  )
}