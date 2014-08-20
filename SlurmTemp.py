#!/bin/env python
"""
Created on Fri Aug  8 04:20:47 2014

@author: Tim Knutsen
"""

import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("unix_command", help = '- command needs to be in "" if multiple arguments',
        type = str)
parser.add_argument("-n", "--cpus", help = "- number of CPUs as integer", type = int, default = 1)
parser.add_argument("-j", "--jobname", help = "Custom SLURM job name", type = str)
        # default = str("Slurmtemp"))

args = parser.parse_args()
template_text = """#!/bin/bash -x 
#SBATCH -J %s 
#SBATCH -N 1 
#SBATCH -n %i

%s""" % (args.jobname, args.cpus, args.unix_command)

if args.jobname:
    custom_SO = "#SBATCH --output=%s_%%j.out" % (args.jobname)
    with open("slurm_template", "w") as template:
        template.write(template_text + "\n" + custom_SO)
    print(template_text + "\n"+ custom_SO)	
else:
    with open("slurm_template", "w") as template:
       	template.write(template_text)
    print(template_text)

os.system("sbatch slurm_template")
#os.remove("slurm_template")
