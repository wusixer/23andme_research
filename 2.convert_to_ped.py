import numpy as np
import pandas as pd
import sys

input=sys.argv[1]
output=sys.argv[2]
#input file format is: rsid, chr, bp, genotype


# read in file
with open(input,'r') as file:
	genotype=file.readlines()

# ped file format FID IID PID MID SEX(1=male, 2=female), affection(0=unaffected, 1=affected), genotypes
ped='0\t0\t0\t0\t2\t0\t'

for line in genotype:
	geno = list(line.strip('\n').split('\t')[3])
	ped += '\t'.join(geno)+'\t'

with open(output, "w") as ped_output:
	    ped_output.write(ped)
