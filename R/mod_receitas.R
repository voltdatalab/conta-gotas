
##### SERVER

mod_receitas_server <- function(id, base) {
  
  shiny::moduleServer(
    id,
    function(input, output, session) {
      
      ##################################################
      ##### PREPARAR BASE
      
      caixa <- reactive({
        main_table <- read_delim("https://docs.google.com/spreadsheets/d/e/2PACX-1vQvhKcjL7uUeyq4S_ncaTPgDeKEZcMSwcLpv-4CWnMb4fOFZWtjNzG-BgC8XnaKvTfQztk_hHWZDOe4/pub?gid=1797569613&single=true&output=csv", col_names = TRUE, show_col_types = FALSE, locale = locale("pt", decimal_mark = ","))
        
        return(main_table)
      })
      
      receitas <- reactive({
        main_table <- read_delim("https://docs.google.com/spreadsheets/d/e/2PACX-1vQvhKcjL7uUeyq4S_ncaTPgDeKEZcMSwcLpv-4CWnMb4fOFZWtjNzG-BgC8XnaKvTfQztk_hHWZDOe4/pub?gid=2109219428&single=true&output=csv", col_names = TRUE, show_col_types = FALSE, locale = locale("pt", decimal_mark = ","))
        
        return(main_table)
      })
      
      receitas_filtro <- reactive({
        main_table <- receitas()
        
        # Filtros 
        if (input$ano != "todos os anos") {
          main_table <- main_table[main_table$ano == input$ano,]
        }
        
        if (input$rubrica != "Tudo") {
          main_table <- main_table[main_table$rubrica == input$rubrica,]
        }
        
        if (input$cliente != "Tudo") {
          main_table <- main_table[main_table$cliente == input$cliente,]
        }
        
        if (input$fiscal != "Tudo") {
          main_table <- main_table[main_table$fiscal == input$fiscal,]
        }
        
        if (input$tipo != "Tudo") {
          main_table <- main_table[main_table$tipo == input$tipo,]
        }
        
        if (input$vertical != "Tudo") {
          main_table <- main_table[main_table$vertical == input$vertical,]
        }
        
        if (input$status != "Tudo") {
          main_table <- main_table[main_table$status == input$status,]
        }
        
        return(main_table)
      })
      
      
      ##########
      # MENSAGEM COM DESCRICAO DA SELECAO
      
      output$basics <- renderText({
        
        main_table <- receitas_filtro()

        n_receitas <- main_table %>% count()
        
        paste(n_receitas$n," receitas registradas")
        
      })
      
      output$caixa_balanco <- renderText({
        
        main_table <- caixa()
        
        main_table <- main_table %>% tail(1)
        
        paste0("R$", format(main_table$valor, big.mark = ".", decimal.mark=","))
        
      })
      
      ##########
      # TEXTUAIS
      
      output$ano_selecionado <- renderUI({
        HTML(input$ano)
      })
      
      output$caixa_periodo <- renderUI({
        main_table <- caixa()
        
        main_table <- main_table %>% tail(1)
        
        HTML(paste0(main_table$mes, "." ,main_table$ano))
      })
      
      ##########
      # RECEITAS
      
      output$receitas_recebidas <- renderText({
        
        main_table <- receitas_filtro()
        
        receitas <- main_table %>% summarise(total = sum(valor))
        
        paste0("R$", format(receitas$total, big.mark = ".", decimal.mark=","))
        
      })
      
      ##########
      ## UIs
      
      output$clientes = renderUI({
        
        ns <- session$ns
        
        main_table <- receitas()
        
        selectizeInput(inputId = ns("cliente"), 
                        #multiple = TRUE,
                    label = "Clientes",
                    choices  = c("Tudo", as.list(unique(main_table$cliente))),
                    selected = "Tudo")
      })
      
      output$tipo = renderUI({
        
        ns <- session$ns
        
        main_table <- receitas()
        
        selectizeInput(inputId = ns("tipo"), 
                       #multiple = TRUE,
                       label = "Grande área",
                       choices  = c("Tudo", as.list(unique(main_table$tipo))),
                       selected = "Tudo")
      })
      
      output$vertical = renderUI({
        
        ns <- session$ns
        
        main_table <- receitas()
        
        selectizeInput(inputId = ns("vertical"), 
                       #multiple = TRUE,
                       label = "Vertical",
                       choices  = c("Tudo", as.list(unique(main_table$vertical))),
                       selected = "Tudo")
      })
      
      ##########
      # TABELA PRINCIPAL
      
      output$table <- DT::renderDataTable(DT::datatable({

        # Importa os dados principais e filtra pelas datas do input$date
        main_table <- receitas_filtro()

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
        #dom = 'Blrftip',
        # buttons = 
        #   list('copy', list(
        #     extend = 'collection',
        #     buttons = c('csv', 'excel'),
        #     text = 'Baixe os dados',
        #     exportOptions = list(
        #       modifiers = list(selected = TRUE)
        #     )
        #   )),
        language = list(
          lengthMenu = "Mostrando _MENU_ registros",
          buttons = list(copy = 'Copiar tabela', 
                         copyTitle = "Tabela copiada com sucesso", 
                         copySuccess = "%d linhas copiadas"),
          info = '',
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

mod_receitas_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    tags$div(
    ### TABELA PRINCIPAL
    column(12,
           
           # BUSCA POR STATUS
           column(2,
                  selectInput(inputId = ns("status"),
                              label = "Staus da receita",
                              selected = "Recebido",
                              choices = c("Contratado",
                                          "Faturado", 
                                          "Orçado",
                                          "Possibilidade alta (negociação)",
                                          "Possibilidade média (contato)",
                                          "Possibilidade remota (lead)",
                                          "Recebido")
                  )),
           
           column(2,
                  selectInput(inputId = ns("ano"),
                              label = "Selecione o ano",
                              selected = "2022",
                              choices = c("todos os anos",
                                          "2021",
                                          "2022")
                  )),
           
           column(2,uiOutput(ns('tipo'))),
           column(2,uiOutput(ns('vertical'))),
           
           # BUSCA POR fiscal
           column(2,
                  selectInput(inputId = ns("fiscal"),
                             label = "Contabilidade fiscal",
                                choices = c("Tudo",
                                           "sim", "não")
                       )),
           
           # SELECIONA REGIÃO
           column(2, selectInput(inputId = ns("rubrica"),
                                 label = "Projeto atribuído",
                                 choices = c("Tudo",
                                   "Volt",
                                   "Núcleo",
                                   "Volt 25 x Núcleo 75",
                                   "Volt 50 x Núcleo 50",
                                   "Volt 75 x Núcleo 25")
                            )
                  
           ),
           
           # SELECIONA CLIENTES
             column(2,uiOutput(ns('clientes'))),
           ),
           
           #BUSCADORES TEXTUAIS
           column(12,
                  
                  
                  
                  
),
           # results
column(12,
  column(2, class="destaque",
                  tags$h2("Receitas em ", uiOutput(ns("ano_selecionado"))),
         tags$h1(include_spinner_small(ns("receitas_recebidas")))
),
  column(2, class="destaque",
         tags$h2("Caixa em", uiOutput(ns("caixa_periodo"))),
         tags$h1(include_spinner_small(ns("caixa_balanco")))
  )
),
           column(12,tags$p(include_spinner_small(ns("basics")))),
            tags$hr(),
           column(12,include_spinner_tables(ns("table")))
    
    # Fecha TagList
  )
)
  
  # Fecha UI
}
