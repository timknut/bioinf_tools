bioinf_tools
============

Simple tools for working with sequence data at CIGENE.

### **Slurmtemp.py**
Command line tool for sending simple yet CPU itensive jobs to the CIGENE cluster.

*Usage*: 
```bash
Slurmtemp.py "grep 'pattern' huge_file.txt"
```
###**get_flanking_seq**
Python and R implementations for fetching flanking sequences. Useful for SNP chip design.
R program should be run interactivly for now. Python script has usage instructions built in.

Run: `python GetFlankingSeq.py`for usage.
