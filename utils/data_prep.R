library(airway)
library(DESeq2)
library(recount) # to calculate TPM

setwd("~/Documents/Computation/ShinyConf2025/RNAseq_teal/RNAseq_plotly")

# data preparation starting with count data in airway
data(airway)
out_data <- airway

conditions <- data.frame(out_data$dex)

# DESeq2 analysis
dds <- DESeqDataSet(out_data, design = ~ dex)
dds <- DESeq(dds)
res <- results(dds)
res <- res[order(res$padj),]

# TPM calculation
# add a bp_length column if not already available
mcols(out_data)$bp_length <- 
  abs(mcols(out_data)$gene_seq_start-mcols(out_data)$gene_seq_end)
tpm <- getTPM(out_data)

# add gene symbol
tpm <- merge(
  mcols(out_data)[, c("gene_id", "gene_name")],
  tpm,
  by.x = "gene_id",
  by.y = 0
)

res <- merge(
  mcols(out_data)[, c("gene_id", "gene_name")],
  as.data.frame(res),
  by.x = "gene_id",
  by.y = 0
)

meta <- data.frame(colnames(out_data), out_data$dex)
colnames(meta) <- c("sample", "condition")

write.csv(tpm, file = "tpm.csv", row.names = F)
write.csv(res, file = "deseq_res.csv", row.names = F)
write.csv(meta, file = "meta.csv", row.names = F)
