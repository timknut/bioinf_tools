#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo usage: $(basename $0) [vcf-file] [vcf-out]
    exit 0
fi


vcf=$1
vcfout=$2
java -Xmx4g -jar \
	 ~tikn/bioinf_tools/snpeff/snpEff/snpEff.jar ann \
	-c ~tikn/bioinf_tools/snpeff/snpEff/snpEff.config \
	-v UMD3.1.78 $vcf \
	-stats ${vcf}_summary.html \
	-o gatk \
	> $vcfout

