
##### SERVER

mod_painel_server <- function(id, base) {
  
  shiny::moduleServer(
    id,
    function(input, output, session) {
      
      ##################################################
      ### TABELÕES
      
      ### RECEITAS
      caixa <- reactive({
        tabela <- read_delim("https://docs.google.com/spreadsheets/d/e/2PACX-1vQvhKcjL7uUeyq4S_ncaTPgDeKEZcMSwcLpv-4CWnMb4fOFZWtjNzG-BgC8XnaKvTfQztk_hHWZDOe4/pub?gid=1797569613&single=true&output=csv", col_names = TRUE, show_col_types = FALSE, locale = locale("pt", decimal_mark = ","))
        
        return(tabela)
      })
      
      tabela_receitas <- reactive({
        tabela <- read_delim("https://docs.google.com/spreadsheets/d/e/2PACX-1vQvhKcjL7uUeyq4S_ncaTPgDeKEZcMSwcLpv-4CWnMb4fOFZWtjNzG-BgC8XnaKvTfQztk_hHWZDOe4/pub?gid=2109219428&single=true&output=csv", col_names = TRUE, show_col_types = FALSE, locale = locale("pt", decimal_mark = ","))
        
        if (input$ano != "todos os anos") {
          tabela <- tabela[tabela$ano == input$ano,]
        }
        
        return(tabela)
      })
      
      ### DESPESAS
      tabela_despesas <- reactive({
        tabela <- read_delim("https://docs.google.com/spreadsheets/d/e/2PACX-1vQvhKcjL7uUeyq4S_ncaTPgDeKEZcMSwcLpv-4CWnMb4fOFZWtjNzG-BgC8XnaKvTfQztk_hHWZDOe4/pub?gid=1800462706&single=true&output=csv", col_names = TRUE, show_col_types = FALSE, locale = locale("pt", decimal_mark = ","))
        
        if (input$ano != "todos os anos") {
          tabela <- tabela[tabela$ano == input$ano,]
        }
        
        tabela <- tabela %>% 
          filter(pgto_lucro == "não" & pago_por_cliente == "não" & despesa_efetiva == "sim")
        
        return(tabela)
      })
      
      ###################
      ### ANÁLISE DE RECEITAS
      
      receitas_recebidas <- reactive({
        tabela <- tabela_receitas()
        
        tabela <- tabela %>% 
          filter(status == "Recebido" | status == "Faturado") %>%
          summarise(total = sum(valor))
        
        return(tabela$total)
      })
      
      receitas_contratadas <- reactive({
        tabela <- tabela_receitas()
        
        tabela <- tabela %>% 
          filter(status == "Contratado") %>%
          summarise(total = sum(valor))
        
        return(tabela$total)
      })
      
      receitas_possiveis <- reactive({
        tabela <- tabela_receitas()
        
        tabela <- tabela %>% 
          filter(status == input$tipo_possiveis[1] |
                   status == input$tipo_possiveis[2] |
                   status == input$tipo_possiveis[3]) %>%
          summarise(total = sum(valor))
        
        return(tabela$total)
      })
      
      
      ###################
      ### ANÁLISE DE DESPESAS
      despesas_efetivas <- reactive({
        tabela <- tabela_despesas()
        
        if (input$ano != "todos os anos") {
          tabela <- tabela[tabela$ano == input$ano,]
        }
        
        tabela <- tabela %>% 
          filter(pgto_lucro == "não" & pago_por_cliente == "não" & despesa_efetiva == "sim") %>%
          summarise(total = sum(valor_efetivo))
        
        return(tabela$total)
      })
      
      despesas_previstas <- reactive({
        tabela <- tabela_despesas()
        
        if (input$ano != "todos os anos") {
          tabela <- tabela[tabela$ano == input$ano,]
        }
        
        tabela <- tabela %>% 
          filter(pgto_lucro == "não" & pago_por_cliente == "não" & despesa_efetiva == "prevista") %>%
          summarise(total = sum(valor_efetivo))
        
        return(tabela$total)
      })
      
      ##########
      # GRÁFICOS
      
      output$caixa_historico <- renderPlotly({
        tabela <- caixa()
        
        if (input$ano != "todos os anos") {
          tabela <- tabela[tabela$ano == input$ano,]
        }
        
        graf <- ggplot(tabela, aes(data,valor)) + 
          geom_bar(fill = "#4b31dd", stat = "identity") + 
          labs(title = "", y="mil R$", x="") +
          theme_minimal() + theme(text=element_text(size=16,family="Barlow")) 
        
        ggplotly(graf) %>% config(responsive = TRUE, 
                                  displayModeBar = FALSE,
                                  scrollZoom = TRUE)
        
      })
      
      despesas_mensais <- reactive({
        tabela <- tabela_despesas()
        mt <- tabela %>% 
          dplyr::group_by(mes = lubridate::floor_date(data, "month")) %>%
          summarise(total = sum(valor_efetivo))
        
        return(mt)
      })

      output$despesas_mes_graf <- renderPlotly({ 
        
        mt <- as.tibble(despesas_mensais())
        
        graf <- ggplot(mt, aes(mes,total)) + 
          geom_bar(fill = "#4b31dd", stat = "identity") + 
          labs(title = "", y="mil R$", x="") +
          theme_minimal() + theme(text=element_text(size=16,family="Barlow")) 
        
        ggplotly(graf) %>% config(responsive = TRUE, 
                                  displayModeBar = FALSE,
                                  scrollZoom = TRUE)
        
      })
      
      output$depesas_por_cliente <- renderPlotly({
        
        despesas <- tabela_despesas()
        
        proporcao <- despesas %>%
          group_by(cliente) %>%
          summarise(total = sum(valor_efetivo)) %>%
          mutate(pct_total = round((total/sum(total))*100,1)) %>%
          arrange(desc(total)) 
        
        proporcao$cat <- ifelse(proporcao$pct_total < 1, "outros", proporcao$cliente)
        
        colors <- c("#231f20", "#cbcbcb", "#4b31dd", "#e2a805")
        
        if (input$exc_nucleo == "Sim") {
          proporcao <- proporcao[proporcao$cliente != "Núcleo",]
        }
        
        plot_ly(data=proporcao,labels=~cat, 
                values=~pct_total, 
                type="pie",
                textposition = 'inside',
                textinfo = 'label+percent',
                insidetextfont = list(color = '#FFFFFF'),
                marker = list(colors = colors,
                              line = list(color = '#FFFFFF', width = 1)),
                #The 'pull' attribute can also be used to create space between the sectors
                showlegend = FALSE) %>% 
          layout(title = '',
                 xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        
      })

      output$depesas_por_finalidade <- renderPlotly({
        
        despesas <- tabela_despesas()
        
        proporcao <- despesas %>%
          group_by(finalidade) %>%
          summarise(total = sum(valor_efetivo)) %>%
          mutate(pct_total = round((total/sum(total))*100,1)) %>%
          arrange(desc(total)) 
        
        graf <- ggplot(proporcao, aes(reorder(finalidade,total), total)) +
          geom_bar(fill = "#4b31dd", stat = "identity") + 
          labs(title = "", y="mil R$", x="") +
          theme_minimal() + theme(text=element_text(size=16,family="Barlow")) +
          coord_flip()
        
        ggplotly(graf) %>%  config(responsive = TRUE, displayModeBar = FALSE, scrollZoom = TRUE)
        
      })

      output$depesas_por_tipo <- renderPlotly({
        
        despesas <- tabela_despesas()
        
        proporcao <- despesas %>%
          group_by(tipo) %>%
          summarise(total = sum(valor_efetivo)) %>%
          mutate(pct_total = round((total/sum(total))*100,1)) %>%
          arrange(desc(total)) 
        
        proporcao$cat <- ifelse(proporcao$pct_total < 1, "outros", proporcao$tipo)
        
        graf <- ggplot(proporcao, aes(reorder(tipo,total), total)) +
          geom_bar(fill = "#4b31dd", stat = "identity") + 
          labs(title = "", y="mil R$", x="") +
          theme_minimal() + theme(text=element_text(size=16,family="Barlow")) +
          coord_flip()
        
        ggplotly(graf) %>% layout(height = 450) %>% config(responsive = TRUE, displayModeBar = FALSE, scrollZoom = TRUE)
        
      })
      
      output$lucro <- renderPlotly({
        despesa <- despesas_efetivas() * -1
        receita <- receitas_recebidas()
        
        cat <- c("despesa", "receita\nrecebida")
        valores <- c(despesa, receita)
        
        resultado <- data.frame(tipo = cat, valores = round(valores/1000,2))
        
        graf <- waterfall(resultado, calc_total = TRUE,
                  theme_text_family = "Barlow",
                  rect_text_size = 2,
                  linetype = "dashed",
                  fill_by_sign = FALSE,
                  fill_colours = c("#f33872", "#e2a805"),
                  total_rect_text_color = "#000000",
                  total_rect_color = "#2ADD90") + 
          labs(title = "", y="mil R$", x="") +
          theme_minimal() + theme(text=element_text(size=16,family="Barlow"))
        
        ggplotly(graf) %>% config(responsive = TRUE, 
                                  displayModeBar = FALSE,
                                  scrollZoom = TRUE)
      })
      
      receitas_mensais <- reactive({
        tabela <- tabela_receitas()
        mt <- tabela %>% 
          dplyr::group_by(mes = lubridate::floor_date(data, "month")) %>%
          summarise(total = sum(valor))
        
        return(mt)
      })
      
      output$receitas_mes_graf <- renderPlotly({ 
        
        mt <- as.tibble(receitas_mensais())
        
        graf <- ggplot(mt, aes(mes,total)) + 
          geom_bar(fill = "#4b31dd", stat = "identity") + 
          labs(title = "", y="mil R$", x="") +
          theme_minimal() + theme(text=element_text(size=16,family="Barlow")) 
        
        ggplotly(graf) %>% config(responsive = TRUE, 
                                  displayModeBar = FALSE,
                                  scrollZoom = TRUE)
        
      })
      
      output$receitas_previstas <- renderPlotly({
        receita_recebida <- receitas_recebidas()
        receita_contratada <- receitas_contratadas()
        receita_possivel <- receitas_possiveis()
        #resultado <- receita + despesa
        
        
        cat <- c("recebidas", "contratadas", if(input$possiveis == "Sim"){"possíveis"})
        valores <- c(receita_recebida, receita_contratada, if(input$possiveis != "Não"){receita_possivel})
        
        resultado <- data.frame(tipo = cat, valores = round(valores/1000,2))
        
        graf <- waterfall(resultado, calc_total = TRUE,
                  theme_text_family = "Barlow",
                  rect_text_size = 2,
                  linetype = "dashed",
                  fill_by_sign = FALSE,
                  fill_colours = c("#f33872", "#e2a805"),
                  total_rect_text_color = "#000000",
                  total_rect_color = "#2ADD90") + 
          labs(title = "", 
               subtitle = "",
               y="mil R$", x="") +
          theme_minimal() + theme(text=element_text(size=16,family="Barlow"))
        
        ggplotly(graf, tooltip = FALSE, text = FALSE, hoverinfo = "none") %>% config(responsive = TRUE, 
                                  displayModeBar = FALSE,
                                  scrollZoom = TRUE)
      })
      
      output$proporcao_receita <- renderPlotly({
        receita <- tabela_receitas()
        
        proporcao <- receita %>%
          filter(status == "Recebido") %>%
          group_by(cliente) %>%
          summarise(total = sum(valor)) %>%
          mutate(pct_total = round((total/sum(total))*100,1)) %>%
          arrange(desc(total)) 
        
        proporcao$cat <- ifelse(proporcao$pct_total < 1, "outros", proporcao$cliente)
        
        colors <- c("#231f20", "#cbcbcb", "#4b31dd", "#e2a805")
        
        plot_ly(data=proporcao,labels=~cat, 
                values=~pct_total, 
                type="pie",
                textposition = 'inside',
                textinfo = 'label+percent',
                insidetextfont = list(color = '#FFFFFF'),
                marker = list(colors = colors,
                              line = list(color = '#FFFFFF', width = 1)),
                #The 'pull' attribute can also be used to create space between the sectors
                showlegend = FALSE) %>% 
          layout(title = '',
                 xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      })
      
      output$faturamento_por_cliente <- renderPlotly({
        receita <- tabela_receitas()
        
        proporcao <- receita %>%
          filter(status == "Recebido") %>%
          group_by(cliente) %>%
          summarise(total = sum(valor)) %>%
          mutate(pct_total = round((total/sum(total))*100,1)) %>%
          arrange(desc(total)) 
        
        proporcao$cat <- ifelse(proporcao$pct_total < 1, "outros", proporcao$cliente)
        
        graf <- ggplot(proporcao, aes(reorder(cliente,total), total)) +
          geom_bar(fill = "#4b31dd", stat = "identity") + 
          labs(title = "", y="mil R$", x="") +
          theme_minimal() + theme(text=element_text(size=16,family="Barlow")) +
          coord_flip()
        
        ggplotly(graf) %>% layout(height = 450) %>% config(responsive = TRUE, displayModeBar = FALSE, scrollZoom = TRUE)
        
      })
      
      # Fecha modulo
    }
    
    # Fecha server
  )}

###################################################################################################
###################################################################################################
###################################################################################################

### UI

mod_painel_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    tags$div(
      ### TABELA PRINCIPAL
      column(12,
             
             column(2,
                    selectInput(inputId = ns("ano"),
                                label = tags$div("Selecione o ano", tags$br()),
                                selected = "2022",
                                choices = c("todos os anos",
                                            "2021",
                                            "2022")
                    )),
             column(2,
                    radioButtons(inputId = ns("possiveis"),
                                 label = "Incluir receitas possíveis",
                                 choices = c("Sim", "Não"),
                                 selected = "Não",
                                 inline = TRUE
                    )),
             conditionalPanel(condition = "input.possiveis == 'Sim'",
                              ns = ns,
                              column(4, 
                                     checkboxGroupInput(
                                inputId = ns("tipo_possiveis"),
                                label = "Possibilidades de receita",
                                choices = c("Baixa" = "Possibilidade remota (lead)",
                                            "Média" = "Possibilidade média (contato)",
                                            "Alta" = "Possibilidade alta (negociação)"),
                                selected = c("Possibilidade remota (lead)",
                                             "Possibilidade média (contato)",
                                             "Possibilidade alta (negociação)")
                              )
                              )
                              )
             ),
      # results
      column(12,
      
      # Lucro
      column(4,
             tags$h2("LUCRO BRUTO"),
             tags$h4("Em relação às despesas totais executadas."),
             plotlyOutput(ns("lucro"))),
      
      # Receitas
      column(4,
             tags$h2("RECEITAS"),
             conditionalPanel(condition = "input.possiveis == 'Sim'",                                       ns = ns, tags$h4("Receitas recebidas, contratadas e em prospecção/negociação.")),
             conditionalPanel(condition = "input.possiveis == 'Não'",                                       ns = ns, tags$h4("Inclui receitas recebidas, com NF faturada e aquelas previstas em contrato.")),
             plotlyOutput(ns("receitas_previstas"))),
      
      # DESPESAS MES
      # column(4,
      #        tags$h2("DESPESAS POR MÊS"),
      #        tags$h4("Evolução das despesas mensais"),
      #        plotlyOutput(ns("despesas_mes_graf"))),
      
      # CAIXA
      column(4,
             tags$h2("HISTÓRICO DO CAIXA"),
             tags$h4("Evolução da disponibilidade de caixa no período"),
             plotlyOutput(ns("caixa_historico")))
      ),
      column(6,
             tags$h2("DESPESAS APURADAS POR MÊS"),
             plotlyOutput(ns("despesas_mes_graf"))),
      column(6,
             tags$h2("RECEITAS APURADAS POR MÊS"),
             plotlyOutput(ns("receitas_mes_graf"))),
      column(12,
      column(4,
             tags$h2("DEPENDÊNCIA DE FATURAMENTO"),
             tags$h4("Proporção de recursos recebidos por clientes ou parceiros"),
             plotlyOutput(ns("proporcao_receita"))),
      
      column(8,
             tags$h2("RECURSOS POR CLIENTE"),
             tags$h4("Recursos recebidos por cliente ou parceiro"),
             plotlyOutput(ns("faturamento_por_cliente")))
      ),
      column(12,
             column(4,
                    tags$h2("DESPESAS POR CLIENTE"),
                    tags$h4("Proporção de recursos gastos com clientes ou parceiros"),
                    radioButtons(inputId = ns("exc_nucleo"),
                                 label = "Excluir Núcleo da Conta",
                                 choices = c("Sim", "Não"),
                                 selected = "Não"
                                 ),
                    plotlyOutput(ns("depesas_por_cliente"))),
             
             column(8,
                    tags$h2("DESPESAS POR FINALIDADE GERAL"),
                    tags$h4(""),
                    plotlyOutput(ns("depesas_por_finalidade"))),
             column(8,
                    tags$h2("DESPESAS POR TIPO"),
                    tags$h4(""),
                    plotlyOutput(ns("depesas_por_tipo")))
             
      )
      # Fecha TagList
    )
  )
  
  # Fecha UI
}
