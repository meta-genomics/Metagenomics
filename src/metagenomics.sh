#!/usr/bin/bash

#####################################################################
#	PIPELINE PARA EL PROCESAMIENTO DE MUESTRAS METAGENÓMICAS    #
#			Dulce I. Valdivia                           #    
#####################################################################

#####################################################################
# Pipeline completo:                                                
#       1. Usar el script setup.sh 				    
#       2. Colocar los archivos fastq en el directorio 		    
#			raw-reads/				
#	3. Activar el ambiente conda:
#			conda activate meta-omics
#       4. Correr este script indicando el número de threads. E.g.:
#			metagenomics.sh 16
#	5. Utilizar la salida 
#			results/taxonomy/kraken/*.json como 
#	entrada del análisis de R ../r-analysis/*.Rmd
#####################################################################


threads=$1

# SCRIPT 1 ----------------------------------------------------------
# Run:
	./src/1_qualityCheck.sh $threads >> metagenomics.log

# SCRIPT 2 ----------------------------------------------------------
# Config:
	export PATH="/home/metagenomics/projects/biodigestores/metaPipeline/lib/SPAdes-3.15.5-Linux/bin:$PATH"
	export PATH="/home/metagenomics/projects/biodigestores/metaPipeline/lib/MaxBin-2.2.7/:$PATH"
# Run:
	./src/2_metagenomeAssembly.sh $threads >> metagenomics.log

# SCRIPT 3 ----------------------------------------------------------
# Config:
	dirKrakenDB="home/metagenomics/data/krakenDB"
# Run:
	./src/3_taxonomicAssignment.sh $threads $dirKrakenDB >> metagenomics.log
