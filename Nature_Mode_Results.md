# Genome-wide transcriptomic reorganization suggests resource allocation trade-offs and specialized chemical defense modulation in Glycyrrhiza uralensis under herbivore attack

**Shiva Raj Chippa**
*Bioinformatician | Computational Biology Enthusiast, IISER Tirupati Alumni*

**Plants respond to herbivory through complex networks of signal transduction and metabolic adjustments. Here, we profile the transcriptomic response of the medicinal legume Glycyrrhiza uralensis to chewing insect infestation across a 24-hour timecourse. Using strict homology filtering and statistical criteria, we show that G. uralensis reorganizes its transcriptome to suppress primary light-harvesting processes while activating flavonoid and phenylpropanoid biosynthesis. Our temporal analysis suggests a progressive signaling-to-metabolite response, identifying candidate novel species-specific defense genes and highlighting time-dependent jasmonate signaling dynamics.**

## Global transcriptional dynamics and replicate validation

To understand G. uralensis transcriptional defense networks, we performed RNA-seq on leaves harvested at 0h, 6h, 12h, and 24h post-infestation. Principal Component Analysis (PCA) of VST-normalized counts revealed that biological replicates cluster tightly, indicating minimal technical variance. PC1 captures 56% of total variance and separates early stages (0-6h) from later responses (12-24h). Hierarchical distance heatmaps confirmed these groupings, showing that the transcriptome undergoes progressive, coordinated remodeling in response to insect chewing.

## Homology filtering isolates novel legume-specific candidates

To map GWH annotations to the model Arabidopsis thaliana proteome, we ran DIAMOND blastp. To prevent annotation over-claiming, homologs were filtered strictly: E-value <= 1e-5, identity >= 30%, and single best-hit selection based on bitscore. This logic resolved 25,121 high-confidence ortholog mappings (63.6% of GWH genes). Umapped DEGs represent candidate novel or lineage-specific genes: we identified 1,177 novel DEGs at 6h (13.64%), 1,015 at 12h (12.98%), and 1,309 at 24h (13.33%). These candidate novel genes represent a rich genomic resource for specialized defense features in Glycyrrhiza.

## Functional enrichment highlights growth-defense trade-offs

Over-representation analysis (ORA) using clusterProfiler (BH-adjusted padj < 0.05, qvalue < 0.05) separate upregulated and downregulated processes. Upregulated biological processes show robust induction of flavonoid biosynthesis (ath00941) and ribosome translation (ath03010) across all timepoints, driving chemical defense mechanisms. Downregulated pathways are enriched in photosynthesis thylakoid membrane proteins (ath00196) and light-harvesting antenna centers, suggesting suppression of photosynthesis to conserve energy resources (growth-defense trade-offs).

## Time-dependent modulation of jasmonic and salicylic acid signaling

We observed time-dependent modulation of JA signaling components rather than simple pathway activation. Putative homologs of lipoxygenases (LOX4) and allene oxide cyclase (AOC1) were differentially regulated. Putative master transcription factor MYC2 showed a delayed induction, remaining non-significant early (6h, padj = 0.18) but showing strong upregulation later (12h, 24h). Conversely, repressor JAZ1 homologs exhibited dynamic regulatory behavior (downregulated at 6h, upregulated at 12h, and downregulated at 24h). Salicylic acid (SA) homologs (SARD1, TGA3) showed limited evidence of SA-associated transcriptional modulation under chewing stress, while PR1 was unmapped and NPR1 was filtered due to low counts.

Upregulation of genes associated with secondary metabolism (PAL1, C4H, 4CL1, CHS, CHI) suggests potential accumulation of protective flavonoids (liquiritin/liquiritigenin precursors), although metabolite concentrations were not directly measured.

Table 1: Expression fold changes (log2FC) and BH-adjusted p-values (padj) for key representative plant defense genes.

| **Symbol** | **G. uralensis Locus** | **Functional Group** | **6H log2FC<br>(padj)** | **12H log2FC<br>(padj)** | **24H log2FC<br>(padj)** |
| --- | --- | --- | --- | --- | --- |
| **PAL1** | GUL07G002927 | Secondary Metabolism | +7.17<br>(2.61e-11) | +2.41<br>(5.31e-02) | +6.46<br>(1.98e-09) |
| **C4H** | GUL06G001053 | Secondary Metabolism | +1.82<br>(4.25e-12) | +2.08<br>(1.43e-15) | +3.20<br>(3.78e-36) |
| **4CL1** | GUL07G000030 | Secondary Metabolism | +2.11<br>(2.71e-08) | +2.42<br>(1.35e-10) | +6.02<br>(3.28e-62) |
| **CHS** | GUL06G004396 | Secondary Metabolism | +0.34<br>(1.35e-02) | +3.07<br>(2.01e-142) | +3.09<br>(3.38e-144) |
| **CHI** | GUL02G005484 | Secondary Metabolism | +1.33<br>(2.26e-11) | +1.77<br>(1.29e-19) | +2.00<br>(6.95e-25) |
| **DFR** | Not Mapped | Secondary Metabolism | N/A | N/A | N/A |
| **LOX4** | GUL07G004353 | Jasmonic Acid Pathway | +0.00<br>(1.0) | +7.87<br>(2.80e-02) | +0.00<br>(1.0) |
| **AOS** | GUL08G001604 | Jasmonic Acid Pathway | N/A | N/A | N/A |
| **AOC1** | GUL06G002173 | Jasmonic Acid Pathway | +2.07<br>(6.14e-04) | +0.04<br>(9.72e-01) | -0.55<br>(4.32e-01) |
| **COI1** | GUL06G000800 | Jasmonic Acid Pathway | +1.26<br>(8.63e-17) | +0.66<br>(3.23e-05) | +0.72<br>(3.56e-06) |
| **JAZ1** | GUL07G000628 | Jasmonic Acid Pathway | -2.39<br>(1.41e-71) | +1.13<br>(5.56e-17) | -2.62<br>(1.22e-85) |
| **MYC2** | GUL06G003272 | Jasmonic Acid Pathway | +0.20<br>(1.83e-01) | +1.37<br>(4.99e-27) | +1.04<br>(4.37e-16) |
| **NPR1** | GUL07G000455 | Salicylic Acid Pathway | -5.86<br>(N/A*) | -5.68<br>(N/A*) | +1.27<br>(N/A*) |
| **PR1** | Not Mapped | Salicylic Acid Pathway | N/A | N/A | N/A |
| **SARD1** | GUL08G002584 | Salicylic Acid Pathway | -4.56<br>(2.19e-07) | +2.28<br>(1.38e-02) | -2.93<br>(1.04e-03) |
| **TGA3** | GUL06G001808 | Salicylic Acid Pathway | -0.72<br>(6.62e-01) | -1.24<br>(4.13e-01) | -2.53<br>(6.00e-02) |

**N/A represents genes filtered out by DESeq2 independent filtering or genes with missing values due to mapping annotation limitations.*

## Progressive transcriptomic response model

In summary, our temporal transcriptomics suggest a progressive response cascade. Early insect chewing is associated with cell-wall wounding, triggering Ca2+ and MAPK signaling cascades at 6h. This signaling coincides with a time-dependent phytohormone modulation (JA pathway) at 12h, allowing transcription factor activation (such as MYC2 and WRKYs). By 24h, this transcription program contributes to downstream defenses, including upregulated flavonoid synthesis and redox homeostasis enzymes (SOD, GSTs), while growth-associated photosynthesis genes are repressed.
