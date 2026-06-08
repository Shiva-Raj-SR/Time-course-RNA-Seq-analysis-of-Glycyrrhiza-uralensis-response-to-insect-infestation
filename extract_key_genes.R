# extract_key_genes.R
# R script to extract and annotate key defense-related genes (TFs, phytohormone pathway,
# secondary metabolism, etc.) from licorice DEG lists.

message("Loading libraries...")
library(org.At.tair.db)

# Set working directory to project root
if (Sys.info()["sysname"] == "Windows") {
  setwd("\\\\wsl.localhost\\Ubuntu\\home\\shiva\\bioinformatics_plant_projects\\licorice_insect_rnaseq")
}
message("Current directory: ", getwd())

# 1. Load the GWH-to-Arabidopsis gene mapping
message("Loading mapping table...")
gene_map <- read.csv("results/gwh_to_arabidopsis_mapping.csv", stringsAsFactors = FALSE)

# 2. Function to annotate and filter key defense genes
extract_key_genes <- function(deg_path, prefix) {
  if (!file.exists(deg_path)) {
    message("File not found: ", deg_path)
    return(NULL)
  }
  
  degs <- read.csv(deg_path, stringsAsFactors = FALSE)
  if (nrow(degs) == 0) {
    message("No DEGs found in: ", deg_path)
    return(NULL)
  }
  
  # Merge with Arabidopsis mapping
  merged <- merge(degs, gene_map, by.x = "Geneid", by.y = "gwh_id", all.x = TRUE)
  # Remove DEGs with no Arabidopsis homolog
  merged <- merged[!is.na(merged$at_id), ]
  
  if (nrow(merged) == 0) {
    message("No DEGs mapped to Arabidopsis for ", prefix)
    return(NULL)
  }
  
  # Fetch Symbol and Gene Name from org.At.tair.db
  message("Retrieving symbols and descriptions for ", prefix, "...")
  tair_ids <- unique(merged$at_id)
  
  annotations <- tryCatch({
    select(org.At.tair.db,
           keys   = tair_ids,
           columns = c("SYMBOL", "GENENAME"),
           keytype = "TAIR")
  }, error = function(e) {
    message("Error retrieving annotations: ", e$message)
    NULL
  })
  
  if (is.null(annotations)) return(NULL)
  
  # Merge annotations back
  annotated_degs <- merge(merged, annotations, by.x = "at_id", by.y = "TAIR", all.x = TRUE)
  
  # Identify Key Biological Groups:
  # Initialize group column
  annotated_degs$functional_group <- "Other DEG"
  
  # Check symbols and gene names (case-insensitive)
  symbols <- tolower(annotated_degs$SYMBOL)
  descriptions <- tolower(annotated_degs$GENENAME)
  
  # 2a. Transcription Factors (WRKY, MYB, bHLH, ERF, NAC, bZIP)
  is_wrky <- grepl("wrky", symbols) | grepl("wrky", descriptions)
  is_myb  <- grepl("\\bmyb\\b", symbols) | grepl("myb domain", descriptions) | grepl("myb-domain", descriptions)
  is_bhlh <- grepl("bhlh", symbols) | grepl("basic helix-loop-helix", descriptions)
  is_erf  <- grepl("erf\\d+", symbols) | grepl("ap2", symbols) | grepl("ethylene-responsive factor", descriptions) | grepl("ethylene responsive factor", descriptions)
  is_nac  <- grepl("nac\\d+", symbols) | grepl("\\bnac\\b", symbols) | grepl("nac domain", descriptions)
  is_bzip <- grepl("bzip", symbols) | grepl("basic leucine zipper", descriptions)
  
  annotated_degs$functional_group[is_wrky] <- "TF: WRKY"
  annotated_degs$functional_group[is_myb]  <- "TF: MYB"
  annotated_degs$functional_group[is_bhlh] <- "TF: bHLH"
  annotated_degs$functional_group[is_erf]  <- "TF: AP2/ERF"
  annotated_degs$functional_group[is_nac]  <- "TF: NAC"
  annotated_degs$functional_group[is_bzip] <- "TF: bZIP"
  
  # 2b. Secondary Metabolism / Phenylpropanoids / Flavonoids
  is_sec_met <- (grepl("phenylalanine ammonia-lyase", descriptions) | grepl("\\bpal\\b", symbols) |
                 grepl("cinnamate", descriptions) | grepl("\\bc4h\\b", symbols) |
                 grepl("4-coumarate", descriptions) | grepl("\\b4cl\\b", symbols) |
                 grepl("chalcone", descriptions) | grepl("\\bchs\\b", symbols) | grepl("\\bchi\\b", symbols) |
                 grepl("flavonoid", descriptions) | grepl("isoflavonoid", descriptions) |
                 grepl("flavone", descriptions) | grepl("stilbene", descriptions))
  
  annotated_degs$functional_group[is_sec_met & annotated_degs$functional_group == "Other DEG"] <- "Secondary Metabolism (Flavonoids/Phenylpropanoids)"
  
  # 2c. Phytohormones (JA, SA, ET)
  is_ja <- (grepl("jasmon", descriptions) | grepl("\\blox\\b", symbols) | grepl("lipoxygenase", descriptions) |
            grepl("\\baos\\b", symbols) | grepl("allene oxide synthase", descriptions) |
            grepl("\\baoc\\b", symbols) | grepl("allene oxide cyclase", descriptions) |
            grepl("\\bopr\\b", symbols) | grepl("12-oxophytodienoate", descriptions) |
            grepl("\\bjaz\\b", symbols) | grepl("jasmonate-zim", descriptions) |
            grepl("\\bcoi1\\b", symbols) | grepl("\\bmyc2\\b", symbols))
  
  is_sa <- (grepl("salicyl", descriptions) | grepl("\\bnpr1\\b", symbols) | grepl("\\bpr1\\b", symbols) |
            grepl("pathogenesis-related protein 1", descriptions) | 
            grepl("\\bics1\\b", symbols) | grepl("isochorismate synthase", descriptions) |
            grepl("sard1", symbols))
  
  is_et <- (grepl("ethylene", descriptions) | grepl("\\baco\\b", symbols) | grepl("\\bacs\\b", symbols) |
            grepl("ein3", symbols) | grepl("ein2", symbols) | grepl("ctr1", symbols))
  
  annotated_degs$functional_group[is_ja & annotated_degs$functional_group == "Other DEG"] <- "Hormone: Jasmonic Acid"
  annotated_degs$functional_group[is_sa & annotated_degs$functional_group == "Other DEG"] <- "Hormone: Salicylic Acid"
  annotated_degs$functional_group[is_et & annotated_degs$functional_group == "Other DEG"] <- "Hormone: Ethylene"
  
  # 2d. ROS Scavenging & Oxidative Stress (Peroxidase, SOD, GST, Catalase)
  is_ros <- (grepl("peroxidase", descriptions) | grepl("\\bprx\\b", symbols) |
             grepl("superoxide dismutase", descriptions) | grepl("\\bsod\\b", symbols) |
             grepl("glutathione s-transferase", descriptions) | grepl("\\bgst\\b", symbols) |
             grepl("catalase", descriptions) | grepl("\\bcat\\b", symbols))
  
  annotated_degs$functional_group[is_ros & annotated_degs$functional_group == "Other DEG"] <- "ROS Scavenging / Redox homeostasis"
  
  # Filter only the key defense genes
  key_defense <- annotated_degs[annotated_degs$functional_group != "Other DEG", ]
  # Reorder columns logically
  key_defense <- key_defense[, c("Geneid", "at_id", "SYMBOL", "functional_group", "log2FoldChange", "pvalue", "padj", "GENENAME")]
  # Sort by functional group, then by significance
  key_defense <- key_defense[order(key_defense$functional_group, key_defense$padj), ]
  
  # Save to file
  out_path <- file.path("results", paste0("key_defense_genes_", prefix, ".csv"))
  write.csv(key_defense, out_path, row.names = FALSE)
  
  message(prefix, " - Extracted ", nrow(key_defense), " key defense genes. Saved to: ", out_path)
  
  # Print count by group
  print(table(key_defense$functional_group))
  return(key_defense)
}

# 3. Execute key genes extraction
k6h <- extract_key_genes("results/I6H_vs_C0H_sig_DEGs.csv", "I6H_vs_C0H")
k12h <- extract_key_genes("results/I12H_vs_C0H_sig_DEGs.csv", "I12H_vs_C0H")
k24h <- extract_key_genes("results/I24H_vs_C0H_sig_DEGs.csv", "I24H_vs_C0H")

message("\nKey defense genes extraction completed successfully!")
