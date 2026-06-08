# go_kegg_enrichment.R
# R script to perform GO and KEGG enrichment analysis on licorice DEGs
# by mapping them to Arabidopsis thaliana homologs.

message("Loading libraries...")
library(clusterProfiler)
library(org.At.tair.db)
library(ggplot2)
library(enrichplot)

# Set working directory to project root
if (Sys.info()["sysname"] == "Windows") {
  setwd("\\\\wsl.localhost\\Ubuntu\\home\\shiva\\bioinformatics_plant_projects\\licorice_insect_rnaseq")
}
message("Current directory: ", getwd())

# 1. Load the GWH-to-Arabidopsis gene mapping
message("Loading GWH-to-Arabidopsis mapping...")
mapping_path <- "results/gwh_vs_arabidopsis.tsv"

if (!file.exists(mapping_path)) {
  stop("Mapping file not found! Please run Step 2 first.")
}

mapping <- read.table(mapping_path, sep = "\t", header = FALSE, stringsAsFactors = FALSE)
colnames(mapping) <- c("qseqid", "sseqid", "pident", "length", "mismatch", "gapopen", 
                       "qstart", "qend", "sstart", "send", "evalue", "bitscore")

# Extract clean identifiers:
# - GWH ID: strip mRNA suffix (e.g., GUL01G000002.mRNA1 -> GUL01G000002)
# - Arabidopsis ID: strip isoform suffix (e.g., AT3G27310.1 -> AT3G27310)
mapping$gwh_id <- gsub("\\.mRNA\\d+", "", mapping$qseqid)
mapping$at_id <- gsub("\\.\\d+", "", mapping$sseqid)

# ENFORCE PARAMETERS IN SCRIPT LOGIC: E-value <= 1e-5, Identity >= 30%
message("Applying E-value <= 1e-5 and percent identity >= 30% filters...")
mapping <- mapping[mapping$evalue <= 1e-5 & mapping$pident >= 30.0, ]

# SELECT SINGLE BEST-HIT (highest bitscore) per query gene
message("Selecting single best hit per query gene based on bitscore...")
mapping <- mapping[order(mapping$gwh_id, -mapping$bitscore), ]
mapping <- mapping[!duplicated(mapping$gwh_id), ]

# Take unique mapping pairs
gene_map <- unique(mapping[, c("gwh_id", "at_id")])
message("Total mapped genes: ", nrow(gene_map))

# Write out the mapping table for user convenience
write.csv(gene_map, "results/gwh_to_arabidopsis_mapping.csv", row.names = FALSE)
message("Mapping table saved to results/gwh_to_arabidopsis_mapping.csv")


# 2. Define enrichment analysis function
run_enrichment <- function(sig_deg_path, prefix) {
  if (!file.exists(sig_deg_path)) {
    message("Significant DEG file not found: ", sig_deg_path)
    return(NULL)
  }
  
  degs <- read.csv(sig_deg_path, stringsAsFactors = FALSE)
  if (nrow(degs) == 0) {
    message("No significant DEGs found in: ", sig_deg_path)
    return(NULL)
  }
  
  # Split into Up, Down, and All
  degs_up <- degs$Geneid[degs$log2FoldChange > 0]
  degs_down <- degs$Geneid[degs$log2FoldChange < 0]
  degs_all <- degs$Geneid
  
  deg_lists <- list(
    "up" = degs_up,
    "down" = degs_down,
    "all" = degs_all
  )
  
  for (dir in names(deg_lists)) {
    genes <- deg_lists[[dir]]
    if (length(genes) == 0) next
    
    # Map to Arabidopsis IDs
    at_genes <- unique(gene_map$at_id[gene_map$gwh_id %in% genes])
    
    label <- paste0(prefix, "_", dir)
    message("\n--- Running enrichment for: ", label, " (", length(genes), " GWH genes -> ", length(at_genes), " Arabidopsis genes) ---")
    
    if (length(at_genes) == 0) {
      message("No Arabidopsis homolog mapping found for this set.")
      next
    }
    
    # 2a. GO Enrichment (BP, MF, CC)
    for (ont in c("BP", "MF", "CC")) {
      ego <- tryCatch({
        enrichGO(gene          = at_genes,
                 OrgDb         = org.At.tair.db,
                 keyType       = "TAIR",
                 ont           = ont,
                 pAdjustMethod = "BH",
                 pvalueCutoff  = 0.05,
                 qvalueCutoff  = 0.05)
      }, error = function(e) {
        message("Error in GO enrichment (", ont, ") for ", label, ": ", e$message)
        NULL
      })
      
      if (!is.null(ego) && nrow(as.data.frame(ego)) > 0) {
        write.csv(as.data.frame(ego), file = file.path("results", paste0("go_", ont, "_", label, ".csv")), row.names = FALSE)
        
        p <- dotplot(ego, showCategory = 15) + 
             labs(title = paste("GO", ont, "Enrichment -", prefix, "(", toupper(dir), ")")) +
             theme(plot.title = element_text(face = "bold", size = 12, hjust = 0.5))
        
        ggsave(file.path("results", paste0("go_", ont, "_dotplot_", label, ".png")), plot = p, width = 8, height = 7, dpi = 300)
        message("Saved GO ", ont, " table and dotplot for ", label)
      } else {
        message("No significant GO ", ont, " terms enriched for ", label)
      }
    }
    
    # 2b. KEGG Pathway Enrichment
    # Note: performed using Arabidopsis homolog mapping due to absence of species-specific KEGG annotation for G. uralensis.
    ekegg <- tryCatch({
      enrichKEGG(gene          = at_genes,
                 organism      = "ath",
                 keyType       = "kegg",
                 pAdjustMethod = "BH",
                 pvalueCutoff  = 0.05,
                 qvalueCutoff  = 0.05)
    }, error = function(e) {
      message("Error in KEGG enrichment for ", label, ": ", e$message)
      NULL
    })
    
    if (!is.null(ekegg) && nrow(as.data.frame(ekegg)) > 0) {
      write.csv(as.data.frame(ekegg), file = file.path("results", paste0("kegg_", label, ".csv")), row.names = FALSE)
      
      p <- dotplot(ekegg, showCategory = 15) + 
           labs(title = paste("KEGG Pathway Enrichment -", prefix, "(", toupper(dir), ")")) +
           theme(plot.title = element_text(face = "bold", size = 12, hjust = 0.5))
      
      ggsave(file.path("results", paste0("kegg_dotplot_", label, ".png")), plot = p, width = 8, height = 7, dpi = 300)
      message("Saved KEGG table and dotplot for ", label)
    } else {
      message("No significant KEGG pathways enriched for ", label)
    }
  }
}

# 3. Execute enrichment analysis for the three comparisons
run_enrichment("results/I6H_vs_C0H_sig_DEGs.csv", "I6H_vs_C0H")
run_enrichment("results/I12H_vs_C0H_sig_DEGs.csv", "I12H_vs_C0H")
run_enrichment("results/I24H_vs_C0H_sig_DEGs.csv", "I24H_vs_C0H")

message("\nGO & KEGG enrichment analysis pipeline completed successfully!")
