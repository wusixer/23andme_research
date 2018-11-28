import subprocess
import sys

CHR_NUM = str(sys.argv[1])
STEP = 5000000


def process_file(chr_name, start_pos, end_pos):
	cmd = "impute2 -known_haps_g  %s.phased.with.ref.haps -h  1000GP_Phase3_%s.hap.gz -l 1000GP_Phase3_%s.legend.gz -m genetic_map_%s_combined_b37.txt -int %d %d -buffer 250 -i result_%s_%d -o result_%s_%d" % (chr_name, chr_name, chr_name, chr_name, start_pos, end_pos, chr_name, start_pos, chr_name,start_pos)
	print(cmd)
	subprocess.call(cmd,shell=True)

def main():
	chr_name = "chr"+ CHR_NUM
	map_file = chr_name+".map"
	first = int(subprocess.check_output(["head", "-1", map_file]).decode('ASCII').strip().split('\t')[-1])
	last = int(subprocess.check_output(["tail", "-1", map_file]).decode('ASCII').strip().split('\t')[-1])
	while (first < last):
		process_file(chr_name, first, first + STEP)
		first += STEP

if __name__ == '__main__':
	main()



