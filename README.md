# RNAseq_teal_plotly

This script implement teal modules to RNAseq data, showing commonly used PCA, volcano and barplot. For PCA and volcano plot, plotly was used in addition to ggplot2 to allow interaction with data.

Test data is from the airway package. [utils/data_prep.R](https://github.com/cyye47/RNAseq_teal_plotly/blob/main/utils/data_prep.R) is used to pre-process the data from airway and write out csv files in data/

In all modules, datanames = NULL, to remove the default right side filter panel.