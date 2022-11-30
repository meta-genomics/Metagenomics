#!/usr/bin/bash

threads=$1

echo "--------------------- METAPIPELINE [PASO 1]:--------------------------------------"
echo "                 		QUALITY CHECK                                           "
echo "----------------------------------------------------------------------------------"

#1: First quality check: ---------------------------------------------------------------------

 fastqc raw-reads/*.fastq -o results/fastqc/ > results/fastqc/fastqc_verbose.txt

#2: Clean the reads: -------------------------------------------------------------------------
# Usage:
#       PE [-version] [-threads <threads>] [-phred33|-phred64] [-trimlog <trimLogFile>] 
#	[-summary <statsSummaryFile>] [-quiet] [-validatePairs] [-basein <inputBase> | <inputFile1> <inputFile2>] 
#	[-baseout <outputBase> | <outputFile1P> <outputFile1U> <outputFile2P> <outputFile2U>] <trimmer1>...


for R1 in raw-reads/*_1.fastq
	do
		R2=${R1//_1.fastq/_2.fastq}
		base=$(basename ${R1} _1.fastq)

		trimmomatic PE $R1 $R2\
				-threads $threads \
				results/trimmed-reads/${base}_1.trim.fastq \
				results/untrimmed-reads/${base}_1.unpaired.fastq \
                                results/trimmed-reads/${base}_2.trim.fastq \
                                results/untrimmed-reads/${base}_2.unpaired.fastq \
				HEADCROP:20 SLIDINGWINDOW:4:20 MINLEN:35
	
	done


#3: Second quality check after trimming: --------------------------------------------------------

mkdir results/fastqc/trimQC

fastqc  results/trimmed-reads/*.fastq \
	-o results/fastqc/trimQC/ > results/fastqc/trimQC/fastqc_trim_verbose.txt
