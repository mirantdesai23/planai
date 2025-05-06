# Base image with R and required packages
FROM rocker/shiny:latest

FROM nginx:latest
COPY your-content/ /usr/share/nginx/html/
EXPOSE 80

# Install system dependencies
RUN apt-get update && apt-get install -y \
libssl-dev \
libcurl4-openssl-dev \
libxml2-dev \
libsodium-dev \
libsqlite3-dev \
&& rm -rf /var/lib/apt/lists/*
  
  # Install R packages
  RUN R -e "install.packages(c('shiny', 'shinyjs', 'DBI', 'RSQLite', 'shinydashboard', \
    'shinydashboardPlus', 'dplyr', 'aws.s3', 'DT', 'bslib', 'dotenv', 'httr', \
    'jsonlite', 'ggplot2', 'stringi', 'emayili', 'uuid', 'digest', 'xaringan', \
    'reshape', 'rhandsontable', 'writexl', 'googleAuthR', 'rmarkdown', 'knitr', \
    'gridExtra', 'plumber', 'fontawesome', 'shinymaterial'))"

# Create app directory
RUN mkdir -p /app
WORKDIR /app

# Copy application files
COPY app12.r /app/
  #COPY plumber.R /app/
 # COPY www /app/www/
  COPY .env /app/
  
  # Add ShinyProxy integration code
  COPY shinyproxy_integration.R /app/
  
  # Add this line after the COPY command
RUN if [ -f /app/app12.r ]; then mv /app/app12.r /app/app.R; fi
  
  # Set permissions
  RUN chmod -R 755 /app

# Expose port
EXPOSE 8080

# Add this at the end of your Dockerfile instead of the CMD line
COPY start-script.sh /app/
RUN chmod +x /app/start-script.sh
CMD ["/app/start-script.sh"]

# Command to run the application
#CMD ["R", "-e", "source('/app/app12.r')"]
