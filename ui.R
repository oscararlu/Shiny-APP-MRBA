## ui.R ##
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(plotly)
library(tidyquant)
library(openxlsx)
library(tidyverse)
library(DT)
library(readxl)
library(forecast)
library(dplyr)
library(mgcv)
library(car)
library(urca)
library(earth)
library(shinyWidgets)
library(rmarkdown)
library(grid)
library(gridExtra)

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



dashboardPage(
  skin = "green",
  # md=TRUE,
  dashboardHeader(title = "Shiny App: M.R.B.A."),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inicio", tabName = "tab_inicio", icon = icon("home", lib = "glyphicon")),
      menuItem("Carga de Ficheros", tabName = "tab_uploader", icon = icon("upload")),
      menuItem("Datos Iniciales", tabName = "tab_datos_iniciales", icon = icon("th-large")),
      menuItem("Datos Elaborados", tabName = "tab_datos_elaborados", icon = icon("th")),
      menuItem("Modelización", tabName = "tab_modelos", icon = icon("signal"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .box {
          border-top: 10px !important; /* Remove the top border */
          margin-bottom: 10px; /* Adjust margin for spacing */
        }
        .box-header {
          display: none; /* Remove the header bar */
        }
        .box-body {
          padding: 10px 10px !important; /* Reduce the padding */
        }
        .box.box-solid .box-body {
          padding-top: 0px !important; /* Reduce top padding for solid header boxes */
        }
        .nav-tabs-custom > .tab-content {
          padding-top: 5px !important; /* Reduce top padding for tabBox content */
        }
        .nav-tabs-custom .tab-pane {
          padding-top: 5px !important; /* Reduce top padding inside each tab panel */
        }
        .nav-tabs-custom .box-body {
          padding-top: 5px !important; /* Additional adjustment for box-body within tabBox */
        }
        .multicol {
          display: flex;
          flex-wrap: wrap;
        }
        .multicol .checkbox {
         flex: 1 1 30%;
         margin-bottom: 5px;
        }
        .pretty.p-default { margin-right: 15px; }
        
"
      ))
    ),
    tabItems(
      
      tabItem(
        tabName = "tab_inicio",
        fluidRow(h2("· BIENVENIDO"),
          tabBox(
            title="",
            id="tab_box_inicio",
            width=12,
            tabPanel(title="Inicio",                             
              fluidRow(
              column(12,
                     p("Bienvenido a la plataforma interactiva",em("M.R.B.A."),"(Modelizador de Resistencias Bacterianas ante tratamientos Antibióticos).",
                       style="font-size:16px; text-align: justify"),
                      p("En esta podrás elaborar un estudio estadistico sobre el comportamiento
                       de las resistencias bacterianas a través del ajuste de modelos.", 
                       style="font-size:16px; text-align: justify"),
                     p("Es una aplicacion flexible y adaptable a tus datos a demás de permitir
                       un sinfin de opciones en el ajuste de modelos.", 
                       style="font-size:16px; text-align: justify"),
                     p("Para conocer más sobre el uso de esta dirígete a la pestaña",em("Guía de uso."), 
                       style="font-size:16px; text-align: justify")
                     ))),
            tabPanel(title="Guía de uso",                             
                     fluidRow(
                       column(12,
                              p("Actualmente te encuentras en la pestaña de inicio.", 
                                style="font-size:16px; text-align: justify"),
                              p("Antes de comenzar tu estudio y uso de la aplicación primero debes
                                conocer varias especificaciones a tener en cuenta en cada una de las pestañas", 
                                style="font-size:16px; text-align: justify"),
                              p("A lo largo de todas las pestañas en contraras burbujas de informacion que te explicaran
                                que hacer para continuar el estudio o lo que ves", 
                                style="font-size:16px; text-align: justify"),
                              p("En la primera pestaña",em("Carga de ficheros"),"Es necesario que los datos subidos
                                esten en formato Excel. El documento debe contener las siguientes hojas: Ocupacion, ConsumosDDDpor1000Estancias,
                                ResultadosSensibles, ResultadosResistentes,DiccionarioConsumos,DiccionarioResistencias.
                                Esto es necesario ya que todo el servidor de la aplicacion utiliza la informacion presente en estas.
                                Sin embargo, por la construccion que hemos hecho del aplicativo este permite cualquier columna dentro de estos, es decir
                                puedes introducir cualquier antibiotico y medicamento siempre y cuando esten bien codificados en el diccionario, la plicacion.", 
                                style="font-size:16px; text-align: justify"),
                              p("En la segunda y terceras pestañas",em("Datos Iniciales y Datos Transformados"),"Puedes estudiar de manera descriptiva
                                los datos introducidos con plots interactivos.", 
                                style="font-size:16px; text-align: justify"),
                              p("En la ultima pestaña, la de modelización, en caso de querer cargar los modelos en CSV estos deben estar por columnas. Es
                                decir, cada columna será un modelo, donde las variables en la primera poscion (fila), serán las variables respuesta, el resto
                                serán consideradas como explicativas.
                                A lo largo de esta pestaña hay un sinfin de opcionalidades, estate atento a las burvbujas para poder exprimir al
                                maximo la app", 
                                style="font-size:16px; text-align: justify"),
                              p("Encontraras en el respositorio de la app una guia de ejemplo que expone de forma hilada
                                todas las burbujas y todo lo que hace la app.", 
                                style="font-size:16px; text-align: justify"),
                       ))),
            tabPanel(title="Autor",                             
                     fluidRow(
                       column(12,
                              h3(strong("Oscar Arroyo Luque")),
                              p("Soy oscar Arroyo Luque, estudiante que cierra su paso por el grado
                                de Estadistica con este proyecto.", 
                                style="font-size:16px; text-align: justify"),
                              p("Mi objetivo personal con la elaboracion de un trabajo final de grado
                                siempre ha sido aportar un proyecto útil, con valor ya sea para las empresas
                                mundo academico o las personas.", 
                                style="font-size:16px; text-align: justify"),
                              p("EN la elaboracion de este aplicativo me doy cuenta del gran abanico de 
                                posibilidades u oportunidades que la estadistica me brinda, sintiendo que mediante
                                la aplicacion de mis estudios soy capaz de aportar valor", 
                                style="font-size:16px; text-align: justify"),
                              p("La estadistica me permite solucionar cuestuones y a partir de datos
                                obtener información que sin un analisis para todos seria desconocida, lo cual me enamora
                                mas de mis estudios.", 
                                style="font-size:16px; text-align: justify"),
                              p("Me siento totalmente agradecido de poder aportar mi pequeña parte desde el mundo de la estadistica.", 
                                style="font-size:16px; text-align: justify"),
                       )))
          )
        )
      ),
      #### SUBIDA DE FICHEROS ######      
      
      tabItem(
        tabName = "tab_uploader",
        fluidRow(
          column(width=4,
                 tabBox(
                   title = "Uploader",
                   id = "tab_box_uploader",
                   width = 12,
                   tabPanel(
                     title = "Excel",
                     dropdownButton(
                       p("A continuación puedes subir el fichero con la estructura y formatos
                         indicados en la guía de uso.",br(), "Después, de las tablas cargadas, puedes
                         seleccionar cuál quieres visualizar.",br(),"Para finalizar, si los datos son los deseados, pulsa el botón
                          ",em("Usar datos."),br(),"Si deseas eliminar los datos subidos al sistema,
                         pulsa el botón",em("Borrar datos."),
                         style="text-align: left"),
                       circle = TRUE,
                       status = "success",
                       size = "xs",
                       icon  = icon("circle-info"),
                       label = NULL,
                       tooltip = FALSE,
                       right = F,
                       up = FALSE,
                       width = NULL,
                       margin = "10px",
                       inline = TRUE,
                       inputId = NULL
                     ),
                     hr(),
                     fileInput(
                       inputId = "file_input_excel",
                       label = "Suba archivo:",
                       accept = c('.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                     ),
                     hr(),
                     selectInput("select_input_table_visual", "Seleccione tabla a visualizar:",
                                 choices = c("Datos Ocupacion"="tabla_ocupacion","Datos Consumos"="tabla_consumos","Datos Resistentes"="tabla_resistentes","Datos Sensibles"="tabla_sensibles", "Diccionario Consumos"="tabla_dicc_cons","Diccionario Resistencias" = "tabla_dicc_res"))
                     ,hr(),
                     actionButton(inputId = 'action_button_excel_ready', label = 'Usar datos', icon = icon('thumbs-up', lib = 'glyphicon')),
                     uiOutput('check_excel'),
                     hr(),
                     actionButton(inputId = "action_button_excel_not_ready", label = "Borrar datos", icon = icon('thumbs-down', lib = 'glyphicon'))
                   )
                 )),
          column(width=8,DT::dataTableOutput('tabla_output_visual'))
        )
      )
      ,
      
      ### PLOTS NORMALES ####
      tabItem(
        tabName = "tab_datos_iniciales",
        fluidRow(
          column(width=1,dropdownButton(
            p("A continuación se muestran varios descriptivos y gráficos.",br(),
              "Puedes seleccionar qué observaciones ver según bacteria y antibiótico.",br()
              ,"Si no hay observaciones para la combinación seleccionada, estas no 
              se mostrarán en la tabla de descriptivos* y se indicará con un mensaje en los gráficos.",
              style="text-align: left"),
            circle = TRUE,
            status = "success",
            size = "xs",
            icon  = icon("circle-info"),
            label = NULL,
            tooltip = FALSE,
            right = F,
            up = FALSE,
            width = NULL,
            margin = "10px",
            inline = TRUE,
            inputId = NULL
          )),
          column(width=5,box(width = 12,
              uiOutput("output_select_input_micro_data_inicial")
          )),

          column(width=5,box(width=12, 
              uiOutput("output_select_input_med_data_inicial")
          )),
          column(width=12,dropdownButton(
            p("En la próxima tabla de descriptivos encontrarás las siguientes variables:",br(),
              "1: Cantidad de bacterias resistentes al antibiótico.*",br(),
              "2: Cantidad de bacterias sensibles al antibiótico.*",br(),
              "3: Cantidad de bacterias en la prueba con ese antibiótico.*",br(),
              "4: Consumos DDD por 1000 estancias del antibiótico.",br(),
              "5: Ocupación del hospital.",br(),
              style="text-align: left"),
            circle = TRUE,
            status = "success",
            size = "xs",
            icon  = icon("circle-info"),
            label = NULL,
            tooltip = FALSE,
            right = F,
            up = FALSE,
            width = NULL,
            margin = "10px",
            inline = TRUE,
            inputId = NULL
          ),),
          tabBox(title="Descriptivos",id="tab_box_data_ini_sum",width=12,
                 tabPanel("Summary",
                          
                          
                          
                          verbatimTextOutput("summary_data_ini"))),
          
          column(width=12,dropdownButton(
            p("Puedes interaccionar con los gráficos a continuación.",
              style="text-align: left"),
            circle = TRUE,
            status = "success",
            size = "xs",
            icon  = icon("circle-info"),
            label = NULL,
            tooltip = FALSE,
            right = F,
            up = FALSE,
            width = NULL,
            margin = "10px",
            inline = TRUE,
            inputId = NULL
          )),
          
          tabBox(title="Gráficos", id="tab_box_data_inicial_1",width = 12,
                 tabPanel("Gráfico de barras apiladas: resistentes vs sensibles",plotlyOutput("plot_barras_apiladas")),
                 tabPanel("Gráfico de serie de tiempo: resistentes, sensibles y total",plotlyOutput("plot_line_totals"))
          )
          ,
          tabBox(title="Gráficos", id="tab_box_plots_inicial_2",width = 12,
                 tabPanel("Gráfico de serie de tiempo: consumos de antibiótico",plotlyOutput("plot_serie_consumos")),
                 tabPanel("Gráfico de serie de tiempo: hospitalizaciones",plotlyOutput("plot_hospitalizaciones"))
          )
          
          
          
        )
        
        
      )
      ,
      tabItem(
        tabName = "tab_datos_elaborados",
        fluidRow(
          
          column(width=1,dropdownButton(
            p("A continuación se muestran varios gráficos de variables elaboradas.",br(),
              "Estos se crearán a partir de la selección de bacteria y antibiótico que tienes disponible.",br(),
              "Primero encontramos el porcentaje de bacterias resistentes de la prueba respecto el total.",br(),
              "Segundo encontramos la tasa de infección por dosis.",
              style="text-align: left"),
            circle = TRUE,
            status = "success",
            size = "xs",
            icon  = icon("circle-info"),
            label = NULL,
            tooltip = FALSE,
            right = F,
            up = FALSE,
            width = NULL,
            margin = "10px",
            inline = TRUE,
            inputId = NULL
          )),
          column(width=5,box(width = 12,
                             uiOutput("output_select_input_micro_data_elaborada")
          )),
          
          column(width=5,box(width=12, 
                             uiOutput("output_select_input_med_data_elaborada")
          )),
          
          column(width=12,dropdownButton(
            p("Puedes interaccionar con los gráficos a continuación.",
              style="text-align: left"),
            circle = TRUE,
            status = "success",
            size = "xs",
            icon  = icon("circle-info"),
            label = NULL,
            tooltip = FALSE,
            right = F,
            up = FALSE,
            width = NULL,
            margin = "10px",
            inline = TRUE,
            inputId = NULL
          )),
          

          tabBox(title="Gráficos", id="tab_box_plots_elaborados",width = 12,
                 tabPanel("Gráfico de serie de tiempo: %Resistencias",plotlyOutput("plot_porcentaje_resistencias")),
                 tabPanel("Gráfico de serie de tiempo: TDI",plotlyOutput("plot_TDI"))
          )
          
          
          
        )
        
        
      ),
      tabItem(
        tabName="tab_modelos",
        fluidRow(
          h2(" · MODELIZACIÓN"),
          h3(" · Selector de variables"),
        column(width=12,dropdownButton(
          p("Primero selecciona las variables de interés para tu modelo.",br(),"Ten en cuenta que la variable
            respuesta será la utilizada a lo largo de toda la modelización. Después iremos trabajando con
            los retardos deseados de cada variable para la parte explicativa",
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
        
        tabBox(width=12,id="tab_box_selector_modelo",
               tabPanel(title="Selector de variables manual",
                        fluidRow(
                          column(width=12,dropdownButton(
                          p("A partir de las columnas presentes en las tablas de consumos y resistencias,
                            puedes seleccionar tus variables de interés para modelizar.",br(),
                            "Una vez seleccionadas pulsa el botón", em("Usar modelo."),
                            style="text-align: left"),
                          circle = TRUE,
                          status = "success",
                          size = "xs",
                          icon  = icon("circle-info"),
                          label = NULL,
                          tooltip = FALSE,
                          right = F,
                          up = FALSE,
                          width = NULL,
                          margin = "10px",
                          inline = TRUE,
                          inputId = NULL
                        )),
                          column(width=6,uiOutput("output_select_input_modelo_2"))
                        ,
                        column(width=6,actionButton(inputId = 'action_button_models_2_ready', label = 'Usar modelo', icon = icon('thumbs-up', lib = 'glyphicon')),
                               uiOutput('check_models_2')),
                        hr(),
                        column(width=12,uiOutput("check_box_output_modelos")),
                        hr(),
                        box(width=12,DT::dataTableOutput('tabla_prueba_2')))
               ),
               tabPanel(title="Selector a partir de fichero",fluidRow(
                 column(width=12,dropdownButton(
                 p("En caso de querer usar modelos ya predefinidos puedes usar este apartado.",br(),
                   "Sube un archivo con la estructura y formatos indicados en la guia de uso, el 
                   sistema se alimentará de este y te mostrará los modelos disponibles.",br(),
                   "Una vez seleccionado el modelo deseado pulsa el botón",em("Usar modelo."),
                   style="text-align: left"),
                 circle = TRUE,
                 status = "success",
                 size = "xs",
                 icon  = icon("circle-info"),
                 label = NULL,
                 tooltip = FALSE,
                 right = F,
                 up = FALSE,
                 width = NULL,
                 margin = "10px",
                 inline = TRUE,
                 inputId = NULL
               )),
               column(width=4,
                                     fileInput(
                                     inputId = "file_input_models",
                                      label = "Suba archivo:",
                                      accept = '.csv'
                                              ),
                                      uiOutput("output_select_input_modelo_1"),
                                                        # hr(),
                                      actionButton(inputId = 'action_button_models_1_ready', label = 'Usar modelo', icon = icon('thumbs-up', lib = 'glyphicon')),

                                uiOutput('check_models_1')
                           ),
                          column(width=8,
                        DT::dataTableOutput('tabla_prueba_1'))
                       ))),

          h3(" · Serie temporal"),
        column(width=12,dropdownButton(
          p("Se muestra el gráfico de serie temporal de las variables seleccionadas.",
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
          box(width=12, plotOutput("plot_ts")),
        h3(" · Exploración preliminar de modelos"),
        column(width=12,dropdownButton(
          p("A continuación selecciona la cantidad de retardos AMR y AMC a ajustar en modelos lineales.",br(),
            "Ten en cuenta que los retardos seleccionados de las variables AMC serán los utilizados en el resto del estudio.",br(),
            "Puedes indicar la cantidad de retardos a calcular, o bien hacer una 
            selección específica de los deseados.",
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
          tabBox(title="Generador de modelos a partir de retardos", width=12, id="tab_box_seleccion_retardos",
                 tabPanel("Selector de retardos a partir de cifras",
                          fluidRow(        
                            column(width=12,dropdownButton(
                            p("Indica el número de retardos a calcular para cada variable y ajusta los modelos pulsando",em("Ajustar modelo."),br(),
                              "Tienes la opción de quitar y recuperar el intercept del modelo pulsando el botón",em("intercept."),
                              style="text-align: left"),
                            circle = TRUE,
                            status = "success",
                            size = "xs",
                            icon  = icon("circle-info"),
                            label = NULL,
                            tooltip = FALSE,
                            right = F,
                            up = FALSE,
                            width = NULL,
                            margin = "10px",
                            inline = TRUE,
                            inputId = NULL
                          )),
                            column(width=5,numericInput(inputId="numeric_input_AMR",label="Número de retardos para la variable respuesta / AMR:", value=1, min=0,max=10)),
                            column(width=5,numericInput(inputId="numeric_input_AMC", label="Número de retardos para las variables explicativas / AMC:", value=5, min=0,max=10)),
                            column(width=2, 
                                   
                                   actionButton(inputId = 'action_button_intercept_no_1', label = 'Intercept'),
                                   hr(),
                                   actionButton(inputId="usar_retardos_1",label = 'Ajustar modelo')
                              )
                          )),
                 tabPanel("Selector de retardos manual",fluidRow(column(width=10,column(width=12,dropdownButton(
                   p("Selecciona los retardos específicos a calcular.",br(),
                     "Pulsa el botón",em("Ajustar modelo"), "cuando tengas la selección deseada.",br(),
                     "También tienes la opcion de eliminar y recuperar el intercept del modelo pulsado el botón",em("intercept."),
                     style="text-align: left"),
                   circle = TRUE,
                   status = "success",
                   size = "xs",
                   icon  = icon("circle-info"),
                   label = NULL,
                   tooltip = FALSE,
                   right = F,
                   up = FALSE,
                   width = NULL,
                   margin = "10px",
                   inline = TRUE,
                   inputId = NULL
                 )),
                 uiOutput("output_checkbox_retardos")),column(width=2,actionButton(inputId = 'action_button_intercept_no_2', label = 'Intercept'),hr(),actionButton(inputId="usar_retardos_2",label = 'Ajustar modelo'))))
                 ),
        column(width=12,dropdownButton(
          p("Se ajustan modelos lineales a partir de los retardos seleccionados.",br(),
            "Primero se muestra el modelo completo y segundo se muestra un modelo simplificado.",br(),
            "El modelo simplificado esta construido mediante el método stepwise y puedes escoger el criterio de selección
            que este usará",
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
          tabBox(title="Ajustes de modelos preliminares",width=12, id="tab_box_summarys",
            tabPanel("Ajuste del Modelo Lineal completo preliminar",verbatimTextOutput("summary_m1")),
            tabPanel("Ajuste del Modelo Lineal simplificado preliminar",selectInput(inputId="select_input_AIC_1",label="Criterio de selección de modelo:",choices=c("AIC"=2,"BIC"=0), selected = "AIC"),verbatimTextOutput("summary_m2"))
          ),
        h3(" · Validación de los modelos preliminares"),
          tabBox(title="Gráficos de validación",width=12,id="tab_box_plots_modelos",
                 tabPanel("Residuos modelo lineal completo",plotOutput("plot_m1")),
                 tabPanel("ACF & PACF", plotOutput("plot_acf_m1")),
                 tabPanel("Residuos modelo lineal simplificado",plotOutput("plot_m2")),
                 tabPanel("ACF & PACF", plotOutput("plot_acf_m2"))
          ),
        h3(" · Selección de variables explicativas / AMC"),
        column(width=12,dropdownButton(
          p("A partir de los modelos previamente ajustados, selecciona
            que retardos (de las variables AMC) quieres usar.",br(),
            "Puedes seleccionar los del modelo completo o los resultantes del método stepwise.",br(),
            "Ten en cuenta que estos retardos serán los introducidos en los modelos ARMAX y MARS.",
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
        
        box(width=12, selectInput(inputId="select_input_modelo_usar_ARMAX",label="Variables AMC del modelo:",choices=c("Completo"="m1","Simplificado"="m2"), selected = "Completo")),
        
        h3(" · Modelo ARMAX"),
        column(width=12,dropdownButton(
          p("A continuación ajustamos un modelo ARMAX.",
            "Este se construye a partir de la función",em("auto.arima()."),
            "Por lo tanto, puedes indicar al procedimiento los valores máximos de cada parámetro.",br(),
            "Después, se muestran el modelo ajustado y los t-ratios.",br(),
            "Por último, se ajustan modelos lineales a partir de las variables presentes en el modelo ARMAX.",
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
        box(width=12,column(width=4,numericInput(inputId="numeric_input_p",label="Máximo valor de p", value=7, min=0,max=7),numericInput(inputId="numeric_input_P",label="Máximo valor de P", value=0, min=0,max=0)),
                      column(width=4,numericInput(inputId="numeric_input_q",label="Máximo valor de q", value=0, min=0,max=7),numericInput(inputId="numeric_input_Q",label="Máximo valor de Q", value=0, min=0,max=7)),
                      column(width=4,numericInput(inputId="numeric_input_d",label="Máximo valor de d", value=0, min=0,max=1),numericInput(inputId="numeric_input_D",label="Máximo valor de D", value=0, min=0,max=1)),
            verbatimTextOutput("autoarima_m3"),verbatimTextOutput("t_ratios")
            ),

          tabBox(title="Ajuste de los Modelos Lineales",width=12, id="tab_box_summarys_auto",
                 tabPanel("Ajuste del Modelo Lineal completo",verbatimTextOutput("summary_m1_auto")),
                 tabPanel("Ajuste del Modelo Lineal simplificado",selectInput(inputId="select_input_AIC_2",label="Escoja AIC/BIC",choices=c("AIC"=2,"BIC"=0), selected = "AIC"),verbatimTextOutput("summary_m2_auto"))
          ),
          tabBox(title="Gráficos de validación",width=12,id="tab_box_plots_modelos_arima",
                 tabPanel("Residuos modelo lineal completo",plotOutput("plot_m1_arima")),
                 tabPanel("ACF & PACF", plotOutput("plot_acf_m1_arima")),
                 tabPanel("Residuos modelo lineal simplificado",plotOutput("plot_m2_arima")),
                 tabPanel("ACF & PACF", plotOutput("plot_acf_m2_arima"))
          ),
        h3(" · Ajuste del Modelo MARS"),
        column(width=12,dropdownButton(
          p("A partir de las variables explicativas y los retardos resultantes
            del procedimiento anterior, ajustamos el modelo", em("MARS."),
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
          box(width=12,verbatimTextOutput("summary_mars")),
        column(width=12,dropdownButton(
          p("Se muestran varios gráficos de utilidad para validar e interpretar el 
            modelo",em("MARS"),
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
          tabBox(title="Gráficos",width=12,id="tab_box_plots_modelos_mars",
                 tabPanel("Respuesta sobre las predictoras",plotOutput("plotmo_mars")),
                 tabPanel("Residuos",plotOutput("plot_res_mars")),
                 tabPanel("QQ - Plot", plotOutput("plot_qq_mars")),
                 tabPanel("ACF & PACF", plotOutput("plot_acf_mars")),
                 tabPanel("Recreación de la serie",plotOutput("plot_final_mars"))
                 
          ),
        column(width=12,dropdownButton(
          p("Pulsando el siguiente botón puedes descargar todos los outputs en formato PDF.",
            style="text-align: left"),
          circle = TRUE,
          status = "success",
          size = "xs",
          icon  = icon("circle-info"),
          label = NULL,
          tooltip = FALSE,
          right = F,
          up = FALSE,
          width = NULL,
          margin = "10px",
          inline = TRUE,
          inputId = NULL
        )),
        column(width=12, downloadButton("export", "Download Outputs"))
          
          # ,
          # box(width=12,)

        )
        
      )
      
      
      
      
      
    )
  )
  ,
  dashboardControlbar(collapsed = TRUE, skinSelector())
)
