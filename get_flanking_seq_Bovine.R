source("http://bioconductor.org/biocLite.R")
if (!require(BSgenome.Btaurus.UCSC.bosTau6)) {
	message("Downloading genome")
	biocLite("BSgenome.Btaurus.UCSC.bosTau6")
}

# Function to pull flanking sequence. Defaults to +/- 10 bp
getflank <- function(position, alleles="[N/N]", chr="chrN", offset=100) {
	leftflank  <- getSeq(Btaurus,chr,position-offset,position-1)
	rightflank <- getSeq(Btaurus,chr,position+1,position+offset)
	paste(leftflank,alleles,rightflank,sep="")
}


## Make function so script can take list of snps and positions from vcf like file and give flanks.
parse_input <- function(flanklist) {
	if (is.character(flanklist)) {
		df <- read.table(flanklist, stringsAsFactors = FALSE)
		
	}
}

# Create an example from dbSNP flank from UMD 3.1

#   http://www.ncbi.nlm.nih.gov/sites/entrez?db=snp&cmd=search&term=rs1520218
getflank(54254, alleles="[C/A]", chr = "chr2", offset=100)
