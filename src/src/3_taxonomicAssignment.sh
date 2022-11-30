#!/usr/bin/bash

echo "--------------------- METAPIPELINE [PASO 5]---------------------------------------"
echo "                       TAXONOMIC ASSIGNMENT                                       "
echo "----------------------------------------------------------------------------------"

threads=$1
krakenDB=$2

# Taxonomic assignment ---------------------------------------------------

for R1 in results/trimmed-reads/*_1.trim.fastq
        do
                R2=${R1//_1.trim.fastq/_2.trim.fastq}
                base=$(basename ${R1} _1.trim.fastq)
		wdir=results/taxonomy/kraken/kraken_${base}
		
		if [ -d "$wdir" ]
			then 
				echo IMPORTANT:
				echo There is a previous run for sample: ${base}
				echo The directory ${wdir} will be deleted 
		
				rm -r $wdir
			fi

		mkdir $wdir
		echo New directory ${wdir} created for sample ${base}

		kraken2 --db $krakenDB \
			--threads $threads \
			--paired $R1 $R2 \
			--output ${wdir}/${base}.kraken.out \
			--report ${wdir}/${base}.kraken.report

	done

echo "---------------------- METAPIPELINE [PASO 6]---------------------------------------"
echo "                       PARSING KRAKEN'S OUTPUT                                     "
echo "-----------------------------------------------------------------------------------"

# Create json file for R analysis ------------------------------------
#	 kraken-biom parses the .report files.
# 	 The option --min P can be used to keep assignments that have 
#	 at least phylum taxa, but this can also be filtered during
#	 the R analysis

kraken-biom results/taxonomy/kraken/kraken_*/*.report \
	-o taxonomy_kraken.json \
	--fmt json  
