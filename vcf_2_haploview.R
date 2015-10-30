#!/usr/bin/env Rscript

## Convert phased VCF to haploview Haps format.
##	ID1	ID2
##	0|1	1|1
##	1|1	0|0

## To:

## ID1	A	T
## ID1	G	T
## ID2	G	A
## ID2	G	A


# Set lib.paths for use on Cigene cluster. -------------------------------
.libPaths( c( .libPaths(), "/mnt/users/tikn/R/x86_64-unknown-linux-gnu-library/3.2") )
geno2alleles <- "~tikn/bioinf_tools/freebayes/vcflib/bin/vcfgeno2alleles"

# Create a parser ---------------------------------------------------------
library(argparser, quietly=TRUE)
p <- arg_parser(
"Convert VCF file to Haplovew Haps format. Detects if file is gzipped.
Appends .dat and locusinfo.txt to input VCF prefix.")
# Add command line arguments
p <- add_argument(p, "VCF", help="Phased VCF file to convert.", type="character")
# Parse the command line arguments
argv <- parse_args(p)
vcf <- argv$VCF

# Load required packages --------------------------------------------------
load_packages <- function(){
require(data.table, quietly = T)
library(plyr, quietly = T)
library(stringr ,quietly = T)
library(splitstackshape, quietly = T)
suppressPackageStartupMessages(library(dplyr, quietly = T))
}

load_packages() #;  cat("\nLoading a perverse number of packages for this trivial task\n\n")
#vcf <- "example_LD_haploview_10_snps_beagle.vcf.gz"
#vcf <- "FA_sign_variants_allelic_primitives_Q30.with_ID_exclude_3454_1893_GQ30.snps.noprim_beaglephased.vcf.gz"


# Set functions and variables ---------------------------------------------
gzipped <- ifelse(str_detect(vcf, "vcf$"), "cat", "zcat")
dict <- c("A" = 1, "C" = 2, "G" = 3, "T" = 4, "." = 0) # haploview alleles.
command <- sprintf("%s  %s | %s | grep -v '##'", gzipped, vcf, geno2alleles) ## Skip ## in VCF text or zipped and convert 0/1 genotypes to ACGT.

# function for writing datafiles
write_data <- function(df,filename) {
	write.table(df,file = filename, row.names = F, col.names = F, quote = F, sep = " ")
}


# Read, convert and write files. ------------------------------------------
infile <- fread(command, header = T, sep = "\t")

#system(sprintf("cat %s", vcf))
#setnames(infile, "#CHROM", "CHROM")
samples <- str_trim(names(infile))
sample_col_start <- which(str_detect(samples, "FORMAT")) + 1

outfile <- apply(infile, 2, str_extract, "[ACGT]/[ACGT]")
outfile <- data.frame(outfile[,10:ncol(outfile)])
setnames(outfile, names(outfile), samples[10:length(samples)])

outfile <- cSplit(outfile, names(outfile), "/")
outfile <- apply(outfile, 2, function(x) dict[x]) %>% t() # mysteriously change ACGT to 1234 and transpose
outfile <- cbind("Fam", str_replace(rownames(outfile), pattern = "_1|_2", ""), outfile)

## Write data file
outname <- str_replace(vcf, "\\.vcf$|\\.vcf\\.gz$", "")

write_data(outfile, filename = sprintf("%s.dat", outname))
## Write locus info file
write_data(df = cbind(paste("marker_", 1:nrow(infile), sep = ""), select(infile,POS)),
			  filename = sprintf("%s.locusinfo.txt", outname))
	cat(sprintf("Convertion finished.\nOutput files:\n%s.dat\n%s.locusinfo.txt\n\n", outname, outname))
