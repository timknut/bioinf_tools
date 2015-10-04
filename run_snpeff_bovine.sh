#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo usage: $(basename $0) [vcf-file]
    exit 0
fi




vcf=$1
vcfout=`dirname $vcf`/`basename $vcf .vcf`.snpeff.vcf          # Output VCF file (annotated by GATK)
java -Xmx4g -jar \
	 ~tikn/bioinf_tools/snpeff/snpEff/snpEff.jar ann \
	-c ~tikn/bioinf_tools/snpeff/snpEff/snpEff.config \
	-v UMD3.1.78 $vcf \
	-stats ${vcf}_summary.html \
	-o gatk \
	> $vcfout

