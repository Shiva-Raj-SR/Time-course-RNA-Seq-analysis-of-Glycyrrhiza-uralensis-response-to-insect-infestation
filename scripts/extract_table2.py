import csv

# Define key defense genes of interest
genes_of_interest = [
    # Secondary Metabolism (Flavonoids/Phenylpropanoids)
    {"at_id": "AT2G37040", "symbol": "PAL1", "desc": "Phenylalanine ammonia-lyase 1", "group": "Secondary Metabolism"},
    {"at_id": "AT2G30490", "symbol": "C4H", "desc": "Cinnamate 4-hydroxylase", "group": "Secondary Metabolism"},
    {"at_id": "AT1G51680", "symbol": "4CL1", "desc": "4-coumarate-CoA ligase 1", "group": "Secondary Metabolism"},
    {"at_id": "AT5G13930", "symbol": "CHS", "desc": "Chalcone synthase", "group": "Secondary Metabolism"},
    {"at_id": "AT3G55120", "symbol": "CHI", "desc": "Chalcone isomerase", "group": "Secondary Metabolism"},
    {"at_id": "AT5G38620", "symbol": "DFR", "desc": "Dihydroflavonol 4-reductase", "group": "Secondary Metabolism"},
    
    # Jasmonic Acid Biosynthesis & Signaling
    {"at_id": "AT1G72520", "symbol": "LOX4", "desc": "Lipoxygenase 4", "group": "Jasmonic Acid Pathway"},
    {"at_id": "AT5G42650", "symbol": "AOS", "desc": "Allene oxide synthase", "group": "Jasmonic Acid Pathway"},
    {"at_id": "AT3G25760", "symbol": "AOC1", "desc": "Allene oxide cyclase 1", "group": "Jasmonic Acid Pathway"},
    {"at_id": "AT2G39940", "symbol": "COI1", "desc": "Coronatine-insensitive 1 receptor", "group": "Jasmonic Acid Pathway"},
    {"at_id": "AT1G19180", "symbol": "JAZ1", "desc": "Jasmonate-ZIM domain protein 1", "group": "Jasmonic Acid Pathway"},
    {"at_id": "AT1G32640", "symbol": "MYC2", "desc": "Transcription factor MYC2", "group": "Jasmonic Acid Pathway"},
    
    # Salicylic Acid Biosynthesis & Signaling
    {"at_id": "AT1G64280", "symbol": "NPR1", "desc": "Nonexpressor of PR genes 1", "group": "Salicylic Acid Pathway"},
    {"at_id": "AT2G14610", "symbol": "PR1", "desc": "Pathogenesis-related protein 1", "group": "Salicylic Acid Pathway"},
    {"at_id": "AT1G73805", "symbol": "SARD1", "desc": "Systemic acquired resistance deficient 1", "group": "Salicylic Acid Pathway"},
    {"at_id": "AT1G22070", "symbol": "TGA3", "desc": "Transcription factor TGA3", "group": "Salicylic Acid Pathway"}
]

# 1. Load the GWH-to-Arabidopsis mapping
at_to_gwh = {}
with open('/home/shiva/bioinformatics_plant_projects/licorice_insect_rnaseq/results/gwh_to_arabidopsis_mapping.csv', 'r') as f:
    reader = csv.reader(f)
    next(reader)
    for row in reader:
        if row:
            gwh_id, at_id = row[0], row[1]
            at_to_gwh[at_id] = gwh_id

# 2. Function to load fold change and padj from DEG results
def load_deg_stats(filepath):
    stats = {}
    with open(filepath, 'r') as f:
        reader = csv.reader(f)
        header = next(reader)
        # Find column indices
        gene_idx = header.index("Geneid")
        log2fc_idx = header.index("log2FoldChange")
        padj_idx = header.index("padj")
        
        for row in reader:
            if row:
                gene_id = row[gene_idx]
                log2fc = float(row[log2fc_idx]) if row[log2fc_idx] else 0.0
                padj = float(row[padj_idx]) if row[padj_idx] and row[padj_idx] != "NA" else None
                stats[gene_id] = (log2fc, padj)
    return stats

# Load DEG stats for each timepoint
stats_6h = load_deg_stats('/home/shiva/bioinformatics_plant_projects/licorice_insect_rnaseq/results/I6H_vs_C0H_all.csv')
stats_12h = load_deg_stats('/home/shiva/bioinformatics_plant_projects/licorice_insect_rnaseq/results/I12H_vs_C0H_all.csv')
stats_24h = load_deg_stats('/home/shiva/bioinformatics_plant_projects/licorice_insect_rnaseq/results/I24H_vs_C0H_all.csv')

# 3. Pull stats for our genes of interest
output_rows = []
for g in genes_of_interest:
    at_id = g["at_id"]
    symbol = g["symbol"]
    desc = g["desc"]
    group = g["group"]
    
    gwh_id = at_to_gwh.get(at_id, "Not Mapped")
    
    row_data = {
        "at_id": at_id,
        "gwh_id": gwh_id,
        "symbol": symbol,
        "group": group,
        "desc": desc,
        "lfc_6h": "N/A", "padj_6h": "N/A",
        "lfc_12h": "N/A", "padj_12h": "N/A",
        "lfc_24h": "N/A", "padj_24h": "N/A"
    }
    
    if gwh_id != "Not Mapped":
        if gwh_id in stats_6h:
            lfc, padj = stats_6h[gwh_id]
            row_data["lfc_6h"] = f"{lfc:.2f}"
            row_data["padj_6h"] = f"{padj:.4e}" if padj is not None else "N/A"
        if gwh_id in stats_12h:
            lfc, padj = stats_12h[gwh_id]
            row_data["lfc_12h"] = f"{lfc:.2f}"
            row_data["padj_12h"] = f"{padj:.4e}" if padj is not None else "N/A"
        if gwh_id in stats_24h:
            lfc, padj = stats_24h[gwh_id]
            row_data["lfc_24h"] = f"{lfc:.2f}"
            row_data["padj_24h"] = f"{padj:.4e}" if padj is not None else "N/A"
            
    output_rows.append(row_data)

# 4. Save to CSV
out_path = '/home/shiva/bioinformatics_plant_projects/licorice_insect_rnaseq/results/table2_representative_defense_genes.csv'
with open(out_path, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=[
        "at_id", "gwh_id", "symbol", "group", "desc",
        "lfc_6h", "padj_6h",
        "lfc_12h", "padj_12h",
        "lfc_24h", "padj_24h"
    ])
    writer.writeheader()
    writer.writerows(output_rows)

print(f"Table 2 extracted successfully and saved to {out_path}!")
for row in output_rows[:5]:
    print(f"{row['symbol']} ({row['gwh_id']}): 6H LFC={row['lfc_6h']} | 12H LFC={row['lfc_12h']} | 24H LFC={row['lfc_24h']}")
