#!/bin/env python

# Sends your unix command in a slurm script to Cluster
# usage: SlurmTemp.py "unix_command" [threads]

import os
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("unix_command", help = 'needs to be in "" if multiple arguments command', 
	type = str)
parser.add_argument("threads", type = int)

args = parser.parse_args()
args
#parser.parse_args()
#print(args.unix_command)

command = sys.argv[1]
threads = sys.argv[2] ## Use som version of sprintf to manipulate the #SBATCH -n string.
	
with open("slurm_template", "w") as template:
    template.write("#!/bin/bash -x\n#SBATCH -J SlurmTemp\n#SBATCH -N 1\n#SBATCH -n " + threads + "\n" + str(command) + "\n")

os.system("sbatch slurm_template")
os.remove("slurm_template")


