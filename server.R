## server.R ##
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(DT)

library(plotly)

library(openxlsx)

library(tidyquant)
library(tidyverse)
library(dplyr)

library(forecast)

# library(mgcv)
library(car)
# library(urca)
library(earth)

# library(rmarkdown)
# library(devtools)
library(psych)

# load_library <- function(libs) {
#   missing_libs <- libs[!(libs %in% installed.packages()[,"Package"])]
#   if (length(missing_libs) > 0) {
#     install.packages(missing_libs, dependencies = TRUE)
#   }
#   invisible(lapply(libs, library))
# }
# 
# libs <- c("shiny", "shinydashboard", "shinydashboardPlus", "plotly", "tidyquant", "openxlsx",
#           "tidyverse", "DT", "forecast", "dplyr", "mgcv", "car", "urca", "earth",
#           "shinyWidgets", "rmarkdown", "grid", "gridExtra", "devtools")
# 
# load_library(libs)



function(input, output) {

  ###
  ###     TAB : CARGA DE FICHEROS         
  ###
  
  ## CARGA FICHEROS DE ENTRADA EN TABLAS VISUALIZABLES / USABLES ##
  
  ### TABLA MERGE BY MES DE LOS DATOS ###
  
  uploaded_file <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(NULL)
    }

    path <- file$datapath
    
    df <- path %>% 
      excel_sheets() %>% 
      set_names() %>% 
      map(~ read_excel(path, .x, col_names = TRUE))

    all_sheets <- excel_sheets(file$datapath)
    
    Ocupacion <- df[[which(all_sheets == "Ocupacion")]]
    ConsumosDDDpor1000Estancias <- df[[which(all_sheets == "ConsumosDDDpor1000Estancias")]]
    ResultadosSensibles <- df[[which(all_sheets == "ResultadosSensibles")]]
    ResultadosResistentes <- df[[which(all_sheets == "ResultadosResistentes")]]
    
    colnames(ResultadosSensibles)[2:ncol(ResultadosSensibles)] <- paste0(colnames(ResultadosSensibles)[2:ncol(ResultadosSensibles)], "_sen")
    colnames(ResultadosResistentes)[2:ncol(ResultadosResistentes)] <- paste0(colnames(ResultadosResistentes)[2:ncol(ResultadosResistentes)], "_res")
    
    data <- Ocupacion %>%
      left_join(ConsumosDDDpor1000Estancias, by = "mes") %>%
      left_join(ResultadosSensibles, by = "mes") %>%
      left_join(ResultadosResistentes, by = "mes")
    
    return(data)
  })
  
  
  ### TABLA OCUPACION EN EL CENTRO ###
  
  upload_ocupacion <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(NULL)
    }
    
    path <- file$datapath
    df <- path %>% 
      excel_sheets() %>% 
      set_names() %>% 
      map(~ read_excel(path, .x, col_names = TRUE))
    
    all_sheets <- excel_sheets(file$datapath)
    
    Ocupacion <- df[[which(all_sheets == "Ocupacion")]]
    Ocupacion<- Ocupacion %>%
      mutate(mes = as_date(mes))
    
    return(Ocupacion)
  })
  
  
  ### TABLA CONSUMOS ###
  
  upload_consumos <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(NULL)
    }
    
    path <- file$datapath
    df <- path %>% 
      excel_sheets() %>% 
      set_names() %>% 
      map(~ read_excel(path, .x, col_names = TRUE))
    
    all_sheets <- excel_sheets(file$datapath)
    
    ConsumosDDDpor1000Estancias <- df[[which(all_sheets == "ConsumosDDDpor1000Estancias")]]
    ConsumosDDDpor1000Estancias <- ConsumosDDDpor1000Estancias %>%
      mutate(mes = as_date(mes))
    
    return(ConsumosDDDpor1000Estancias)
  })
  
  
  ### TABLA OBSERVACIONES SENSIBLES ###
  
  upload_obs_sensibles <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(NULL)
    }
    
    path <- file$datapath
    df <- path %>% 
      excel_sheets() %>% 
      set_names() %>% 
      map(~ read_excel(path, .x, col_names = TRUE))
    
    all_sheets <- excel_sheets(file$datapath)
    

    ResultadosSensibles <- df[[which(all_sheets == "ResultadosSensibles")]]
    ResultadosSensibles <- ResultadosSensibles %>%
      mutate(mes = as_date(mes))
    
    return(ResultadosSensibles)
  })
  
  
  ### TABLA OBSERVACIONES RESISTENTES ###
  
  upload_obs_resistentes <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(NULL)
    }
    
    path <- file$datapath
    df <- path %>% 
      excel_sheets() %>% 
      set_names() %>% 
      map(~ read_excel(path, .x, col_names = TRUE))
    
    all_sheets <- excel_sheets(file$datapath)
    
    
    ResultadosResistentes <- df[[which(all_sheets == "ResultadosResistentes")]]
    ResultadosResistentes <- ResultadosResistentes %>%
      mutate(mes = as_date(mes))
    
    return(ResultadosResistentes)
  })
  

  ### DICCIONARIO CONSUMOS (MEDICAMENTO/ANTIBIOTICO) ###
  
  #### PARA MOSTRAR ####
  
  upload_diccionario_meds <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(c("Sin diccionario"="NULL"))
    } else {
      
      path <- file$datapath
      
      df <- path %>%
        excel_sheets() %>%
        set_names() %>%
        map(~ read_excel(path, .x))
      
      all_sheets <- excel_sheets(file$datapath)
      
      DiccionarioConsumos <- df[[which(all_sheets == "DiccionarioConsumos")]]
      colnames(DiccionarioConsumos) <- c("Code","Name")
      
      return(DiccionarioConsumos)
    }
  })
  
  #### PARA LOS SELECCIONADORES ####
  
  upload_diccionario_meds_selec <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(c("Sin diccionario"="NULL"))
    } else {
      
    path <- file$datapath
      
    df <- path %>%
      excel_sheets() %>%
      set_names() %>%
      map(~ read_excel(path, .x))
      
    all_sheets <- excel_sheets(file$datapath)
      
    DiccionarioConsumos <- df[[which(all_sheets == "DiccionarioConsumos")]]
    colnames(DiccionarioConsumos) <- c("Code","Name")
    
    p <- setNames(DiccionarioConsumos$Code, DiccionarioConsumos$Name)
    
    return(p)
    }
  })
  
  ### DICCIONARIO RESISTENCIAS (BACTERIA/MICROORGANISMO) ###
  
  ####  PARA MOSTRAR ####
  upload_diccionario_micro <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(c("Sin diccionario"="NULL"))
    } else {
      
      path <- file$datapath
      
      df <- path %>%
        excel_sheets() %>%
        set_names() %>%
        map(~ read_excel(path, .x))
      
      all_sheets <- excel_sheets(file$datapath)
      
      DiccionarioResistencias <- df[[which(all_sheets == "DiccionarioResistencias")]]
      DiccionarioResistencias <- DiccionarioResistencias[,c(1,2)]
      colnames(DiccionarioResistencias) <- c("Code","Name")
      DiccionarioResistencias$Code <- substr(DiccionarioResistencias$Code, 1, 3)
      DiccionarioResistencias <- DiccionarioResistencias[!duplicated(DiccionarioResistencias$Code), ]
      
      return(DiccionarioResistencias)
    }
  })
  
  
  
  #### PARA LOS SELECCIONADORES ####
  upload_diccionario_micro_selec <- reactive({
    
    file <- input$file_input_excel
    
    if(is.null(file)){
      return(c("Sin diccionario"="NULL"))
    } else {
      
    path <- file$datapath
      
    df <- path %>%
      excel_sheets() %>%
      set_names() %>%
      map(~ read_excel(path, .x))
      
    all_sheets <- excel_sheets(file$datapath)
      
    DiccionarioResistencias <- df[[which(all_sheets == "DiccionarioResistencias")]]
    DiccionarioResistencias <- DiccionarioResistencias[,c(1,2)]
    colnames(DiccionarioResistencias) <- c("Code","Name")
    DiccionarioResistencias$Code <- substr(DiccionarioResistencias$Code, 1, 3)
    DiccionarioResistencias <- DiccionarioResistencias[!duplicated(DiccionarioResistencias$Code), ]
      
    p <- setNames(DiccionarioResistencias$Code, DiccionarioResistencias$Name)
      
    return(p)
    }
  })
  
  
  
  ## BOTONES PARA GUARDAR O BORRAR LA TABLA EN EL SISTEMA ##
  
  ### OBJETO PARA GUARDAR LA TABLA ###
  
  data <- reactiveValues(table_obs = NULL,table_cons=NULL,table_res= NULL,table_micro = c("Sin diccionario"="NULL"), table_meds = c("Sin diccionario"="NULL"))
  
  ### GUARDAR TABLA ###
  
  observeEvent(input$action_button_excel_ready, {
    data$table_obs <- uploaded_file()
    data$table_micro <- upload_diccionario_micro_selec()
    data$table_meds <- upload_diccionario_meds_selec()
    data$table_res <- upload_obs_resistentes()
    data$table_cons <- upload_consumos()
    output$check_excel <- renderUI(icon('check'))
  })
  
  
  ### BORRAR TABLA ###
  observeEvent(input$action_button_excel_not_ready, {
    data$table_obs <- NULL
    data$table_micro <- c("Sin diccionario"="NULL")
    data$table_meds <- c("Sin diccionario"="NULL")
    data$table_res <- NULL
    data$table_cons <- NULL
    output$check_excel <- renderUI(NULL)
  })
  
  
  
  ## VISUALIZADOR DE TABLAS ##
  
  output$tabla_output_visual <- renderDT({
    if(input$select_input_table_visual == "tabla_ocupacion"){
      datatable(upload_ocupacion(),
                options = list(
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 5,
                  paging = TRUE
                ))
    } else if(input$select_input_table_visual == "tabla_dicc_res"){
      datatable(upload_diccionario_micro(),
                options = list(
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 5,
                  paging = TRUE
                ))
    } else if(input$select_input_table_visual == "tabla_consumos"){
      datatable(upload_consumos(),
                options = list(
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 5,
                  paging = TRUE
                ))
    } else  if(input$select_input_table_visual == "tabla_sensibles"){
      datatable(upload_obs_sensibles(),
                options = list(
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 5,
                  paging = TRUE
                ))
    } else if(input$select_input_table_visual == "tabla_resistentes"){
      datatable(upload_obs_resistentes(),
                options = list(
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 5,
                  paging = TRUE
                ))
    } else if(input$select_input_table_visual == "tabla_dicc_cons"){
      datatable(upload_diccionario_meds(),
                options = list(
                  lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                  pageLength = 5,
                  paging = TRUE
                ))
    }else{
      return(NULL)
    }
  })
  
  
  
  
  
  
  
  ###
  ###         TAB: DATA INICIAL
  ###
  
  ## SELECCIONADORES DE GRAFICOS ALIMENTADOS POR EL FICHERO SUBIDO ##
  
  ### GRAFICOS DATA INICIAL ###
  
  output$output_select_input_med_data_inicial <- renderUI({
        selectInput("select_input_med_data_inicial","Seleccione antibiótico:",data$table_meds)
 
  })
  
  output$output_select_input_micro_data_inicial <- renderUI({
    selectInput("select_input_micro_data_inicial","Seleccione bacteria:",data$table_micro )
    
  })
  
  output$summary_data_ini <- renderPrint({
    df <- data$table_obs
    if (!is.null(df)) {
      res_col <- paste(input$select_input_micro_data_inicial, input$select_input_med_data_inicial, "_res", sep = "")
      sen_col <- paste(input$select_input_micro_data_inicial, input$select_input_med_data_inicial, "_sen", sep = "")
      
      if (all(c(res_col, sen_col) %in% colnames(df))) {

        df <- df %>%
          select(mes, !!sym(res_col), !!sym(sen_col), Ocupacion, !!sym(input$select_input_med_data_inicial)) %>%
          mutate(total = !!sym(res_col) + !!sym(sen_col)) %>%
          select(mes, !!sym(res_col), !!sym(sen_col), total, Ocupacion, !!sym(input$select_input_med_data_inicial)) %>%
          as.data.frame()
        
        
        
        return(describe(df[,-1]))
      } else {
        res_col <- paste(input$select_input_micro_data_inicial, input$select_input_med_data_inicial, "_res", sep = "")
        sen_col <- paste(input$select_input_micro_data_inicial, input$select_input_med_data_inicial, "_sen", sep = "")
          df <- df %>%
            select(mes, Ocupacion, !!sym(input$select_input_med_data_inicial)) %>%
            as.data.frame()
          
          
          return(describe(df[,-1]))
      }
    } else {
      return(print("Sin datos"))
    }
  })

  
  
  
  ## GENERADORES DE GRAFICOS ##
  
  ### GRAFICO DE BARRAS APILADAS ###
  
  output$plot_barras_apiladas <- renderPlotly({
    df <- data$table_obs
    if (!is.null(df)) {
      res_col <- paste(input$select_input_micro_data_inicial, input$select_input_med_data_inicial, "_res", sep = "")
      sen_col <- paste(input$select_input_micro_data_inicial, input$select_input_med_data_inicial, "_sen", sep = "")
      if (all(c(res_col, sen_col) %in% colnames(df))) {
        df <- df %>%
          select(mes, !!sym(res_col), !!sym(sen_col)) %>%
          as.data.frame()
        
        plot_ly(df, x = ~mes) %>%
          add_trace(y = ~get(res_col), name = "Resistencias", type = "bar") %>%
          add_trace(y = ~get(sen_col), name = "Sensibilidades", type = "bar") %>%
          layout(
            title = 'Observaciones Resistentes vs Sensibles',
            xaxis = list(title = "Mes"),
            yaxis = list(title = "Número de observaciones"),
            barmode = 'stack',
            plot_bgcolor = '#e5ecf6'
          )
      } else {
        plot_ly() %>%
          layout(
            title = "La combinación seleccionada no existe",
            xaxis = list(title = "Mes"),
            yaxis = list(title = "Número de observaciones")
          )
      }
    } else {
      plot_ly() %>%
        layout(
          title = "Sin datos disponibles",
          xaxis = list(title = "Mes"),
          yaxis = list(title = "Número de observaciones")
        )
    }
  })
  
  ### GRAFICO DE LINEAS TOTALES ###
  
  output$plot_line_totals <- renderPlotly({
    df <- data$table_obs
    if (!is.null(df)) {
      res_col <- paste(input$select_input_micro_data_inicial, input$select_input_med_data_inicial, "_res", sep = "")
      sen_col <- paste(input$select_input_micro_data_inicial, input$select_input_med_data_inicial, "_sen", sep = "")
      if (all(c(res_col, sen_col) %in% colnames(df))) {
        df <- df %>%
          select(mes, !!sym(res_col), !!sym(sen_col)) %>%
          mutate(total = !!sym(res_col) + !!sym(sen_col)) %>%
          as.data.frame()
        
        plot_ly(df, x = ~mes) %>%
          add_trace(y = ~get(res_col), name = "Resistencias", type = "scatter", mode = "lines", line = list(color = "blue")) %>%
          add_trace(y = ~get(sen_col), name = "Sensibilidades", type = "scatter", mode = "lines", line = list(color = "red")) %>%
          add_trace(y = ~total, name = "Total", type = "scatter", mode = "lines", line = list(color = "green")) %>%
          layout(
            title = 'Observaciones Resistencias, Sensibilidades y Total',
            xaxis = list(title = "Mes"),
            yaxis = list(title = "Número de observaciones"),
            plot_bgcolor = '#e5ecf6'
          )
      } else {
        plot_ly() %>%
          layout(
            title = "La combinación seleccionada no existe",
            xaxis = list(title = "Mes"),
            yaxis = list(title = "Número de observaciones")
          )
      }
    } else {
      plot_ly() %>%
        layout(
          title = "Sin datos disponibles",
          xaxis = list(title = "Mes"),
          yaxis = list(title = "Número de observaciones")
        )
    }
  })
  
  
  
  ### GRAFICO LINE PLOT OCUPACIONES ###
  
  output$plot_hospitalizaciones <- renderPlotly({
    df <- data$table_obs
    if (!is.null(df)) {
      if ("Ocupacion" %in% colnames(df)) {
        df <- df %>%
          select(mes, Ocupacion) %>%
          as.data.frame()
        
        plot_ly() %>%
          add_trace(data = df, x = ~mes, y = ~Ocupacion, type = 'scatter', mode = 'lines', fill = 'tozeroy', name = 'Ocupacion') %>%
          layout(
            title = 'Hospitalizaciones',
            showlegend = F,
            yaxis = list(title = "Hospitalizaciones", zerolinecolor = '#ffff', zerolinewidth = 2, gridcolor = '#ffff'),
            xaxis = list(title = "Mes", zerolinecolor = '#ffff', zerolinewidth = 2, gridcolor = '#ffff'),
            plot_bgcolor = '#e5ecf6',
            width = 900
          )
      } else {
        plot_ly() %>%
          layout(
            title = "La columna 'Ocupacion' no existe",
            xaxis = list(title = "Mes"),
            yaxis = list(title = "Hospitalizaciones")
          )
      }
    } else {
      plot_ly() %>%
        layout(
          title = "Sin datos disponibles",
          xaxis = list(title = "Mes"),
          yaxis = list(title = "Hospitalizaciones")
        )
    }
  })
  
  
  ### GRAFICO SERIE CONSUMOS ###
  
  output$plot_serie_consumos <- renderPlotly({
    df <- data$table_obs
    if (!is.null(df)) {
      if (input$select_input_med_data_inicial %in% colnames(df)) {
        df <- df %>%
          select(mes, !!sym(input$select_input_med_data_inicial)) %>%
          as.data.frame()
        
        plot_ly() %>%
          add_trace(data = df, x = ~mes, y = ~get(input$select_input_med_data_inicial), type = 'scatter', mode = 'lines', fill = 'tozeroy', name = 'Antibiótico') %>%
          layout(
            title = 'Consumos',
            showlegend = F,
            yaxis = list(title = "Consumos", zerolinecolor = '#ffff', zerolinewidth = 2, gridcolor = '#ffff'),
            xaxis = list(title = "Mes", zerolinecolor = '#ffff', zerolinewidth = 2, gridcolor = '#ffff'),
            plot_bgcolor = '#e5ecf6',
            width = 900
          )
      } else {
        plot_ly() %>%
          layout(
            title = "La columna seleccionada no existe",
            xaxis = list(title = "Mes"),
            yaxis = list(title = "Consumos")
          )
      }
    } else {
      plot_ly() %>%
        layout(
          title = "Sin datos disponibles",
          xaxis = list(title = "Mes"),
          yaxis = list(title = "Consumos")
        )
    }
  })

  
    

  
  
  ###
  ###         TAB: DATA ELABORADA
  ###
  
  ## SELECCIONADORES DE GRAFICOS ALIMENTADOS POR EL FICHERO SUBIDO ##
  
  output$output_select_input_med_data_elaborada <- renderUI({
    selectInput("select_input_med_data_elaborada","Seleccione antibiótico:",data$table_meds )
    
  })
  
  output$output_select_input_micro_data_elaborada <- renderUI({
    selectInput("select_input_micro_data_elaborada","Seleccione bacteria:",data$table_micro )
    
  })
  
  ## GENERADORES DE GRAFICOS ##
  
  ### GRAFICO % RESISTENCIAS ###
  
  output$plot_porcentaje_resistencias <- renderPlotly({
    df <- data$table_obs
    if (!is.null(df)) {
      res_col <- paste(input$select_input_micro_data_elaborada, input$select_input_med_data_elaborada, "_res", sep = "")
      sen_col <- paste(input$select_input_micro_data_elaborada, input$select_input_med_data_elaborada, "_sen", sep = "")
      if (any(colnames(df) %in% c(res_col, sen_col))) {
        df <- df %>%
          select(mes, !!sym(res_col), !!sym(sen_col))
        
        df <- df %>%
          mutate(
            porc_res = (!!sym(res_col) / (!!sym(res_col) + !!sym(sen_col))) * 100
          )
        df <- as.data.frame(df)
        
        plot_ly() %>%
          add_trace(data = df[, c("mes", "porc_res")], type = 'scatter', mode = 'lines', fill = 'tozeroy', x = ~df[, "mes"], y = ~df[, "porc_res"], name = 'Resistencias') %>%
          layout(
            title = 'Porcentaje de Resistencias',
            showlegend = F,
            yaxis = list(
              title = "Porcentaje de observaciones resistentes",
              zerolinecolor = '#ffff',
              zerolinewidth = 2,
              gridcolor = 'ffff'
            ),
            xaxis = list(
              title = "Mes",
              zerolinecolor = '#ffff',
              zerolinewidth = 2,
              gridcolor = 'ffff'
            ),
            plot_bgcolor = '#e5ecf6',
            width = 900
          )
      } else {
        plot_ly() %>%
          layout(
            title = "La combinación seleccionada no existe",
            xaxis = list(title = "Mes"),
            yaxis = list(title = "% Resistencias")
          )
      }
    } else {
      plot_ly() %>%
        layout(
          title = "Sin datos disponibles",
          xaxis = list(title = "Mes"),
          yaxis = list(title = "% Resistencias")
        )
    }
  })
  
  
  ### GRAFICO TDI ###
  
  output$plot_TDI <- renderPlotly({
    df <- data$table_obs
    if (!is.null(df)) {
      res_col <- paste(input$select_input_micro_data_elaborada, input$select_input_med_data_elaborada, "_res", sep = "")
      if (res_col %in% colnames(df)) {
        df <- df %>%
          select(mes, Ocupacion, !!sym(res_col)) %>%
          mutate(TDI = (!!sym(res_col) * 1000) / Ocupacion) %>%
          as.data.frame()
        
        plot_ly() %>%
          add_trace(data = df, x = ~mes, y = ~TDI, type = 'scatter', mode = 'lines', fill = 'tozeroy', name = 'TDI') %>%
          layout(
            title = 'Tasa de Infección por Dosis (TDI)',
            showlegend = F,
            yaxis = list(title = "TDI", zerolinecolor = '#ffff', zerolinewidth = 2, gridcolor = '#ffff'),
            xaxis = list(title = "Mes", zerolinecolor = '#ffff', zerolinewidth = 2, gridcolor = '#ffff'),
            plot_bgcolor = '#e5ecf6',
            width = 900
          )
      } else {
        plot_ly() %>%
          layout(
            title = "La combinación seleccionada no existe",
            xaxis = list(title = "Mes"),
            yaxis = list(title = "TDI")
          )
      }
    } else {
      plot_ly() %>%
        layout(
          title = "Sin datos disponibles",
          xaxis = list(title = "Mes"),
          yaxis = list(title = "TDI")
        )
    }
  })
  

  
  
  
  
  
  
  
  
  ###
  ###     TAB : MODELOS         
  ###
  
  ### OBJETO REACTIVO ###
  
  dt <- reactiveValues(AMC = NULL, AMR = NULL, data = NULL)
  
  ### GUARDAR MODELOS ###
  
  observeEvent(input$action_button_models_1_ready, {
    dt$AMC <- AMC_pre()
    dt$AMR <- AMR_pre()
    dt$data <- dat_1()
    output$check_models_1 <- renderUI(icon('check'))
  })
  
  observeEvent(input$action_button_models_2_ready, {
    dt$AMC <- AMC_manual()
    dt$AMR <- AMR_manual()
    dt$data <- dat_2()
    output$check_models_2 <- renderUI(icon('check'))
  })
  
  
  
  
  
  ### MODELOS A PARTIR DE FICHERO PREDETERMINADO ###
  
  
  
  upload_mod <- reactive({
    file <- input$file_input_models
    
    if (is.null(file)) {
      return(NULL)
    }
    
    path <- file$datapath  # Cambiado de file$path a file$datapath
    mod <- read.csv2(path, stringsAsFactors = FALSE)  # Asegurarse de que los factores no se conviertan automáticamente
    mod <- as.list(mod)
    modelos <- names(mod)
    modelos <- substr(modelos, 1, 6)
    mod <- mod[!modelos %in% c("ecoMEM")] 
    return(mod)
  })
  
  upload_modelos <- reactive({
    file <- input$file_input_models
    
    if (is.null(file)) {
      return(NULL)
    }
    
    path <- file$datapath  # Cambiado de file$path a file$datapath
    mod <- read.csv2(path, stringsAsFactors = FALSE)  # Asegurarse de que los factores no se conviertan automáticamente
    mod <- as.list(mod)
    modelos <- names(mod)
    modelos <- substr(modelos, 1, 6)
    modelos <- modelos[!modelos %in% c("ecoMEM")]
    return(modelos)
  })
  
  
  output$output_select_input_modelo_1 <- renderUI({
    selectInput("select_input_modelo_1", "Seleccione modelo:",upload_modelos())
  })
  

  dat_1 <- reactive({
    lista_consumos <- upload_mod()[[input$select_input_modelo_1]]
    lista_consumos <- lista_consumos[lista_consumos != ""]

    if (length(lista_consumos) == 0) {
      return(NULL)
    }

    cons <- data$table_cons[, c("mes", lista_consumos)]
    res <- data$table_res[, c("mes", input$select_input_modelo_1)]

    df <- merge(res, cons, by = "mes")
    df<- df[-c(1:5),-1]
    return(df)
  })




  output$tabla_prueba_1 <- renderDT(datatable(dat_1(),
                                               options = list(
                                                lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                                               pageLength = 5,
                                                paging = TRUE
                                                  )))
  
  AMC_pre <-reactive({
    lista_consumos <- upload_mod()[[input$select_input_modelo_1]]
    lista_consumos <- lista_consumos[lista_consumos != ""]
    
    if (length(lista_consumos) == 0) {
      return(NULL)
    }
    return(lista_consumos)
  })
  AMR_pre <- reactive({
    return(input$select_input_modelo_1)
  })
  
  ###  MODELOS A PARTIR DE SELECCIÓN ###
  
  
  output$output_select_input_modelo_2 <- renderUI({
    selectInput("select_input_modelo_2", "Seleccione variable respuesta / AMR:",names(data$table_res)[-c(1)])
  })
  
  

  output$check_box_output_modelos <- renderUI({
    prettyCheckboxGroup(
      "check_box_input_modelos",
      "Seleccione variables explicativas / AMC:",
      choices = colnames(data$table_cons[-c(1)]),
      selected = NULL,
      shape = c("curve"),
      outline = TRUE,
      fill = TRUE,
      inline = TRUE
    )
    
  })
  
  
  dat_2 <- reactive({

    if(length(input$check_box_input_modelos)==0){
      res <- data$table_res[, c("mes", input$select_input_modelo_2)]
      df <- res
      df<- df[-c(1:5),-1]
      return(df)
    } else {
    cons <- data$table_cons[, c("mes", input$check_box_input_modelos)]
    res <- data$table_res[, c("mes", input$select_input_modelo_2)]
    
    df <- merge(res, cons, by = "mes")
    df<- df[-c(1:5),-1]
    return(df)}
  })
  

  output$tabla_prueba_2 <- renderDT(datatable(dat_2(),
                                              options = list(
                                                lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                                                pageLength = 5,
                                                paging = TRUE
                                              )))
  
  
  AMR_manual <-reactive({
    return(input$select_input_modelo_2)
  })
  AMC_manual <- reactive({
    return(input$check_box_input_modelos)
  })



   # EXPLORACION





   serie <- reactive({

     cons <- data$table_cons[, c("mes", dt$AMC)]
     res <- data$table_res[, c("mes", dt$AMR)]

     df <- merge(res, cons, by = "mes")

     df <- df[-c(1:5),]

     start_date <- as.Date(df$mes[1])
     end_date <- as.Date(df$mes[nrow(df)])

     start_year <- as.numeric(format(start_date, "%Y"))
     start_month <- as.numeric(format(start_date, "%m"))

     end_year <- as.numeric(format(end_date, "%Y"))
     end_month <- as.numeric(format(end_date, "%m"))

     df <- df[, -which(names(df) == "mes")]

     df_ts <- ts(df, start = c(start_year, start_month), end = c(end_year, end_month), freq = 12)

     return(df_ts)
   })
   
   output$plot_ts <- renderPlot({
     if(is.null(dt$AMC) || is.null(dt$AMR) ){
        return(NULL)
     } else {
       df_ts <- serie()
       a <- dt$AMR
       plot(df_ts, main = a)
     }
   })
   


  ### EXPLORACION ENTRE MODELOS


   
   output$output_checkbox_retardos <- renderUI({
       
     

      
       AMR <- dt$AMR
       AMC <- dt$AMC
       
       if(is.null(AMC)){
         return("")
       } else {
         dat <- serie()
         la=1:8
         nam <- c()
         for (v in AMR){
           for (i in 1:length(la)) {
             nam<-c(nam,paste(v,i,sep="_"))
           }
         }
         
         for (v in AMC){
           for (i in 1:length(la)) {
             nam<-c(nam,paste(v,i,sep="_"))
           }
         }
         return(
         prettyCheckboxGroup(
           "check_box_input_retardos",
           "Retardos disponibles:",
           choices = nam,
           selected = NULL,
           shape = c("curve"),
           outline = FALSE,
           fill = TRUE,
           thick = FALSE,
           bigger = FALSE,
           inline = TRUE))
       }
       

   })
   
   
   
   
   forms <- reactiveValues(data=NULL)
   
   
   observeEvent(input$usar_retardos_1, {
      forms$data <- data_retardos_1()

   })
   
   observeEvent(input$usar_retardos_2, {
     forms$data <- data_retardos_2()

   })
   
  


   data_retardos_1 <- reactive({
     dat <- serie()
     
     n <- input$numeric_input_AMR
     m <- input$numeric_input_AMC
     AMR <- c(dt$AMR)
     AMC <- c(dt$AMC)
     
     df <- dat[,1]
     nam <- c(AMR)
     
     for(v in AMR){
     for (i in 1:n) {
       df <- cbind(df,stats::lag(dat[,v], i)) 
       nam <- c(nam,paste(v, i, sep="_"))
     }
     }
     
     
     for(v in AMC){
       for (i in 1:m) {
         df <- cbind(df,stats::lag(dat[,v], i)) 
         nam <- c(nam,paste(v, i, sep="_"))
       }
     }
     
      colnames(df) <- nam
     return(df)
   })
   
   # data_amc_1 <- reactive({
   #   dat <- serie()
   #   
   #   m <- input$numeric_input_AMC
   #   AMR <- c(dt$AMR)
   #   AMC <- c(dt$AMC)
   #   nam <- c()
   #   df <- dat[,1]
   #   
   #   for(v in AMC){
   #     for (i in 1:m) {
   #       df <- cbind(df,stats::lag(dat[,v], i)) 
   #       nam <- c(nam,paste(v, i, sep="_"))
   #     }
   #   }
   #   
   #   colnames(df) <- nam
   #   return(df[,-1])
   # })
   # 

   
   
   
   
   
   
   
   # if(input$action_button_intercept_no == TRUE){
   #   int <- NULL
   # } else {
   #   int <- "0"
   # }
   # 
   # 
   # a <- c(int,nam)
   
   
   
   data_retardos_2 <- reactive({
     dat <- serie()
     
     vector <- c(input$check_box_input_retardos)
     
     variables <- substr(vector, 1, nchar(vector) - 2)
     retardos<- substr(vector, nchar(vector), nchar(vector))
     retardos <- as.numeric(retardos)
     
     AMR <- c(dt$AMR)
     AMC <- c(dt$AMC)
     
     df <- dat[,1]
     nam <- c(AMR)
     
     for(ind in 1:length(variables)){
          i <- retardos[ind]
          v <- variables[ind]
         df <- cbind(df,stats::lag(dat[,v], i)) 
         nam <- c(nam,paste(v, i, sep="_"))
     }
     

     colnames(df) <- nam
     return(df)
     
   })
   
   # 
   # 
   # data_amc_2 <- reactive({
   #   dat <- serie()
   #   
   #   AMC <- c(dt$AMC)
   #   
   #   b <- c(names(coef(modelo_a_usar())))
   #   c <- c()
   #   for(i in 1:length(b)){
   #     if(substr(b[i],1,nchar(b[i])-2) %in% AMC){
   #       c <- c(c,b[i])
   #     }
   #   }
   #   
   #   vector <- c(input$check_box_input_retardos)
   #   
   #   variables <- substr(vector, 1, nchar(vector) - 2)
   #   retardos<- substr(vector, nchar(vector), nchar(vector))
   #   retardos <- as.numeric(retardos)
   # 
   #   
   #   df <- dat[,1]
   #   nam <- c(AMR)
   #   
   #   for(ind in 1:length(variables)){
   #     i <- retardos[ind]
   #     v <- variables[ind]
   #     df <- cbind(df,stats::lag(dat[,v], i)) 
   #     nam <- c(nam,paste(v, i, sep="_"))
   #   }
   #   
   #   
   #   colnames(df) <- nam
   #   df <- df[,c %in% colnames(df)]
   #   return(df)
   #   
   # })
   # 
   
   m1 <- reactive({
     
     df <- forms$data
     AMR <- dt$AMR
     form0 <- as.formula(paste0(AMR, "~ ."))
    if(input$action_button_intercept_no_1 == TRUE || input$action_button_intercept_no_2==TRUE){
        form0 <- as.formula(paste0(AMR, "~ . - 1"))
      } else {
        form0 <- as.formula(paste0(AMR, "~ ."))
      }


     if(is.null(df)){
       m1 <- NULL
     } else {
     m1 <- lm(form0, na.omit(df))
     }
     return(m1)
   })
   

  m2 <- reactive({
    
    df <- forms$data
    AMR <- dt$AMR

    form1=as.formula(paste0(AMR,"~1"))
    if(is.null(df)){
      m2 <- NULL
    }else {
      if(input$select_input_AIC_1 == 2){
        a <- 2
      } else {
        a <- log(nrow(df))
      }
    m2<-step(m1(),scope=list(lower=form1),trace=F,k=a)
}
    return(m2)

  })
  
  
  
  


  output$summary_m1 <- renderPrint({
    if(is.null(m1())){
      return("NULL")
    } else {
      return(summary(m1()))
    }
  })


  output$summary_m2 <- renderPrint({
    if(is.null(m2())){
      return("NULL")
    } else {
    return(summary(m2()))
    }
  })

  output$plot_m1 <- renderPlot({
    
    if(is.null(forms$data)){
      return(NULL)
    } else {
    par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))
    plot(m1(),which=1,ask=F)
    plot(m1(),which=2,ask=F)
    plot(m1(),which=3,ask=F)
    plot(m1(),which=4,ask=F)
}
  })
  

  output$plot_m2 <- renderPlot({
    
    if(is.null(forms$data)){
      return(NULL)
    } else {
    par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))
    plot(m2(),which=1,ask=F)
    plot(m2(),which=2,ask=F)
    plot(m2(),which=3,ask=F)
    plot(m2(),which=4,ask=F)
}
  })

  output$plot_acf_m1 <- renderPlot({
    
    if(is.null(forms$data)){
      return(NULL)
    } else {
    par(mfrow=c(1,2))
    acf(resid(m1()),ylim=c(-1,1),lwd=2)
    pacf(resid(m1()),ylim=c(-1,1),lwd=2)
}
  })

output$plot_acf_m2 <- renderPlot({
  
  if(is.null(forms$data)){
    return(NULL)
  } else {
  par(mfrow=c(1,2))
  acf(resid(m2()),ylim=c(-1,1),lwd=2)
  pacf(resid(m2()),ylim=c(-1,1),lwd=2)
}
})


  ### ARMAX

modelo_a_usar <- reactive({
    m <- m1()
  if(input$select_input_modelo_usar_ARMAX == "m2"){
    m <- m2()
  } else {
    m <- m1()
  }
  return(m)
  
})


m3 <- reactive({
  df <- forms$data
  
  AMC <- c(dt$AMC)
  
  b <- c(names(coef(modelo_a_usar())))
  c <- c()
  for(i in 1:length(b)){
    if(substr(b[i],1,nchar(b[i])-2) %in% AMC){
      c <- c(c,b[i])
    }
  }

  # b <- b[nchar(b)==5]
  a<- df[,c]


  if(is.null(df)){
    m3 <- NULL
  } else {
    if (length(names(coef(modelo_a_usar()))) > 2) {
      m3 <- auto.arima(df[,1], max.p=input$numeric_input_p, max.q=input$numeric_input_q, max.d=input$numeric_input_d, max.P=input$numeric_input_P, max.D=input$numeric_input_D, max.Q=input$numeric_input_Q, xreg=a)
    } else {
      m3 <- auto.arima(df[,1], max.p=input$numeric_input_p, max.q=input$numeric_input_q, max.P=input$numeric_input_P, max.Q=input$numeric_input_Q)
    }
  }
  
  return(m3)
})

output$autoarima_m3 <- renderPrint({
  if(is.null(forms$data)){
    return("NULL")
  } else {
    print(m3())
  }
})


output$t_ratios <- renderPrint({
  if(is.null(forms$data)){
    return("NULL")
  } else {
  d <- sqrt(diag(m3()$var.coef))
  c <- m3()$coef
  t_ratios <- c/d
  a <- data.frame(t_ratios)
  a <- t(a)
  colnames(a) <- names(coef(m3()))
  print(a)
  }
})


m1_auto <- reactive({
  df <- forms$data
  
  if (is.null(df)) {
    m1 <- NULL
  } else {
    dat <- serie()
    AMR <- dt$AMR
    AMC <- dt$AMC
    df <- dat[, 1]
    nam <- c(AMR)
    p <- length(m3()$model$phi)
    b <- c(names(coef(modelo_a_usar())))
    
    if (p > 0) {
      for (i in 1:p) {
        df <- cbind(df, stats::lag(dat[, 1], i))
        nam <- c(nam, paste(AMR, i, sep = "_"))
      }
    }
    
    amc_added <- FALSE
    for (v in AMC) {
      for (i in 1:8) {
        if (paste(v, i, sep = "_") %in% b) {
          df <- cbind(df, stats::lag(dat[, v], i))
          nam <- c(nam, paste(v, i, sep = "_"))
          amc_added <- TRUE
        }
      }
    }
    
    if (p == 0 && amc_added == FALSE) {
      df <- dat[, 1, drop = FALSE]
      nam <- c(AMR)
    }
    
    colnames(df) <- nam
    if (!any(nam %in% paste(AMC, 1:8, sep = "_")) && p == 0) {
      form0 <- as.formula(paste0(AMR, " ~ 1"))
    } else {
      form0 <- as.formula(paste0(AMR, "~ ."))
      if (input$action_button_intercept_no_1 == TRUE || input$action_button_intercept_no_2 == TRUE) {
        form0 <- as.formula(paste0(AMR, "~ . - 1"))
      }
    }
    
    m1 <- lm(form0, na.omit(df))
  }
  return(m1)
})

m2_auto <- reactive({
  df <- forms$data
  
  if (is.null(df)) {
    m2 <- NULL
  } else {
    dat <- serie()
    AMR <- dt$AMR
    AMC <- dt$AMC
    df <- dat[, 1]
    nam <- c(AMR)
    p <- length(m3()$model$phi)
    b <- c(names(coef(modelo_a_usar())))
    
    amc_added <- FALSE
    
    if (p > 0) {
      for (i in 1:p) {
        df <- cbind(df, stats::lag(dat[, 1], i))
        nam <- c(nam, paste(AMR, i, sep = "_"))
      }
    }
    
    for (v in AMC) {
      for (i in 1:8) {
        if (paste(v, i, sep = "_") %in% b) {
          df <- cbind(df, stats::lag(dat[, v], i))
          nam <- c(nam, paste(v, i, sep = "_"))
          amc_added <- TRUE
        }
      }
    }
    
    if (p == 0 && amc_added == FALSE) {
      df <- dat[, 1, drop = FALSE]
      nam <- c(AMR)
    }
    
    colnames(df) <- nam
    
    if (!any(nam %in% paste(AMC, 1:8, sep = "_")) && p == 0) {
      form0 <- as.formula(paste0(AMR, " ~ 1"))
      form1 <- as.formula(paste0(AMR, " ~ 1"))
    } else if (p > 0) {
      form0 <- as.formula(paste0(AMR, " ~ ."))
      form1 <- as.formula(paste0(AMR, " ~ ", paste0(AMR, "_", 1:p, collapse = "+")))
    } else {
      form0 <- as.formula(paste0(AMR, " ~ ."))
      form1 <- as.formula(paste0(AMR, " ~ 1"))
    }
    
    m1 <- lm(form0, data = na.omit(df))
    
    if (input$select_input_AIC_2 == 2) {
      a <- 2
    } else {
      a <- log(nrow(df))
    }
    
    m2 <- step(m1, scope = list(lower = form1), trace = FALSE, k = a)
  }
  return(m2)
})



# 
# m1_auto <- reactive({
# 
#   df <- forms$data
# 
# 
#   if(is.null(df)){
#     m1 <- NULL
#   } else {
#     dat <- serie()
#     AMR <- dt$AMR
#     AMC <- dt$AMC
#     df <- dat[,1]
#     p <- length(m3()$model$phi)
#     nam <- c(AMR)
#     b <- c(names(coef(modelo_a_usar())))
#     
#     if(p>0){
#         for (i in 1:p) {
#           df <- cbind(df,stats::lag(dat[,1], i))
#           nam <- c(nam,paste(AMR, i, sep="_"))
#         }
#       
#       for(v in AMC){
#         for (i in 1:8) {
#           if(paste(v, i, sep="_") %in% b ){
#             df <- cbind(df,stats::lag(dat[,v], i))
#             nam <- c(nam,paste(v, i, sep="_"))
#           }
#         }
#       } 
#     } 
#       
#       
#       colnames(df) <- nam
#       form0 <- as.formula(paste0(AMR, "~ ."))
#       if(input$action_button_intercept_no_1 == TRUE || input$action_button_intercept_no_2==TRUE){
#         form0 <- as.formula(paste0(AMR, "~ . - 1"))
#       } else {
#         form0 <- as.formula(paste0(AMR, "~ ."))
#       }
# 
#       m1 <- lm(form0, na.omit(df))
# 
# 
# 
#     
#   }
#   return(m1)
# })
# 
# m2_auto <- reactive({
#   
#   df <- forms$data
#   AMR <- c(dt$AMR)
#   
# 
#   if(is.null(df)){
#     m2 <- NULL
#   }else {
#     dat <- serie()
#     AMR <- dt$AMR
#     AMC <- dt$AMC
#     df <- dat[,1]
#     nam <- c(AMR)
#     p <- length(m3()$model$phi)
#     b <- c(names(coef(modelo_a_usar())))
#     
#     
#     form1<-as.formula(paste0(AMR,"~",paste0(AMR,"_",1:p,collapse="+")))
#       if(p>0){
#         for (i in 1:p) {
#           df <- cbind(df,stats::lag(dat[,1], i))
#           nam <- c(nam,paste(AMR, i, sep="_"))
#         }
#         
#         for(v in AMC){
#           for (i in 1:8) {
#             if(paste(v, i, sep="_") %in% b ){
#               df <- cbind(df,stats::lag(dat[,v], i))
#               nam <- c(nam,paste(v, i, sep="_"))
#             }
#           }
#         }
#         
#       }
#     
#     
#     colnames(df) <- nam
#     form0 <- as.formula(paste(AMR, "~."))
#     m1 <- lm(form0, na.omit(df))
#    
#     if(input$select_input_AIC_2 == 2){
#       a <- 2
#     } else {
#       a <- log(nrow(df))
#     }
#     
#     m2<-step(m1,scope=list(lower=form1),trace=F,k=a)#log(nrow(df)))))
#   }
#   return(m2)
#   
# })






output$summary_m1_auto <- renderPrint({
  if(is.null(m1_auto())){
    return("NULL")
  } else {
    return(summary(m1_auto()))
  }
})


output$summary_m2_auto <- renderPrint({
  if(is.null(m2_auto())){
    return("NULL")
  } else {
    return(summary(m2_auto()))
  }
})


output$plot_m1_arima <- renderPlot({
  
  
  if(is.null(forms$data)){
    return(NULL)
  } else {
  par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))
  plot(m1_auto(),which=1,ask=F)
  plot(m1_auto(),which=2,ask=F)
  plot(m1_auto(),which=3,ask=F)
  plot(m1_auto(),which=4,ask=F)
}
})


output$plot_m2_arima <- renderPlot({
  if(is.null(forms$data)){
    return(NULL)
  } else {
  par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))
  plot(m2_auto(),which=1,ask=F)
  plot(m2_auto(),which=2,ask=F)
  plot(m2_auto(),which=3,ask=F)
  plot(m2_auto(),which=4,ask=F)}
})


output$plot_acf_m1_arima <- renderPlot({
  if(is.null(forms$data)){
    return(NULL)
  } else {
  par(mfrow=c(1,2))
  acf(resid(m1_auto()),ylim=c(-1,1),lwd=2)
  pacf(resid(m1_auto()),ylim=c(-1,1),lwd=2)}

})

output$plot_acf_m2_arima <- renderPlot({
  if(is.null(forms$data)){
    return(NULL)
  } else {
  par(mfrow=c(1,2))
  acf(resid(m2_auto()),ylim=c(-1,1),lwd=2)
  pacf(resid(m2_auto()),ylim=c(-1,1),lwd=2)}

})

# MARS

m5 <- reactive({
  if (length(coef(m2_auto())) > 2) {
    df <- forms$data
    
    if (is.null(df)) {
      m5 <- NULL
    } else {
      p <- length(m3()$model$phi)
      pp <- p + 1
      vars <- c(names(coef(m2_auto()))[-c(1:c(pp))])
      np = 6
      ng = 10
      ms = 50
      
      dat <- serie()
      AMR <- dt$AMR
      AMC <- c(dt$AMC)
      df <- dat[, 1]
      nam <- c(AMR)
      b <- c(names(coef(modelo_a_usar())))
      
      amc_added <- FALSE
      if (p > 0) {
        for (i in 1:p) {
          df <- cbind(df, stats::lag(dat[, 1], i))
          nam <- c(nam, paste(AMR, i, sep = "_"))
        }
        for (v in AMC) {
          for (i in 1:8) {
            if (paste(v, i, sep = "_") %in% b) {
              df <- cbind(df, stats::lag(dat[, v], i))
              nam <- c(nam, paste(v, i, sep = "_"))
              amc_added <- TRUE
            }
          }
        }
      } else {
        for (v in AMC) {
          for (i in 1:8) {
            if (paste(v, i, sep = "_") %in% b) {
              df <- cbind(df, stats::lag(dat[, v], i))
              nam <- c(nam, paste(v, i, sep = "_"))
              amc_added <- TRUE
            }
          }
        }
      }
      
      if (p == 0 && amc_added == FALSE) {
        df <- dat[, 1, drop = FALSE]
        nam <- c(AMR)
      }
      
      colnames(df) <- nam
      
      if (p > 0 && amc_added) {
        form3 <- as.formula(paste0(AMR, "~", paste0(AMR, "_", 1:p, collapse = "+"), "+", paste0(vars, collapse = "+")))
      } else if (p == 0 && amc_added) {
        form3 <- as.formula(paste0(AMR, "~", paste0(vars, collapse = "+")))
      } else if (p > 0) {
        form3 <- as.formula(paste0(AMR, "~", paste0(AMR, "_", 1:p, collapse = "+")))
      } else {
        form3 <- as.formula(paste0(AMR, "~ 1"))
      }
      
      m5 <- earth(form3, data = na.omit(df), nfold = 1, nk = ng, minspan = ms,
                  nprune = np, linpreds = paste0(AMR, "_", 1:p), trace = 4, pmethod = "exh")
    }
    return(m5)
  }
})



# 
# m5 <- reactive({
#   if (length(coef(m2_auto())) > 2) {
# 
#     df <- forms$data
# 
#     if(is.null(df)){
#       m5 <- NULL
#     }else {
#       
#       p <- length(m3()$model$phi)
#       pp <- p+1
#       vars=c(names(coef(m2_auto()))[-c(1:c(pp))])
#       np=6
#       ng=10
#       ms=50
# 
# 
# 
#       dat <- serie()
#       AMR <- dt$AMR
#       AMC <- c(dt$AMC)
#       df <- dat[,1]
#       nam <- c(AMR)
#       b <- c(names(coef(modelo_a_usar())))
#       if(p>0){
#         for (i in 1:p) {
#           df <- cbind(df,stats::lag(dat[,1], i))
#           nam <- c(nam,paste(AMR, i, sep="_"))
#         }
#         for(v in AMC){
#           for (i in 1:8) {
#             if(paste(v, i, sep="_") %in% b ){
#               df <- cbind(df,stats::lag(dat[,v], i))
#               nam <- c(nam,paste(v, i, sep="_"))
#             }
#           }
#         }
#       } else {
#         for (i in 1:p) {
#           df <- cbind(df,stats::lag(dat[,1], i))
#           nam <- c(nam,paste(AMR, i, sep="_"))
#         }
#         
#       }
#         
#       colnames(df) <- nam
# 
#       if (p>0){
#         form3<-as.formula(paste0(AMR,"~",paste0(AMR,"_",1:p,collapse="+"),"+",paste0(vars,collapse="+")))
#       } else{
#         form3<-as.formula(paste0(AMR,"~",paste0(vars,collapse="+")))
#       }
# 
# 
#       # form0 <- as.formula(paste0(AMR, "~."))
# 
#       m5<-earth(form3,data=na.omit(df),nfold=1,nk=ng,minspan=ms,
#                 nprune=np,linpreds=paste0(AMR,"_",1:p),trace=4,pmethod="exh")
# 
# 
#     }
# 
#     return(m5)
#   }
# })

output$summary_mars <- renderPrint({
  if(is.null(forms$data)){
    return("NULL")
  } else {
  a <- m5()
  print(a)}
})

output$plotmo_mars <- renderPlot({
  if(is.null(forms$data)){
    return("NULL")
  } else {
  a <- m5()
  plotmo(a, ask=FALSE)}
})

output$plot_res_mars <- renderPlot({
  if(is.null(forms$data)){
    return("NULL")
  } else {
  cons <- data$table_cons[, c("mes", dt$AMC)]
  res <- data$table_res[, c("mes", dt$AMR)]
  
  df <- merge(res, cons, by = "mes")
  
  df <- df[-c(1:5),]
  
  start_date <- as.Date(df$mes[1])
  
  start_year <- as.numeric(format(start_date, "%Y"))
  start_month <- as.numeric(format(start_date, "%m"))
  
  plot(ts(resid(m5()),start=c(start_year,start_month),freq=12),main="Residuos")}
})



output$plot_qq_mars <- renderPlot({
  if(is.null(forms$data)){
    return("NULL")
  } else {
  qqnorm(resid(m5()))
  qqline(resid(m5()), col=2, lwd=2)}
})


output$plot_acf_mars <- renderPlot({
  if(is.null(forms$data)){
    return("NULL")
  } else {
  par(mfrow=c(1,2))
  acf(resid(m5()), ylim=c(-1,1), lwd=2, main="Residuos")
  pacf(resid(m5()), ylim=c(-1,1), lwd=2, main="Residuos")}
})



output$plot_final_mars <- renderPlot({
  if(is.null(forms$data)){
    return("NULL")
  } else {
  AMR <- dt$AMR
  cons <- data$table_cons[, c("mes", dt$AMC)]
  res <- data$table_res[, c("mes", dt$AMR)]
  
  df <- merge(res, cons, by = "mes")
  
  df <- df[-c(1:5),]
  
  start_date <- as.Date(df$mes[1])
  
  start_year <- as.numeric(format(start_date, "%Y"))
  start_month <- as.numeric(format(start_date, "%m"))
  
  par(mfrow=c(1,1))
  plot(ts(df[,AMR], start=start_year, freq=12))
  lines(ts(predict(m5()), start=c(start_year, start_month), freq=12), col=2)
  legend("topright", legend=c(AMR,"NL-TSA Model"), col=c(1,2), lty=1)}
})






# 
# Plot1 <- reactive({
#   plot(
#     x=x(), y=y(), main = "iris dataset plot", xlab = xl(), ylab = yl()
#   )
#   recordPlot()
# })
# 
# Plot2 <- reactive({
#   plot(
#     x=x(), y=y(), main = "iris plot 2", xlab = xl(), ylab = yl(), col = "blue"
#   )
#   recordPlot()
# })
# 
# output$plot <- renderPlot({
#   Plot1()
# })
# 
# output$plot2 <- renderPlot({
#   Plot2()
# })

output$export <- downloadHandler(
  filename =  function() {"Plot_output.pdf"},
  content = function(file) {
    pdf(file, width=12)
    
    par(mfrow=c(1,1))
    df_ts <- serie()
    a <- dt$AMR
    plot(df_ts, main = a)
    
    
    
    
    
    par(mfrow=c(1,1))
    model_summary <- summary(m1())
    plot.new()
    title("Ajuste del Modelo Lineal completo preliminar:")
    text(0.5, 0.5, paste(capture.output(model_summary), collapse="\n"), cex=0.9) # Adjust cex for font size
    
    par(mfrow=c(1,1))
    model_summary <- summary(m2())
    plot.new()
    title("Ajuste del Modelo Lineal simplificado preliminar:")
    text(0.5, 0.5, paste(capture.output(model_summary), collapse="\n"), cex=0.9) # Adjust cex for font size
    
    

    par(mfrow = c(2, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
    plot(m1(), which = 1, ask = FALSE)
    plot(m1(), which = 2, ask = FALSE)
    plot(m1(), which = 3, ask = FALSE)
    plot(m1(), which = 4, ask = FALSE)
    mtext("Validacion del Modelo Lineal completo preliminar:", outer = TRUE, cex = 1.5, line = 1)

    par(mfrow = c(1, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
    acf(resid(m1()),ylim=c(-1,1),lwd=2)
    pacf(resid(m1()),ylim=c(-1,1),lwd=2)
    mtext("Estructura de autocorrelacion de los residuos del Modelo Lineal completo preliminar:", outer = TRUE, cex = 1.5, line = 1)
    
    
        par(mfrow = c(2, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
        plot(m2(),which=1,ask=F)
        plot(m2(),which=2,ask=F)
        plot(m2(),which=3,ask=F)
        plot(m2(),which=4,ask=F)
        mtext("Validacion Modelo Lineal simplificado preliminar:", outer = TRUE, cex = 1.5, line = 1)
        


        par(mfrow = c(1, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
        acf(resid(m2()),ylim=c(-1,1),lwd=2)
        pacf(resid(m2()),ylim=c(-1,1),lwd=2)
        mtext("Estructura de autocorrelacion de los residuos del Modelo Lineal simplificado preliminar:", outer = TRUE, cex = 1.5, line = 1)
        
    
    
    par(mfrow=c(1,1))
    a <- print(m3())
    model_output <- capture.output(print(a))
    plot.new()
    title("Ajuste del Modelo Autoarima:")
    text(0.5, 0.5, paste(model_output, collapse="\n"), cex=0.9) 
    
    
    d <- sqrt(diag(m3()$var.coef))
    c <- m3()$coef
    t_ratios <- c/d
    a <- data.frame(t_ratios)
    a <- t(a)
    colnames(a) <- names(coef(m3()))
    model_output <- capture.output(print(a))
    plot.new()
    title("T-ratios del Modelo Autoarima:")
    text(0.5, 0.5, paste(model_output, collapse="\n"), cex=0.9) 
    
    
    par(mfrow=c(1,1))
    model_summary <- summary(m1_auto())
    plot.new()
    title("Ajuste del Modelo Lineal total con estructura AR(p):")
    text(0.5, 0.5, paste(capture.output(model_summary), collapse="\n"), cex=0.9) # Adjust cex for font size
    
    par(mfrow=c(1,1))
    model_summary <- summary(m2_auto())
    plot.new()
    title("Ajuste del Modelo Lineal simplificado con estructura AR(p):")
    text(0.5, 0.5, paste(capture.output(model_summary), collapse="\n"), cex=0.9) # Adjust cex for font size
    


    
    
    
    
    
    

    par(mfrow = c(2, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
      plot(m1_auto(),which=1,ask=F)
      plot(m1_auto(),which=2,ask=F)
      plot(m1_auto(),which=3,ask=F)
      plot(m1_auto(),which=4,ask=F)
      mtext("Validacion del Modelo Lineal completo:", outer = TRUE, cex = 1.5, line = 1)
      
      
      
      par(mfrow = c(1, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
      acf(resid(m1_auto()),ylim=c(-1,1),lwd=2)
      pacf(resid(m1_auto()),ylim=c(-1,1),lwd=2)
      mtext("Estructura de autocorrelacion de los residuos del Modelo Lineal completo:", outer = TRUE, cex = 1.5, line = 1)
      

      
      par(mfrow = c(2, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
      plot(m2_auto(),which=1,ask=F)
      plot(m2_auto(),which=2,ask=F)
      plot(m2_auto(),which=3,ask=F)
      plot(m2_auto(),which=4,ask=F)
      mtext("Validacion del Modelo Lineal simplificado:", outer = TRUE, cex = 1.5, line = 1)
      

      par(mfrow = c(1, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
      acf(resid(m2_auto()),ylim=c(-1,1),lwd=2)
      pacf(resid(m2_auto()),ylim=c(-1,1),lwd=2)
      mtext("Estructura de autocorrelacion de los residuos del Modelo Lineal simplificado:", outer = TRUE, cex = 1.5, line = 1)
      
    
    
  
    
      par(mfrow=c(1,1))
    a <- print(m5())
    model_output <- capture.output(print(a))
    plot.new()
    title("Ajuste del Modelo MARS:")
    text(0.5, 0.5, paste(model_output, collapse="\n"), cex=0.9) 
    
    
    
    par(mfrow=c(1,1), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
    a <- m5()
    plotmo(a, ask=FALSE)
    mtext("Plotmo:", outer = TRUE, cex = 1.5, line = 0)
    
    
    
    
    
    cons <- data$table_cons[, c("mes", dt$AMC)]
    res <- data$table_res[, c("mes", dt$AMR)]
    
    df <- merge(res, cons, by = "mes")
    
    df <- df[-c(1:5),]
    
    start_date <- as.Date(df$mes[1])
    
    start_year <- as.numeric(format(start_date, "%Y"))
    start_month <- as.numeric(format(start_date, "%m"))
    par(mfrow=c(1,1))
    plot(ts(resid(m5()),start=c(start_year,start_month),freq=12),main="Residuos")
    mtext("Residuos del Modelo MARS:", outer = TRUE, cex = 1.5, line = 0)    
    

    par(mfrow=c(1,1))
    qqnorm(resid(m5()))
    qqline(resid(m5()), col=2, lwd=2)
    mtext("Residuos en papel probabilistico normal:", outer = TRUE, cex = 1.5, line = 0)
    
    
    
    
    
    
    par(mfrow = c(1, 2), mar = c(4, 4, 4, 4), oma = c(0, 0, 5, 0))
    acf(resid(m5()), ylim=c(-1,1), lwd=2, main="Residuos")
    pacf(resid(m5()), ylim=c(-1,1), lwd=2, main="Residuos")
    mtext("Estructura de autocorrelación de los residuos del Modelo MARS:", outer = TRUE, cex = 1.5, line = 1)
    

    
    
    
    
    AMR <- dt$AMR
    cons <- data$table_cons[, c("mes", dt$AMC)]
    res <- data$table_res[, c("mes", dt$AMR)]
    
    df <- merge(res, cons, by = "mes")
    
    df <- df[-c(1:5),]
    
    start_date <- as.Date(df$mes[1])
    
    start_year <- as.numeric(format(start_date, "%Y"))
    start_month <- as.numeric(format(start_date, "%m"))
    
    par(mfrow=c(1,1))
    plot(ts(df[,AMR], start=start_year, freq=12))
    lines(ts(predict(m5()), start=c(start_year, start_month), freq=12), col=2)
    legend("topright", legend=c(AMR,"NL-TSA Model"), col=c(1,2), lty=1)
    mtext("Reconstrucción de la serie mediante el modelo:", outer = TRUE, cex = 1.5, line = 0)
    
    dev.off() 
  } 
)




}