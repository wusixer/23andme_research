library(ggplot2)
library(data.table)
df<-fread("my_genotype_after_imputation.final.txt",header=T, data.table=F)

df<-df[,c(6,7,8)]
df$chr<-NA
# get the number of variants on a chr
system('wc -l `ls -v result_chr*.txt`>chr_num.txt')
chr_num<-fread("chr_num.txt",header=F, data.table=F)
# assign chr to the dataframe
chr=1
start_pos=1
for (chr_length in chr_num$V1[1:22]){
        end_pos=start_pos+chr_length
        print(paste0("----chr",chr,"---"))
        print(start_pos)
        print(end_pos)
        df[c(start_pos:end_pos),"chr"]<-chr
        chr=chr+1
        start_pos=chr_length+start_pos
}

fwrite(df,"all_chr_imputation_score.txt",quote=F)
# sample 
#chr<-unlist(lapply(strsplit(df[,2],split=":"),"[",1))
pdf("imputation_quality_info_by_chr.pdf")
ggplot(df, aes(x=info)) + 
  geom_density()+facet_wrap(~as.factor(chr), ncol=2)
  #geom_vline(aes(xintercept=mean(certainty)),
                        #color="blue", linetype="dashed", size=1)

dev.off()

# use info score 0.5 as cut off
df1<-df[df$info>0.5,]
fwrite(df1,"all_chr_0.5above_imputation_score.txt",quote=F)


