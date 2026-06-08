#!/bin/bash

# Usage:
# bash scripts/run_rnaseq_pipeline.sh C0H_R2 SRR38388772

set -e

########################################
# Check arguments
########################################

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage:"
    echo "bash scripts/run_rnaseq_pipeline.sh SAMPLE SRR"
    exit 1
fi

SAMPLE=$1
SRR=$2

THREADS=8

echo "====================================="
echo "Processing: $SAMPLE"
echo "SRR: $SRR"
echo "====================================="

########################################
# 1. Download SRA
########################################

prefetch $SRR

mv $SRR raw_data/$SAMPLE

########################################
# 2. FASTQ conversion
########################################

fasterq-dump \
raw_data/$SAMPLE/$SRR.sra \
-e $THREADS \
-O raw_data/$SAMPLE

mv raw_data/$SAMPLE/${SRR}_1.fastq \
raw_data/$SAMPLE/${SAMPLE}_r1.fastq

mv raw_data/$SAMPLE/${SRR}_2.fastq \
raw_data/$SAMPLE/${SAMPLE}_r2.fastq

########################################
# 3. Raw FastQC
########################################

fastqc \
raw_data/$SAMPLE/${SAMPLE}_r1.fastq \
raw_data/$SAMPLE/${SAMPLE}_r2.fastq \
-o qc

########################################
# 4. Trimming
########################################

trim_galore \
--paired \
-o trimmed \
raw_data/$SAMPLE/${SAMPLE}_r1.fastq \
raw_data/$SAMPLE/${SAMPLE}_r2.fastq

########################################
# 5. Rename trimmed outputs
########################################

mv trimmed/${SAMPLE}_r1_val_1.fq \
trimmed/${SAMPLE}_r1_trimmed.fq

mv trimmed/${SAMPLE}_r2_val_2.fq \
trimmed/${SAMPLE}_r2_trimmed.fq

########################################
# 6. FastQC after trimming
########################################

fastqc \
trimmed/${SAMPLE}_r1_trimmed.fq \
trimmed/${SAMPLE}_r2_trimmed.fq \
-o qc_trimmed

########################################
# 7. Alignment
########################################

hisat2 \
-p $THREADS \
-x reference/GWH_reference/hisat2_index/licorice \
-1 trimmed/${SAMPLE}_r1_trimmed.fq \
-2 trimmed/${SAMPLE}_r2_trimmed.fq \
-S alignments/${SAMPLE}.sam

########################################
# 8. BAM conversion
########################################

samtools view \
-bS alignments/${SAMPLE}.sam \
-o alignments/${SAMPLE}.bam

########################################
# 9. Sort BAM
########################################

samtools sort \
-@ $THREADS \
-o alignments/${SAMPLE}.sorted.bam \
alignments/${SAMPLE}.bam

########################################
# 10. BAM index
########################################

samtools index \
alignments/${SAMPLE}.sorted.bam

########################################
# 11. Gene counting
########################################

featureCounts \
-T $THREADS \
-p \
-t gene \
-g ID \
-a reference/GWH_reference/annotation.gff \
-o counts/${SAMPLE}_counts.txt \
alignments/${SAMPLE}.sorted.bam

########################################
# 12. Cleanup
########################################

rm -f alignments/${SAMPLE}.sam
rm -f alignments/${SAMPLE}.bam
rm -f alignments/${SAMPLE}.sorted.bam
rm -f alignments/${SAMPLE}.sorted.bam.bai



echo ""
echo "====================================="
echo "Pipeline completed successfully!"
echo "Sample: $SAMPLE"
echo "====================================="
echo ""
