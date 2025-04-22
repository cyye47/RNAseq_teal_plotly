library(teal)
library(ggplot2)
library(plotly)

volcano_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("dataset"),
      "Select DESeq Dataset",
      choices = NULL
      ),
    plotlyOutput(ns("volcano"))
  )
}

volcano_module_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    observe({
      updateSelectInput(
        session, 
        "dataset", 
        choices = get_datasets_by_type(data, "deseq")
        )
    })
    
    output$volcano <- renderPlotly({
      req(input$dataset)
      df <- data[[input$dataset]]
      gg <- ggplot(df, aes(x = log2FoldChange, 
                           y = -log10(padj),
                           lable = gene_name)
                   ) +
        geom_point(alpha = 0.3) +
        geom_text(
          data = subset(df, abs(log2FoldChange) > 1 & padj < 0.000000005),
          aes(label = gene_name),
          nudge_y = -3,
          size = 2
        ) +
        geom_vline(xintercept = 1, linetype = "dashed", color = "red") +
        geom_vline(xintercept = -1, linetype = "dashed", color = "red") +
        geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "blue") +
        xlab("log2FC") +
        ylab("-log10(Adjusted p value)") +
        ggtitle(paste("Volcano -", input$dataset))
      ggplotly(gg)
    })
  })
}

