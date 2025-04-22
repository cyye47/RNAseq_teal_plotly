library(teal)
library(ggplot2)
library(plotly)

pca_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("dataset"), 
      "Select TPM Dataset", 
      choices = NULL
      ),
    plotlyOutput(ns("pca_plot"))
  )
}

pca_module_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    observe({
      updateSelectInput(
        session, 
        "dataset", 
        choices = get_datasets_by_type(data, "tpm")
        )
    })

    output$pca_plot <- renderPlotly({
      req(input$dataset)
      df <- data[[input$dataset]]
      df <- df[, 3:ncol(df)] # first two columns are gene_id and gene_name
      validate(need(ncol(df) >= 2, "Not enough samples for PCA"))
      
      df_t <- t(df)
      df_t <- df_t[complete.cases(df_t), ]
      # Remove genes (columns) with zero variance
      df_t <- df_t[, apply(df_t, 2, function(x) var(x, na.rm = TRUE) > 0)]
      
      validate(need(ncol(df_t) >= 2, "Not enough features after removing NAs"))
      
      meta_name <- sub("_tpm$", "_meta", input$dataset)
      validate(need(meta_name %in% names(data), "Metadata not available for selected dataset"))
      meta_df <- data[[meta_name]]
      
      # Perform PCA
      pca <- prcomp(df_t, scale. = TRUE)
      
      to_plot <- data.frame(pca$x)
      to_plot$sample <- rownames(to_plot)
      
      # add sample condition
      to_plot <- merge(to_plot, meta_df, 
                       by.x = "sample", 
                       by.y = "sample", 
                       all.x = TRUE)
      
      gg <- ggplot(to_plot, aes(x = PC1, 
                                y = PC2, 
                                color = condition, 
                                label = sample)) +
        geom_point() +
        geom_text(aes(label = sample), nudge_y = -7, size = 2) +
        xlab("PC1") +
        ylab("PC2") +
        ggtitle(paste("PCA -", input$dataset))
      ggplotly(gg)
    })
  })
}

