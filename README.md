bioinf_tools
============

Simple tools for working with sequence data at CIGENE.
### **Slurmtemp.py**
Command line tool for sending simple yet CPU itensive jobs to the CIGENE cluster.

*Usage*: `Slurmtemp.py "commands" [n threads as integer]`
type `Slurmtemp.py -h` for command line help.

*Example:*
The following bash command will reproduce the script below

`Slurmtemp.py "module load bamtools && bamtools merge $(for file in $(ls *RG.bam); do echo " -in "$file; done) -out outbam.merge.bam -forceCompression" 2`

```bash
#!/bin/bash -x
#SBATCH -J SlurmTemp
#SBATCH -N 1
#SBATCH -n 2
module load bamtools && bamtools merge $(for file in $(ls *RG.bam); do echo " -in "$file; done) -out outbam.merge.bam -forceCompression
```

###**get_flanking_seq**
Python and R implementations for fetching flanking sequences. Useful for SNP chip design.
R program should be run interactivly for now. Python script has usage instructions built in.

Run: `python GetFlankingSeq.py` for usage.
