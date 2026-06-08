import csv

# Load the mapped GWH identifiers
with open('/home/shiva/bioinformatics_plant_projects/licorice_insect_rnaseq/results/gwh_to_arabidopsis_mapping.csv', 'r') as f:
    reader = csv.reader(f)
    next(reader) # skip header
    gwh_mapped = set(row[0] for row in reader if row)

# Parse DEGs and compute statistics
for tp in ['I6H', 'I12H', 'I24H']:
    path = f'/home/shiva/bioinformatics_plant_projects/licorice_insect_rnaseq/results/{tp}_vs_C0H_sig_DEGs.csv'
    with open(path, 'r') as f:
        reader = csv.reader(f)
        next(reader) # skip header
        gene_ids = [row[0] for row in reader if row]
    
    total = len(gene_ids)
    mapped = sum(1 for g in gene_ids if g in gwh_mapped)
    unmapped = total - mapped
    pct = (unmapped * 100.0) / total if total > 0 else 0
    print(f'{tp}: Total {total} | Mapped {mapped} | Unmapped (Novel) {unmapped} ({pct:.2f}%)')
