#########################################################################################
#########################################################################################
###########################                                   ###########################
###########################     FUNCOES    ###########################
###########################                                   ###########################

#########################################################################################

### SPINNERS

# Spinners que devem aparecer enquanto dados carregam. Sao diferentes tipos:

# Coluna Grande: spinner circular
include_spinner_large_column <- function(output){
  
  withSpinner(tableOutput(output),
              type = getOption("spinner.type", default = 3),
              color = getOption("spinner.color", default = "#0fb872"),
              size = getOption("spinner.size", default = 1),
              color.background = getOption("spinner.color.background", default = "#eeeeee"),
              custom.css = FALSE, proxy.height = if (grepl("height:\\s*\\d", tableOutput(output))) NULL else "300px")
  
}

# Coluna Fina: spinner retangular
include_spinner_thin_column <- function(output){
  
  withSpinner(tableOutput(output),
              type  = getOption("spinner.type",  default = 1),
              color = getOption("spinner.color", default = "#0fb872"),
              size  = getOption("spinner.size",  default = 1),
              color.background = getOption("spinner.color.background", default = "#0fb872"),
              custom.css = FALSE, proxy.height = if (grepl("height:\\s*\\d", tableOutput(output))) NULL else "300px")
  
}

# Spinner pequeno: textos, circular pequeno
include_spinner_small <- function(output){
  
  withSpinner(textOutput(output),
              type = getOption("spinner.type", default = 7),
              color = getOption("spinner.color", default = "#0fb872"),
              size = getOption("spinner.size", default = 0.4),
              color.background = getOption("spinner.color.background", default = "#0fb872"),
              custom.css = FALSE, proxy.height = "20px")
  
}

# Spinner tabelas: circular grande
include_spinner_tables <- function(output){
  
  withSpinner(DT::dataTableOutput(output),
              type = getOption("spinner.type", default = 6),
              color = getOption("spinner.color", default = "#0fb872"),
              size = getOption("spinner.size", default = 1),
              color.background = getOption("spinner.color.background", default = "#0fb872"),
              custom.css = FALSE, proxy.height = if (grepl("height:\\s*\\d", DT::dataTableOutput(output))) NULL else "300px")
  
}

# Loader tabelas: circular grande
include_loader_tables <- function(output){
  
  withLoader(DT::dataTableOutput(output),
             type = "html",
             loader = "myloader")
  
}

########################################################################################

## TEMA GRAFICO

tema <- function(base_size = 14 , base_family = "Barlow"){(
  
  theme_foundation(base_size = base_size, base_family = base_family) +
    theme(
      plot.background = element_rect(colour="#eeeeee", fill="#eeeeee"),
      panel.background = element_rect(colour="#eeeeee", fill="#eeeeee"),
      text = element_text(colour = "#231f20"),
      
      axis.text = element_text(size = rel(0.8), margin=margin(0,40,0,0)),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      axis.title = element_text(size = rel(0.9), colour = "#999999"),
      
      legend.text = element_text(size=rel(0.9), angle = 0),
      legend.title = element_blank(),
      legend.key = element_rect(fill = "#eeeeee", colour = "#eeeeee", size = 0.5, linetype='dashed'),
      legend.key.width = unit(0.6, "cm"),
      legend.position = "top",
      legend.justification = c(-0.05, 0),
      legend.background = element_blank(),
      legend.direction = "horizontal",
      legend.margin = (margin=margin(0,0,0,0)),
      legend.box = NULL,
      
      panel.border = element_rect(colour = "#eeeeee", fill=NA, size=2),
      panel.grid.major = element_line(colour = "#e4e4e4"),
      panel.grid.minor = element_line(colour = "#e6e6e6"),
      panel.grid.minor.x = element_line(colour = "#e4e4e4"),
      
      plot.title = element_text(hjust = 0, size = rel(1.3), face = "bold", colour = "#231f20"),
      plot.title.position = "plot",
      strip.background = element_rect(colour="#eeeeee", fill="#eeeeee"),
      plot.subtitle = element_text(hjust = 0, margin=margin(0,0,40,0),size = rel(1), lineheight = 1),
      plot.caption = element_text(size = rel(0.75), hjust = 1, margin=margin(20,0,0,0), colour = "#555555", lineheight = 1),
      plot.margin = unit(c(1, 1, 1, 0), "lines")
    )
)
}
