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

# Set lib.path for use on Cigene cluster.
.libPaths( c( .libPaths(), "/mnt/users/tikn/R/x86_64-redhat-linux-gnu-library/3.2") )

library(argparser, quietly=TRUE)
# Create a parser
p <- arg_parser("Convert phased VCF file to Haplovew Haps format")

# Add command line arguments
p <- add_argument(p, "VCF", help="Phased VCF file to convert", type="character")
#p <- add_argument(p, "--digits", help="number of decimal places", default=0)

# Parse the command line arguments
argv <- parse_args(p)

# Do work based on the passed arguments
# cat( round(argv$number, argv$digits), "\n")

load_packages <- function(){
require(data.table, quietly = T)
library(plyr, quietly = T)
library(stringr ,quietly = T)
library(splitstackshape, quietly = T)
suppressPackageStartupMessages(library(dplyr, quietly = T))
}

load_packages() ;  cat("Loading a perverse number of packages for this trivial task\n")
#vcf <- "~/Projects/Fatty_acids_bovine/variant_calling/example_LD_haploview_10_snps_beagle.vcf"
vcf <- argv$VCF
#vcf <- "example_LD_haploview_10_snps.vcf"


geno2alleles <- "~tikn/bioinf_tools/freebayes/vcflib/bin/vcfgeno2alleles"
## Skip ## in VCF and convert 0 1 to ACGT.
command <- sprintf("%s < %s | grep -v '##'", geno2alleles, vcf)
dict <- c("A" = 1, "C" = 2, "G" = 3, "T" = 4, "." = 0)

# function for writing datafiles
write_data <- function(df,filename) {
	write.table(df,file = filename, row.names = F, col.names = F, quote = F, sep = " ")
}

# Read VCF
infile <- fread(command, header = T, sep = "\t")

#system(sprintf("cat %s", vcf))
#setnames(infile, "#CHROM", "CHROM")
samples <- str_trim(names(infile))
sample_col_start <- which(str_detect(samples, "FORMAT")) + 2

outfile <- ddply(infile, .(POS), str_extract, "[ACGT]/[ACGT]")
samplecols <- seq(sample_col_start, ncol(outfile), 1)
outfile <- select(outfile, samplecols) %>% tbl_dt()

setnames(outfile, names(outfile), samples[10:length(samples)])
outfile <- cSplit(outfile, names(outfile), "/")
outfile <- apply(outfile, 2, function(x) dict[x]) %>% t() # mysteriously change ACGT to 1234 and transpose
outfile <- cbind("Fam", str_replace(rownames(outfile), pattern = "_1|_2", ""), outfile)

## Write data file
write_data(outfile, filename = sprintf("%s.dat", vcf))
## Write locus info file
write_data(df = cbind(paste("marker_", 1:nrow(infile), sep = ""), select(infile,POS)),
			  filename = sprintf("%s.locusinfo.txt", vcf))
