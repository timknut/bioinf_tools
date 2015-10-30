#!/usr/bin/env Rscript
.libPaths(c( .libPaths(), "/mnt/users/tikn/R/x86_64-unknown-linux-gnu-library/3.2")) # Orion R
library(argparser, quietly=TRUE)
library(magrittr, quietly=TRUE)

 # Create a parser
p <- arg_parser("Run freebayes on a list of bam files. Region is optional")

 # Add command line arguments
p <- add_argument(p, "bamlist", help="list of bamfiles. One per line", type="character")
p <- add_argument(p, "reference", help="Reference file in Fasta format", type = "character")#, default=0)
p <- add_argument(p, "--out", help="Out prefix", type = "character")#, default=0)
p <- add_argument(p, "--region", help="format: <chrom>:<start_position>-<end_position>",
						type = "character", default = NULL)

# Parse the command line arguments
argv <- parse_args(p)

vcf <- sprintf("%s.vcf.gz", argv$out)
cat (vcf, "\n")
ref <- argv$reference

## Resolve region thing by having a if statement
if (is.null(argv$region)) {
	hash <- "#"
	region <- "no region specified"
} else {
	hash <- ""
	region <- argv$region
}

# make sbatch script
## Remember to count up % and so on..
## Alternatively use cat
sbatch <- sprintf(
"
#!/bin/bash
#SBATCH -n 1            # -n cores
#SBATCH -N 1            # -n Nodes
#SBATCH -J freebayes    # sensible name for the job
#SBATCH --output=freebayes_job_%%j.log
set -o nounset
set -o errexit

module load freebayes/0.9.21

freebayes \\
%s --region %s \\
   -f %s \\
   --bam-list %s \\
   --use-mapping-quality \\
   --min-mapping-quality 1 \\
   --min-alternate-count 2 \\ # Default 0.2
   --genotype-qualities \\
   --experimental-gls \\ # Is default from march 02 2015.
   --min-alternate-fraction 0.2 \\ # 0.2 is default
#   --variant-input $dbsnp \\
   | vcffilter -f 'QUAL > 30' \\
   | bgzip  > %s_QUAL_30.vcf",hash, region, ref, argv$bamlist, vcf)
cat(sbatch, file = sprintf("%s_freebayes.sh", vcf))
