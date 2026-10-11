# Time-course transcriptomic analysis of *Glycyrrhiza uralensis* under insect infestation

**Shiva Raj Chippa**  
*Bioinformatician | Computational Biology Enthusiast, IISER Tirupati Alumni*

**This project profiles the transcriptomic response of *Glycyrrhiza uralensis* leaves to chewing insect infestation across a 24-hour time course. Differential expression, best-hit mapping to *Arabidopsis thaliana*, and GO/KEGG over-representation analyses identify candidate genes and functional categories for follow-up. These computational results support hypotheses about defense-associated transcriptional changes; they do not demonstrate pathway activity, metabolite accumulation, or causal resource allocation. Genes without a retained Arabidopsis match are described as unmapped in this analysis, not as confirmed novel or species-specific genes.**

## Global transcriptional patterns

RNA-seq samples were collected at 0, 6, 12, and 24 hours after infestation. PCA of variance-stabilized counts shows PC1 accounting for 56% of the variance and separates the 0–6 hour samples from the 12–24 hour samples in the plotted data. The sample-distance heatmap shows a similar pattern. These plots describe overall expression-space similarities; replicate proximity does not quantify technical variance or independently establish experimental reproducibility, and the plotted separation alone does not identify its biological cause.

## Arabidopsis best-hit mapping

Licorice protein sequences were compared with the Arabidopsis proteome using DIAMOND blastp. The reported filtering used an E-value threshold of ≤ 1e-5, identity ≥ 30%, and retained the single highest-bitscore hit for each query. The project reports 25,121 retained best-hit associations (63.6% of GWH genes). A single best hit does not establish reciprocal or one-to-one orthology, so these are described as homology-based mappings rather than confirmed orthologs.

For the 6, 12, and 24 hour contrasts, the project reports 1,177, 1,015, and 1,309 DEGs, respectively, without a retained Arabidopsis mapping. “Unmapped” refers to this analysis and its thresholds. It does not establish that a gene is novel, lineage-specific, or involved in defense; lack of a match can also reflect sequence divergence, database representation, or filtering.

## Functional enrichment and pathway interpretation

The project reports GO and KEGG over-representation results for up- and down-regulated mapped gene sets. Reported categories include flavonoid biosynthesis (ath00941), ribosome (ath03010), photosynthesis-related pathways (ath00195 and ath00196), and alpha-linolenic acid metabolism (ath00592). These are enrichment associations among the analyzed Arabidopsis-mapped IDs. They do not by themselves show pathway activation or suppression, metabolite production, hormone activity, or an energy-allocation trade-off. The enrichment script does not specify a custom background universe, which is an additional limitation when interpreting the reported categories.

## Candidate hormone and secondary-metabolism genes

The following table reproduces the project’s reported expression estimates for selected candidate genes. Gene names and pathway labels refer to Arabidopsis best-hit annotations and should be interpreted as putative functional associations in licorice. The values are not direct measurements of protein activity, hormone levels, or metabolites. Reported differential expression of these candidates can motivate targeted follow-up, but does not establish the corresponding pathway’s activity.

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

**N/A indicates that a value or mapping was unavailable in the reported table; the cause depends on the entry and is not necessarily attributable to annotation mapping or DESeq2 filtering alone.**

The table shows time-dependent expression estimates for genes annotated as JA- or SA-associated in Arabidopsis. For example, the reported MYC2 estimates are positive at 12 and 24 hours, while JAZ1 estimates change direction across time points. Such patterns are candidate transcriptional observations, not direct evidence of hormone signaling activity. Likewise, expression estimates for PAL1, C4H, 4CL1, CHS, and CHI do not demonstrate accumulation of flavonoids such as liquiritin or liquiritigenin; metabolite concentrations were not measured here.

## Proposed response model

The project’s proposed model links early wound signaling, later hormone-associated transcription, candidate transcription factors, and secondary-metabolism genes. These links are hypotheses based on the expression and annotation analyses. This study did not directly measure calcium or MAPK signaling, hormone concentrations, photosynthetic rates, growth costs, or defense metabolites, so the proposed sequence and resource-allocation interpretation require independent experimental validation.
