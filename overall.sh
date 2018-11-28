### 0. delete the hash tags
tail -n +21 raw_genome.txt > my_genotype.txt
# distribution of my variants, single A, T, G, C are from mitochondria
cat my_genotype.txt |awk -F'\t' '{print $4}'|sort |uniq -c
  # 18274 --
   # 1256 A
 # 109072 AA
   # 9589 AC
  # 39439 AG
    # 319 AT
    # 945 C
 # 147475 CC
    # 481 CG
  # 39804 CT
     # 10 D
   # 1348 DD
     # 47 DI
    # 591 G
 # 146998 GG
   # 9614 GT
      # 3 I
   # 3440 II
   # 1170 T
 # 108594 TT

### 1. filter out the variants who has -- or insertion/deletion or from MT
awk -F'\t' '$4=="AA\r" || $4=="AC\r"|| $4=="AG\r" ||$4=="AT\r" || $4=="CC\r"|| $4=="CG\r"|| $4=="CT\r" || $4=="GG\r" || $4=="GT\r"|| $4=="TT\r"' my_genotype.txt  >filtered.my_genotype.txt

# remove X chr variants
awk '$2!="X"' filtered.my_genotype.txt >filtered.my_genotype.noX.txt

# remove variants with duplicated locations
awk '{print $2":"$3}' filtered.my_genotype.noX.txt >filtered.my_genotype.noX.id.txt
paste filtered.my_genotype.noX.id.txt filtered.my_genotype.noX.txt| sort -k3,3n -k4,4n  >filtered.my_genotype.noX.id.forfilter.txt
awk '!seen[$1]++' filtered.my_genotype.noX.id.forfilter.txt >filtered.my_genotype.noX.final.txt

### 2. convert txt to map file and ped file by chromosome
# format of map file, CHR RSID genetic_distance bp
for i in {1..22}; do echo $i; awk -v n=$i '$3==n{print}' filtered.my_genotype.noX.final.txt |awk '{print $3"\t"$2"\t"0"\t"$4}'  >chr$i.map; done

#split the genotype information by chromosome
for i in {1..22}; do echo $i; awk -v n=$i '$3==n{print}' filtered.my_genotype.noX.final.txt |awk '{print $2"\t"$3"\t"$4"\t"$5}'  >chr$i.txt; done

#convert genotype level txt to ped file by chr
# format FID IID PID MID SEX(1=male, 2=female), affection(0=unaffected, 1=affected), genotypes
for i in {1..22}; do echo $i; python 2.convert_to_ped.py chr$i.txt chr$i.ped;done
# remove genotype txt file by chr to save space
for i in {1..22}; do echo $i; rm chr$i.txt;done

#ERROR: You cannot phase less than 10 samples wihout using a reference panel!

# next step:download 1000G and start from chr1, no need to check since on 23andme website it says The genotypes displayed on the 23andMe website, including in the Raw Data feature, always refer to the positive (+) strand on build 37 of the human reference genome
#shapeit -check --input-ped test.ped test.map -M genetic_map_chr1_combined_b37.txt --input-ref 1000GP_Phase3_chr1.hap.gz 1000GP_Phase3_chr1.legend.gz 1000GP_Phase3.sample --output-log test.alignments
# it turned out lots of my snps are monomorphic, and they are filtered out
# solution: create a fake person with reference genome phenotype so that the alternative alleles are always there
for i in {1..22};
do
	echo $i
	echo "run shapeit to get miss alignment file"
	shapeit  -check --input-ped chr${i}.ped chr${i}.map -M genetic_map_chr${i}_combined_b37.txt --input-ref 1000GP_Phase3_chr${i}.hap.gz 1000GP_Phase3_chr${i}.legend.gz 1000GP_Phase3.sample  --include-grp group.list  

	echo "making drop list"
# drop the missing snps
	#tail -1 *log|awk -F' ' '{print $5}'|awk -F'=' '{print $2}' >chr$i.drop
	grep Missing *strand |awk '{print $3}'>>chr$i.drop
#add duplicated snp position to drop
	awk -F'\t' '{print $3}' *strand|sort|uniq -D|uniq >>chr$i.drop
	

	echo "adding fake person genotype"
	#run ambigusou script fake person script
	python 3.add_fake_sample_ped.py chr$i.ped chr$i.map

	rm *strand	
	rm *exclude

	echo "running final stage phasing shapeit"
	shapeit  --input-ped chr${i}.ped chr${i}.map -M genetic_map_chr${i}_combined_b37.txt --input-ref 1000GP_Phase3_chr${i}.hap.gz 1000GP_Phase3_chr${i}.legend.gz 1000GP_Phase3.sample  --include-grp group.list --no-mcmc  --exclude-snp chr${i}.drop -O chr${i}.phased.with.ref
	# ---------if there is another error about misalignment, exclude the new bp from exclude file that just generated ---------
	cat *exclude>>chr$i.drop
	shapeit  --input-ped chr${i}.ped chr${i}.map -M genetic_map_chr${i}_combined_b37.txt --input-ref 1000GP_Phase3_chr${i}.hap.gz 1000GP_Phase3_chr${i}.legend.gz 1000GP_Phase3.sample  --include-grp group.list --no-mcmc  --exclude-snp chr${i}.drop -O chr${i}.phased.with.ref
	# -------------------------------------
	echo "remove missing strand info"
	rm shapeit*

done
