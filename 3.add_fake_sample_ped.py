import numpy as np
import pandas as pd
import sys
import glob

input_ped=sys.argv[1]
map_directionary=sys.argv[2]  # this is the file that is in chr$i.map format
right_strand_info=glob.glob('*.strand')[0]

# add another fake sample to line 2 with alternative genotype there
#  with open(input_ped,"r+") as ped:
#  for line in ped:
#  ped.write('\n'+line)

# make a dictorionay to chr map file
map_dict={}

line_number = 1
with open(map_directionary,"r") as chr_map_dict:
	for line in chr_map_dict:
		pos=line.strip('\n').split('\t')[3]
		map_dict[pos] = line_number
		line_number += 1

ped_lines=[]
with open(input_ped,"r") as ped:
	ped_line=ped.readline().strip('\n').split('\t')

# open shapeit error file *snp.strand which has in the infor of current homozygous and alternative
# use that information to filp the fake person's genotype
with open(right_strand_info,"r") as right_info:
	n = 0
	for line in right_info:
		n += 1
		if n == 1:
			continue
		if line.strip('\n').split('\t')[0]=="Strand":
			pos=line.strip('\n').split('\t')[2]
			a1_old=line.strip('\n').split('\t')[4]
			a2_old=line.strip('\n').split('\t')[5]
			a1=line.strip('\n').split('\t')[8]
			a2=line.strip('\n').split('\t')[9]
			line_number=map_dict[pos]
			# use line_number in map file to find the column number in ped file
			col_number=6+2*(line_number-1)
			if a1_old==a1 or a2_old==a2:  # this means the problem is strand mismatch
				ped_line[col_number]=a1
				ped_line[col_number+1]=a2
			else: # this means the problem is nothing match for the reference
				ped_line[col_number]=='0'
				ped_line[col_number+1]='0'
		else: # this means the variant is missing in reference
			continue
#change the famlily ids for the fake person
for col in range(4):
	ped_line[col]="1"
	
with open(input_ped, "a+") as ped:
	ped.writelines('\n'+'\t'.join(ped_line))





