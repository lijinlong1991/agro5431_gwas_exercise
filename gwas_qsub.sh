#!/bin/bash
#PBS -l walltime=01:00:00,nodes=1:ppn=16,mem=16gb
#PBS -o /home/agro5431/<user>/gwas_exercise/gwas_o
#PBS -e /home/agro5431/<user>/gwas_exercise/gwas_e
#PBS -N gwas

cd /home/agro5431/<user>/gwas_exercise
ln -s /home/agro5431/shared/GAPIT.RNAseq.hmp_438K_imputed2_no_quotes.csv gwas_genotypes.csv
ln -s /home/agro5431/shared/tpc119982SupplementalDS6.csv gwas_phenotypes.csv
module load perl
perl convert_for_rrblup.pl -i gwas_genotypes.csv -o genotypes_rrblup.csv -f 12 -l 514
module load R/3.3.3
Rscript gwas.R /home/agro5431/<user>/gwas_exercise/ genotypes_rrblup.csv gwas_phenotypes.csv 16 1 503 FALSE
