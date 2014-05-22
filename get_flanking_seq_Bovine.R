# Load the BSgenome package and download the Btau6 reference sequence 
# For documentation see http://www.bioconductor.org/packages/release/bioc/html/BSgenome.html
source("http://bioconductor.org/biocLite.R")
biocLite("BSgenome")
biocLite("BSgenome.Btaurus.UCSC.bosTau6") #installs the cow genome (~750 MB download).
library('BSgenome.Btaurus.UCSC.bosTau6')

# Function to pull flanking sequence. Defaults to +/- 10 bp
getflank <- function(position, alleles="[N/N]", chr="chrN", offset=10) {
   leftflank  <- getSeq(Btaurus,chr,position-offset,position-1)
   rightflank <- getSeq(Btaurus,chr,position+1,position+offset)
   paste(leftflank,alleles,rightflank,sep="")
}

# Create an example from dbSNP flank from UMD 3.1
 
#   http://www.ncbi.nlm.nih.gov/sites/entrez?db=snp&cmd=search&term=rs1520218
getflank(54254, alleles="[C/A]")
