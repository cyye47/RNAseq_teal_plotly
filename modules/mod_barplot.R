library(teal)
library(dplyr)
library(ggplot2)

barplot_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(
        width = 9,
        selectInput(
          ns("dataset"),
          "Select TPM Dataset",
          choices = NULL
        ),
        plotOutput(ns("barplot"))
      ),
      column(
        width = 3,
        textInput(
          ns("gene_filter"),
          "Filter by gene_name:",
          placeholder = "ACTB"
        )
      )
    )
  )
}

barplot_module_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    observe({
      updateSelectInput(
        session,
        "dataset",
        choices = get_datasets_by_type(data, "tpm")
      )
    })
    
    output$barplot <- renderPlot({
      req(input$dataset)
      df <- as.data.frame(data[[input$dataset]])
      
      req(input$gene_filter)
      gene_row <- df[df$gene_name == input$gene_filter, , drop = FALSE]
      validate(need(nrow(gene_row) > 0, "Gene not found."))
      
      # Expression values
      expr_values <- as.numeric(gene_row[1, 3:ncol(gene_row)])
      samples <- colnames(gene_row)[3:ncol(gene_row)]

      # Metadata merge
      meta_name <- sub("_tpm$", "_meta", input$dataset)
      validate(need(meta_name %in% names(data), "Metadata not available"))
      meta_df <- as.data.frame(data[[meta_name]])
      
      plot_df <- data.frame(
        sample = samples,
        expression = expr_values
      )

      plot_df <- merge(plot_df, meta_df, by = "sample", all.x = TRUE)

      # Summary stats for bars
      summary_df <- plot_df |>
        group_by(condition) |>
        summarise(
          mean_expr = mean(expression, na.rm = TRUE),
          sd = sd(expression, na.rm = TRUE),
          n = n(),
          se = sd / sqrt(n)
        )
      
      ggplot() +
        # Bar layer using summary_df
        geom_bar(
          data = summary_df,
          aes(x = condition, y = mean_expr, fill = condition),
          stat = "identity",
          width = 0.5,
          alpha = 0.6,
          show.legend = FALSE
        ) +
        # Error bar layer using summary_df
        geom_errorbar(
          data = summary_df,
          aes(x = condition, ymin = mean_expr - se, ymax = mean_expr + se),
          width = 0.2
        ) +
        # Jitter layer using plot_df
        geom_jitter(
          data = plot_df,
          aes(x = condition, y = expression),
          width = 0.15,
          height = 0,
          alpha = 0.8,
          color = "gray30"
        ) +
        ylab("TPM") +
        xlab("Condition") +
        ggtitle(paste("Expression of", input$gene_filter)) +
        theme_minimal()
    })
  })
}



