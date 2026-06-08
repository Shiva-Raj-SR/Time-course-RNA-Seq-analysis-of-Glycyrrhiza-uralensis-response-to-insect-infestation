# deseq2_analysis.R
# R script to run DESeq2 differential expression analysis on 12 licorice samples
# comparing I6H, I12H, and I24H to C0H.

# Load libraries
message("Loading required libraries...")
library(DESeq2)
library(ggplot2)
library(ggrepel)
library(pheatmap)
library(RColorBrewer)

# Set working directory to project root
if (Sys.info()["sysname"] == "Windows") {
  setwd("\\\\wsl.localhost\\Ubuntu\\home\\shiva\\bioinformatics_plant_projects\\licorice_insect_rnaseq")
}
message("Current directory: ", getwd())


# Create results directory if it doesn't exist
dir.create("results", showWarnings = FALSE)

# 1. Load sample metadata
message("Loading metadata...")
metadata <- read.csv("metadata/sample_info.csv", stringsAsFactors = FALSE)
print(metadata)

# Ensure condition is a factor with reference level C0H
metadata$condition <- factor(metadata$condition, levels = c("C0H", "I6H", "I12H", "I24H"))
rownames(metadata) <- metadata$sample

# 2. Load count files and build count matrix
message("Building count matrix...")
count_list <- list()

for (i in 1:nrow(metadata)) {
  sample_name <- metadata$sample[i]
  file_path <- file.path("counts", paste0(sample_name, "_counts.txt"))
  
  if (!file.exists(file_path)) {
    stop(paste("Count file not found:", file_path))
  }
  
  # Read count file, skipping the program comment header line
  df <- read.table(file_path, header = TRUE, sep = "\t", skip = 1, stringsAsFactors = FALSE)
  
  # Column 1 is Geneid, Column 7 contains the count values
  counts <- df[, c(1, 7)]
  colnames(counts) <- c("Geneid", sample_name)
  
  count_list[[sample_name]] <- counts
}

# Merge all sample counts by Geneid
count_matrix <- Reduce(function(x, y) merge(x, y, by = "Geneid"), count_list)
rownames(count_matrix) <- count_matrix$Geneid
count_matrix$Geneid <- NULL
count_matrix <- as.matrix(count_matrix)

message("Count matrix dimensions: ", paste(dim(count_matrix), collapse = "x"))
print(head(count_matrix))

# 3. Create DESeqDataSet and pre-filter low counts
message("Initializing DESeq2 object...")
dds <- DESeqDataSetFromMatrix(countData = count_matrix,
                              colData = metadata,
                              design = ~ condition)

# Filter: keep genes with at least 10 reads in total across all samples
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep, ]
message("Number of genes after filtering low counts: ", nrow(dds))

# 4. Run DESeq2 Analysis
message("Running DESeq2 pipeline...")
dds <- DESeq(dds)

# 5. Extract results for pairwise comparisons
message("Extracting pairwise comparisons...")
res_6h <- results(dds, contrast = c("condition", "I6H", "C0H"))
res_12h <- results(dds, contrast = c("condition", "I12H", "C0H"))
res_24h <- results(dds, contrast = c("condition", "I24H", "C0H"))

# Function to save results as CSV files
save_results <- function(res, prefix) {
  df <- as.data.frame(res)
  df$Geneid <- rownames(df)
  # Reorder columns to put Geneid first
  df <- df[, c("Geneid", setdiff(colnames(df), "Geneid"))]
  
  # Save full results table
  write.csv(df, file = file.path("results", paste0(prefix, "_all.csv")), row.names = FALSE)
  
  # Save significant DEGs (adjusted p-value < 0.05 and |log2FC| > 1)
  sig <- df[!is.na(df$padj) & df$padj < 0.05 & abs(df$log2FoldChange) > 1, ]
  write.csv(sig, file = file.path("results", paste0(prefix, "_sig_DEGs.csv")), row.names = FALSE)
  
  message(prefix, " - Total Genes: ", nrow(df), " | Significant DEGs: ", nrow(sig), 
          " (Up: ", sum(sig$log2FoldChange > 0), ", Down: ", sum(sig$log2FoldChange < 0), ")")
  return(df)
}

df_6h <- save_results(res_6h, "I6H_vs_C0H")
df_12h <- save_results(res_12h, "I12H_vs_C0H")
df_24h <- save_results(res_24h, "I24H_vs_C0H")

# 6. Visualizations
message("Generating visualization plots...")

# 6a. VST transformation for downstream visualization
vsd <- vst(dds, blind = FALSE)

# 6b. PCA Plot
pca_data <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
percentVar <- round(100 * attr(pca_data, "percentVar"))

pca_plot <- ggplot(pca_data, aes(PC1, PC2, color = condition)) +
  geom_point(size = 4, alpha = 0.8) +
  theme_minimal() +
  labs(title = "PCA Plot of Licorice RNA-Seq Samples",
       x = paste0("PC1: ", percentVar[1], "% variance"),
       y = paste0("PC2: ", percentVar[2], "% variance")) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
        axis.title = element_text(size = 12),
        legend.title = element_text(size = 12))

ggsave("results/pca_plot.png", plot = pca_plot, width = 7, height = 6, dpi = 300)
message("PCA plot saved to results/pca_plot.png")

# 6c. Sample Distance Heatmap
sampleDists <- dist(t(assay(vsd)))
sampleDistMatrix <- as.matrix(sampleDists)
colnames(sampleDistMatrix) <- NULL

pheatmap(sampleDistMatrix,
         clustering_distance_rows = sampleDists,
         clustering_distance_cols = sampleDists,
         col = colorRampPalette(rev(brewer.pal(9, "Blues")))(255),
         filename = "results/sample_distance_heatmap.png",
         width = 7, height = 6)
message("Sample distance heatmap saved to results/sample_distance_heatmap.png")

# 6d. Custom Volcano Plot function
plot_volcano <- function(res_df, title, filename) {
  # Label signficance categories
  res_df$sig <- "Not Sig"
  res_df$sig[res_df$padj < 0.05 & res_df$log2FoldChange > 1] <- "Up"
  res_df$sig[res_df$padj < 0.05 & res_df$log2FoldChange < -1] <- "Down"
  res_df$sig <- factor(res_df$sig, levels = c("Down", "Not Sig", "Up"))
  
  # Select top 10 genes to label based on significance
  top_genes <- head(res_df[order(res_df$padj, na.last = TRUE), ], 10)
  
  volc <- ggplot(res_df, aes(x = log2FoldChange, y = -log10(padj), color = sig)) +
    geom_point(alpha = 0.6, size = 1.5) +
    scale_color_manual(values = c("blue" = "#3182bd", "Not Sig" = "#bdbdbd", "Up" = "#de2d26")) +
    geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "black", alpha = 0.5) +
    geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "black", alpha = 0.5) +
    geom_text_repel(data = top_genes, aes(label = Geneid), size = 3, color = "black", 
                    max.overlaps = 15, fontface = "italic") +
    theme_minimal() +
    labs(title = title, x = "log2(Fold Change)", y = "-log10(adjusted p-value)", color = "Expression") +
    theme(legend.position = "right", 
          plot.title = element_text(hjust = 0.5, face = "bold", size = 12),
          axis.title = element_text(size = 11))
  
  ggsave(filename, plot = volc, width = 7, height = 6, dpi = 300)
}

plot_volcano(df_6h, "Insect Infestation 6H vs Control (C0H)", "results/volcano_I6H_vs_C0H.png")
plot_volcano(df_12h, "Insect Infestation 12H vs Control (C0H)", "results/volcano_I12H_vs_C0H.png")
plot_volcano(df_24h, "Insect Infestation 24H vs Control (C0H)", "results/volcano_I24H_vs_C0H.png")
message("Volcano plots saved successfully.")

# 6e. Heatmap of Top DEGs
# Union of top 20 genes (by padj) from each comparison to visualize dynamic changes
top_6h <- head(df_6h$Geneid[order(df_6h$padj, na.last = TRUE)], 20)
top_12h <- head(df_12h$Geneid[order(df_12h$padj, na.last = TRUE)], 20)
top_24h <- head(df_24h$Geneid[order(df_24h$padj, na.last = TRUE)], 20)
top_degs <- unique(c(top_6h, top_12h, top_24h))

vst_matrix <- assay(vsd)[top_degs, ]

pheatmap(vst_matrix,
         scale = "row",
         annotation_col = metadata[, "condition", drop = FALSE],
         show_rownames = TRUE,
         show_colnames = TRUE,
         filename = "results/deg_heatmap.png",
         width = 8, height = 9,
         main = "Top Differentially Expressed Genes (Row Z-score)")
message("Heatmap of top DEGs saved to results/deg_heatmap.png")

message("DESeq2 preprocessing pipeline completed successfully!")
