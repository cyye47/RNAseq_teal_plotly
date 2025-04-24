library(teal)
library(data.table)

source("utils/load_data.R")
source("modules/mod_volcano.R")
source("modules/mod_pca.R")
source("modules/mod_barplot.R")

app_data <- teal_data(
  comp1_deseq = fread("data/comp1/deseq_res1.csv"),
  comp1_tpm   = fread("data/comp1/tpm1.csv"),
  comp1_meta  = fread("data/comp1/meta1.csv"),
  comp2_deseq = fread("data/comp2/deseq_res2.csv"),
  comp2_tpm   = fread("data/comp2/tpm2.csv"),
  comp2_meta  = fread("data/comp2/meta2.csv")
)

pca_mod <- module(
  label = "PCA",
  ui = function(id) {
    ns <- NS(id)
    pca_module_ui(ns("pca"))
  },
  server = function(id, data) {
    moduleServer(id, function(input, output, session) {
      pca_module_server("pca", data())
    }
    )
  },
  datanames = NULL # ← disables filter panel
)

volcano_mod <- module(
  label = "Volcano",
  ui = function(id) {
    ns <- NS(id)
    volcano_module_ui(ns("volcano"))
  },
  server = function(id, data) {
    moduleServer(id, function(input, output, session) {
      volcano_module_server("volcano", data())
    }
    )
  },
  datanames = NULL
)

barplot_mod <- module(
  label = "Barplot",
  ui = function(id) {
    ns <- NS(id)
    barplot_module_ui(ns("barplot"))
  },
  server = function(id, data) {
    moduleServer(id, function(input, output, session) {
      barplot_module_server("barplot", data())
    }
    )
  },
  datanames = NULL
)

app <- init(
  data = app_data,
  modules = modules(
    pca_mod,
    volcano_mod,
    barplot_mod
  )
)

shinyApp(ui = app$ui, server = app$server)