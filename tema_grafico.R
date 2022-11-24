library(ggthemes)
library(showtext)
library(tidyverse)

font_add_google("Lato", "Lato")
showtext_auto()

# cria um tema mais bonitinho para gráfico
tema <- function(base_size = 14, base_family = "Lato") {
  (theme_foundation(base_size = base_size, base_family = base_family) + 
     theme(
       #line = element_line(colour = "black"),
       text = element_text(colour = "#008596"),
       #axis.title = element_blank(),
       axis.text = element_text(),
       axis.ticks = element_blank(),
       axis.line = element_blank(),
       legend.background = element_rect(),
       legend.position = "bottom",
       legend.direction = "horizontal",
       legend.box = "vertical",
       legend.margin = (margin=margin(0,0,0,0)),
       panel.border = element_rect(colour = "#ffffff", fill=NA, size=2),
       panel.grid = element_line(colour = NULL),
       panel.grid.major = element_line(colour = "#f4f4f4"),
       panel.grid.minor = element_blank(),
       plot.title = element_text(hjust = 0, size = rel(1.5), face = "bold"),
       plot.subtitle = element_text(hjust = 0, margin=margin(5,0,20,0)),
       plot.caption = element_text(size = 10, hjust = 0, margin=margin(20,0,0,0)),
       plot.margin = unit(c(1, 1, 1, 1), "lines"),
       strip.background = element_rect()))
}