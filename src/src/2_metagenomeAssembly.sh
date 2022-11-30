#!/usr/bin/bash

echo "--------------------- METAPIPELINE [PASO 2]---------------------------------------"
echo "                        METAGENOME ASSEMBLY                                       "
echo "----------------------------------------------------------------------------------"

threads=$1

# GENOME ASSEMBLY ---------------------------------------------------------------

for R1 in results/trimmed-reads/*_1.trim.fastq
	do
		R2=${R1//_1.trim.fastq/_2.trim.fastq}
		base=$(basename ${R1} _1.trim.fastq)

		metaspades.py -1 $R1 -2 $R2 \
			-o results/assemblies/assembly_${base} \
			--threads $threads \
			> results/assemblies/metaspades_verbose.txt

	done

for d in results/assemblies/assembly_*
	do
		base=${d:31:11}
		cp ${d}/scaffolds.fasta results/assemblies/${base}-scaffolds.fasta
	done

echo "--------------------- METAPIPELINE [PASO 3]---------------------------------------"
echo "                        	 BINNING  		                                "
echo "----------------------------------------------------------------------------------"


# BINNING  ---------------------------------------------------------------------

for d in results/assemblies/assembly_*
	do
		# Create a working directory for maxbin
		base=${d:31:11}
		mkdir results/assemblies/maxbin_${base}

		# MaxBin call
		lib/MaxBin-2.2.7/run_MaxBin.pl -thread $threads \
			-contig results/assemblies/${base}-scaffolds.fasta \
			-reads results/trimmed-reads/${base}_1.trim.fastq \
			-reads2 results/trimmed-reads/${base}_2.trim.fastq \
			-out results/assemblies/maxbin_${base}/${base} \
				> results/assemblies/maxbin_${base}.log					
	done



echo "--------------------- METAPIPELINE [PASO 4]---------------------------------------"
echo "                      QUALITY OF THE BINNING                                      "
echo "----------------------------------------------------------------------------------"


# QUALITY OF THE BINNING ---------------------------------------------------------------

for d in results/assemblies/assembly_*
       do
		# Create a working directory for checkm
		base=${d:31:11}
		mkdir results/assemblies/checkm_${base}

		# CheckM call
		checkm lineage_wf \
			-x fasta results/assemblies/maxbin_${base} \
			results/assemblies/checkm_${base} \
			-t 16 > results/assemblies/checkm_${base}_verbose.txt
	done
