#! /usr/bin/env Rscript

#configure trailing arguments
args <- commandArgs(trailingOnly = TRUE)

require("rrBLUP")
library("rrBLUP")

#args = c("/Users/ianmcnish/GoogleDrive/courses/genomics_ta/gwas","GAPIT.RNAseq.hmp_438K_imputed2_rrblup.csv","tpc119982SupplementalDS6.csv",3,1,503,"TRUE")

#import genotype and phenotype files
working_directory <- args[1]
genotype_file <- args[2]
phenotype_file <- args[3]
n_core <- as.numeric(args[4])
n_pc <- as.numeric(args[5])
n_lines <- as.numeric(args[6])
debug_mode <- args[7]

setwd(working_directory)

#format genotype file line names to uppercase to match phenotype
if(debug_mode == TRUE){
  genotypes <- read.csv(genotype_file, header = T, nrows = 1000)[,-c(2,5:11)]
}else{
  genotypes <- read.csv(genotype_file, header = T)[,-c(2,5:11)]
}

if(n_lines<503){
  markers_defs <- genotypes[, c(1:3)]
  genotypes <- genotypes[, -c(1:3)]
  genotypes <- genotypes[, sample(ncol(genotypes), n_lines)]
  genotypes <- cbind(markers_defs, genotypes)
}

names(genotypes) <- toupper(names(genotypes))

phenotypes <- read.csv(phenotype_file, header = T, skip = 2)[,c(1:4)]

#these lines are necesarry to format the phenotype line names to match the genotype
phenotypes$Genotype <- toupper(phenotypes$Genotype)
phenotypes$Genotype <- gsub(" ","",phenotypes$Genotype)
phenotypes$Genotype <- gsub("-","",phenotypes$Genotype)
phenotypes$Genotype <- gsub("_","",phenotypes$Genotype)
phenotypes$Genotype <- gsub("\\.","",phenotypes$Genotype)
phenotypes$Genotype <- gsub("\\(","",phenotypes$Genotype)
phenotypes$Genotype <- gsub("\\)","",phenotypes$Genotype)
phenotypes$Genotype <- as.factor(phenotypes$Genotype)

#the genotypes in both files must be limited to lines in both files and the files must be formated to rrblup format
lines_genotypes <- as.character(names(genotypes)[4:ncol(genotypes)])
lines_phenotypes <- as.character(phenotypes$Genotype)
lines_both <- intersect(lines_genotypes, lines_phenotypes)
genotypes <- genotypes[,c( "RS", "CHROM", "POS", lines_both)]
genotypes$CHROM <- as.numeric(genotypes$CHROM)
genotypes$POS <- as.numeric(genotypes$POS)
phenotypes <- phenotypes[phenotypes$Genotype %in% lines_both, c(1,3)]

#open pdf file for charts to print, run GWAS
model <- GWAS(geno = genotypes, pheno = phenotypes, n.core = n_core, n.PC = n_pc)

#calculate p-values, fdr, and classify fdr results
model$p <- 10^(-model$Growing.Degree.Days.to.Pollen.Shed)
model$rank <- rank(model$p, ties.method = 'min')
model$fdr <- 0.05*(model$rank/max(model$rank))
model$fdr_result <- ifelse(model$fdr > model$p, "significant", "not significant")

write.csv(model,"results.csv", row.names = FALSE)

print("rrBLUP complete")


