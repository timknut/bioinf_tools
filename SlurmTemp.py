#!/bin/env python

# Sends your unix command in a slurm script to Cluster
# usage: SlurmTemp.py "unix_command" [threads]

import os
import sys

command = sys.argv[1]
threads = sys.argv[2] ## Use som version of sprintf to manipulate the #SBATCH -n string.
	
with open("slurm_template", "w") as template:
    template.write("#!/bin/bash -x\n#SBATCH -J SlurmTemp\n#SBATCH -N 1\n#SBATCH -n " + threads + "\n" + str(command) + "\n")

os.system("sbatch slurm_template")
os.remove("slurm_template")

#template = open("slurm_template", "w")
#template.write("#!/bin/bash -x\n#SBATCH -J LEECH\n#SBATCH -N 1\n#SBATCH -n 1\n" + str(command) + "\n")
#template.close()
#os.system("sbatch slurm_template")
#os.remove("slurm_template")
