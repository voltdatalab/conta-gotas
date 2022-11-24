#########################################################################################
#########################################################################################
###################                                               #######################
###################         CONTA GOTAS          #######################
###################                                               #######################

#########################################################################################

### PACOTES
suppressMessages(library(shiny))
suppressMessages(library(tidyverse))
suppressMessages(library(dbplyr))
suppressMessages(library(rsconnect))
suppressMessages(library(lubridate))
suppressMessages(library(scales))
suppressMessages(library(DT))
suppressMessages(library(shinycssloaders))
suppressMessages(library(stringi))
suppressMessages(library(tidytext))
suppressMessages(library(extrafont))
suppressMessages(library(ggthemes))
suppressMessages(library(sysfonts))
suppressMessages(library(shinyWidgets))
suppressMessages(library(shinymanager))
suppressMessages(library(ggplot2))
suppressMessages(library(plotly))
suppressMessages(library(waterfalls))


### FUNCOES
source("functions.R")
options(scipen=999)

# Sanitize error messages
options(shiny.sanitize.errors = TRUE)
use_language(lan = "pt-BR")

# No need for token on gs4
#gs4_deauth()

######################################################################################### AUTH


# data.frame with credentials info
credentials <- data.frame(
  user = c("admin", "user", "convidado"),
  password = c("abelhasmatadoras", "ricadordarin", "cachorrosmalditos"),
  admin = c(TRUE, FALSE, FALSE),
  comment = "Use a senha para entrar",
  stringsAsFactors = FALSE
)

### UI

ui <- secure_app(language = "pt-BR", fab_position = "top-right",
  fluidPage(
  navbarPage(
    title = "Balanço da minha empresa fodástica",
    
    theme = "custom.css",
    tabPanel(tags$div(icon("chart-line"), " Painel"),
             mod_painel_ui("painel")),
    tabPanel(tags$div(icon("coins"), " Receitas"),
             mod_receitas_ui("receitas")),
    tabPanel(tags$div(icon("credit-card"), " Despesas"), 
              mod_despesas_ui("despesas")),
    tabPanel(tags$div(icon("table"), tags$a(href="https://docs.google.com/spreadsheets/d/12QRBFa-8U6QHoX7DOj3e_o1Ef7n-BTFklMPOP9qEFUc/edit#gid=1797569613", target="_blank"," Tabela/db"), style="margin-top:-4px"),
             )
  
  )
)
#secure app bracket
)

#########################################################################################

### SERVER

server <- function(input, output, session){
  
  result_auth <- secure_server(check_credentials = check_credentials(credentials))

  ##################################
  mod_receitas_server("receitas")
  mod_despesas_server("despesas")
  mod_painel_server("painel")
  
}


#########################################################################################

shinyApp(ui = ui, server = server)
