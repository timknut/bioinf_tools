#!/usr/bin/env Rscript
.libPaths(c( .libPaths(), "/mnt/users/tikn/R/x86_64-unknown-linux-gnu-library/3.2")) # Orion R
library(argparser, quietly=TRUE)
library(magrittr, quietly=TRUE)

 # Create a parser
p <- arg_parser("Run freebayes on a list of bam files. Region is optional") %>%
	add_argument("--bamlist", help="list of bamfiles. One per line", type="character", default = NULL) %>%
	add_argument("--reference", help="Reference file in Fasta format", type = "character", default = NULL) %>%
   add_argument("--out", help="Out prefix", type = "character") %>%
   add_argument("--region", help="format: <chrom>:<start_position>-<end_position>",
   				 type = "character", default = NA)

# Parse the command line arguments
argv <- parse_args(p)

vcf <- "freebayes"
if (!is.na(argv$out)){
	vcf <- sprintf("%s.vcf.gz", argv$out)
} else {
	vcf <- sprintf("freebayes_region_%s", argv$region) %>%
		stringr::str_replace(":", "_")
}
#vcf <- sprintf("%s.vcf.gz", argv$out)
# cat (vcf, "\n")
ref <- argv$reference

## Resolve region thing by having a if statement
## Somethng shitty happens here:
## freebayes \
## --region NA \

# if (is.na(argv$region)) {
# 	hash <- "#"
# 	region <- "no region specified"
# } else {
# 	hash <- ""
# 	region <- argv$region
# }
if (!is.na(argv$region)) {
	hash <- ""
	region <- sprintf("--region %s", argv$region)
} else {
hash <- "#"
region <- ""
}
#region <- "no region specified"


# make sbatch script
## Remember to count up % and so on..
## Alternatively use cat
if(!dir.exists("slurm_logs")) dir.create("slurm_logs")
sbatch <- sprintf(
"#!/bin/sh
#SBATCH -n 1            # -n cores
#SBATCH -N 1            # -n Nodes
#SBATCH -J freebayes    # sensible name for the job
#SBATCH --output=slurm_logs/freebayes_job_%%j.log
set -o nounset
set -o errexit
# min alt count Default = 0.2
# experimental-gls is default from march 02 2015.
#  --experimental-gls \\

module load freebayes/0.9.21
module load samtools/1.2

freebayes %s \\
   -f %s \\
   --bam-list %s \\
   --use-mapping-quality \\
   --min-mapping-quality 1 \\
   --min-alternate-count 2 \\
   --genotype-qualities \\
   --min-alternate-fraction 0.2 \\
   | vcffilter -f 'QUAL > 30' \\
   | bgzip  > %s_QUAL_30.vcf.gz \\
	&& tabix %s_QUAL_30.vcf.gz\n",
region, ref, argv$bamlist, vcf, vcf)

#cat(sbatch) # Test
if (!dir.exists("slurm_files")) dir.create("slurm_files")
cat(sbatch, file = sprintf("slurm_files/slurm.%s.sh", vcf))
system2("sbatch", sprintf("slurm_files/slurm.%s.sh", vcf))
