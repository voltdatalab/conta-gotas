
##### SERVER

mod_despesas_server <- function(id, base) {
  
  shiny::moduleServer(
    id,
    function(input, output, session) {
      
      ##################################################
      ##### PREPARAR BASE
      
      despesas <- reactive({
        main_table <- read_delim("https://docs.google.com/spreadsheets/d/e/2PACX-1vQvhKcjL7uUeyq4S_ncaTPgDeKEZcMSwcLpv-4CWnMb4fOFZWtjNzG-BgC8XnaKvTfQztk_hHWZDOe4/pub?gid=1800462706&single=true&output=csv", col_names = TRUE, show_col_types = FALSE, locale = locale("pt", decimal_mark = ","))
        
        return(main_table)
      })
      
      despesas_filtro <- reactive({
        main_table <- despesas()
        
        # Filtros 
        if (input$despesa != "Tudo") {
          main_table <- main_table[main_table$despesa == input$despesa,]
        }
        
        if (input$ano != "Tudo") {
          main_table <- main_table[main_table$ano == input$ano,]
        }
        
        if (input$centro_custo != "Tudo") {
          main_table <- main_table[main_table$centro_custo == input$centro_custo,]
        }
        
        if (input$finalidade != "Tudo") {
          main_table <- main_table[main_table$finalidade == input$finalidade,]
        }
        
        if (input$tipo != "Tudo") {
          main_table <- main_table[main_table$tipo == input$tipo,]
        }
        
        if (input$efetivacao != "Tudo") {
          main_table <- main_table[main_table$efetivacao == input$efetivacao,]
        }
        
        if (input$cliente != "Tudo") {
          main_table <- main_table[main_table$cliente == input$cliente,]
        }
        
        if (input$despesa_efetiva != "Tudo") {
          main_table <- main_table[main_table$despesa_efetiva == input$despesa_efetiva,]
        }
        
        if (input$pago_por_cliente != "Tudo") {
          main_table <- main_table[main_table$pago_por_cliente == input$pago_por_cliente,]
        }
        
        return(main_table)
      })
      
      ##########
      # TEXTUAIS
      output$ano_selecionado <- renderUI({
        HTML(input$ano)
      })
      
      
      ##########
      # MENSAGEM COM DESCRICAO DA SELECAO
      
      output$basics <- renderText({
        
        main_table <- despesas_filtro()
        
        n_despesas <- main_table %>% count()
        
        paste(n_despesas$n," despesas registradas")
        
      })
      
      ##########
      # DEESPESAS
      
      output$despesas_recebidas <- renderText({
        
        main_table <- despesas_filtro()
        
        despesas <- main_table %>% summarise(total = sum(valor_efetivo))
        
        paste0("R$", format(despesas$total, big.mark = ".", decimal.mark=","))
        
      })
      
      ##########
      ## UIs
      
      output$despesa <- renderUI({
        
        ns <- session$ns
        
        main_table <- despesas()
        
        selectizeInput(inputId = ns("despesa"), 
                       #multiple = TRUE,
                       label = "Nome da depesa",
                       choices  = c("Tudo", as.list(unique(sort(main_table$despesa)))),
                       selected = "Tudo")
      })
      
      output$clientes = renderUI({
        
        ns <- session$ns
        
        main_table <- despesas()
        
        selectizeInput(inputId = ns("cliente"), 
                       #multiple = TRUE,
                       label = "Clientes",
                       choices  = c("Tudo", as.list(unique(main_table$cliente))),
                       selected = "Tudo")
      })
      
      output$tipo = renderUI({
        
        ns <- session$ns
        
        main_table <- despesas()
        
        selectizeInput(inputId = ns("tipo"), 
                       #multiple = TRUE,
                       label = "Grande área",
                       choices  = c("Tudo", as.list(unique(main_table$tipo))),
                       selected = "Tudo")
      })
      
      output$efetivacao = renderUI({
        
        ns <- session$ns
        
        main_table <- despesas()
        
        selectizeInput(inputId = ns("efetivacao"), 
                       #multiple = TRUE,
                       label = "Efetivação",
                       choices  = c("Tudo", as.list(unique(main_table$efetivacao))),
                       selected = "Tudo")
      })
      
      ##########
      # TABELA PRINCIPAL
      
      output$table <- DT::renderDataTable(DT::datatable({
        
        # Importa os dados principais e filtra pelas datas do input$date
        main_table <- despesas_filtro()
        
        # Gera a tabela principal
        
        main_table
        
      }, escape = FALSE,
      #colnames = c(''),
      extensions = c("Buttons"), 
      rownames = FALSE,
      # CONFIGURACOES GERAIS DA TABELA
      options = list(
        #language = list(searchPlaceholder = "Busca por palavra-chave...",
        #              zeroRecords = "Não há resultados para a sua busca.",
        #             sSearch = ""),
        pageLength = 50,
        lengthMenu = list( c(10, 50, -1) # declare values
                           , c(10, 50, "Todos") # declare titles
        ),
        dom = 'lrftip',
        buttons = 
          list('copy', list(
            extend = 'collection',
            buttons = c('csv', 'excel'),
            text = 'Baixe os dados',
            exportOptions = list(
              modifiers = list(selected = TRUE)
            )
          )),
        language = list(
          lengthMenu = "Mostrando _MENU_ registros",
          buttons = list(copy = 'Copiar tabela', 
                         copyTitle = "Tabela copiada com sucesso", 
                         copySuccess = "%d linhas copiadas"),
          info = 'FONTE: Atlas da Notícia',
          paginate = list(previous = 'Anterior', `next` = 'Próxima'),
          processing = "CARREGANDO OS DADOS...",
          search = "Buscar na tabela",
          emptyTable = "INICIE SUA BUSCA POR TERMOS DE PESQUISA",
          zeroRecords = "SEM RESULTADOS PARA MOSTRAR, FAÇA NOVA BUSCA"),
        info = TRUE
      )
      
      # Fecha DT::datatable
      )
      )
      # Fecha modulo
    }
    
    # Fecha server
  )}

###################################################################################################
###################################################################################################
###################################################################################################

### UI

mod_despesas_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    tags$div(
      ### TABELA PRINCIPAL
      column(12,
             
             # BUSCA POR STATUS
             column(2,uiOutput(ns('despesa'))),
             column(2,
                    selectInput(inputId = ns("despesa_efetiva"),
                                label = "Staus da despesa",
                                selected = "Despesa efetiva",
                                choices = c("Tudo", 
                                            "Despesa efetiva" = "sim",
                                            "Não realizada/prevista" = "não")
                    )),
             
             column(2,
                    selectInput(inputId = ns("ano"),
                                label = "Selecione o ano",
                                selected = "2022",
                                choices = c("Tudo",
                                            "2021",
                                            "2022")
                    )),
             
             # BUSCA POR fiscal
             column(2,
                    selectInput(inputId = ns("centro_custo"),
                                label = "Centro de custo",
                                choices = c("Tudo",
                                            "Volt", "Núcleo")
                    )),
             
             # SELECIONA REGIÃO
             column(2, selectInput(inputId = ns("finalidade"),
                                   label = "Finalidade da despesa",
                                   choices = c("Tudo",
                                               "administrativo",
                                               "pessoal",
                                               "operacional")
             )),
             column(2, selectInput(inputId = ns("pago_por_cliente"),
                                   label = "Despesa paga por cliente",
                                   selected = "não",
                                   choices = c("Tudo",
                                               "sim",
                                               "não")
             )),
             column(2,uiOutput(ns('tipo'))),
             column(2,uiOutput(ns('efetivacao'))),
             
             # SELECIONA CLIENTES
             column(2,uiOutput(ns('clientes'))),
      ),
      
      # results
      column(12,
             column(2, class="destaque",
                    tags$h2("Despesas em ", uiOutput(ns("ano_selecionado"))),
                    tags$h1(include_spinner_small(ns("despesas_recebidas")))
             ),
      ),
      column(12,tags$p(include_spinner_small(ns("basics")))),
      tags$hr(),
      column(12,include_spinner_tables(ns("table")))
      
      # Fecha TagList
    )
  )
  
  # Fecha UI
}