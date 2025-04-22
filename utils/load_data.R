get_datasets_by_type <- function(data, type = c("tpm", "deseq")) {
  type <- match.arg(type)
  grep(paste0("_", type, "$"), names(data), value = TRUE)
}
