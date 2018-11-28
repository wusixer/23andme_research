# concatenate all the chuncks by chr
for chr in {1..22}
do
	echo ${chr}
	cat `ls -v result*chr${chr}*[0-9]` >result_chr${chr}.txt
	# delete the repetitive header
	sed -i '/snp_id rs_id position a0 a1 exp_freq_a1 info certainty type info_type0 concord_type0 r2_type0/d' result_chr${chr}.txt
done

#concatenate all chr into 1
cat `ls -v result_chr*.txt` >my_genotype_after_imputation.txt
#get header of the final imputation file
echo 'snp_id rs_id position a0 a1 exp_freq_a1 info certainty type info_type0 concord_type0 r2_type0'>header

#add header back in
cat header my_genotype_after_imputation.txt >my_genotype_after_imputation.final.txt

# remove old file
rm my_genotype_after_imputation.txt
# to check if lines match
#cat `find -name 'result*chr22*[0-9]'|sort` |wc -l
#echo find -name 'result*chr${i}*[0-9]'|sort
