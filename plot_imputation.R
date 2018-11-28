#R/3.3.2
library(ggplot2)
library(grid)
df1<-read.table("imputation_summary.txt", sep="\t",header=T)
df<-as.data.frame(rbind(df1,df1))
df<-as.data.frame(rbind(df,df1))
df$cutoff<-NA
df[1:22,"cutoff"]<-"raw 23andme"
df[23:44,"cutoff"]<-"info>0.5"
df[45:66,"cutoff"]<-"info>0.8"
df[23:44,"original"]<-df[23:44,"X0.5cutoff"]
df[45:66,"original"]<-df[45:66,"X0.8cutoff"]

df<-df[,c(1,2,5)]
names(df)[2:3]<-c("num","cutoff")
# this will order the chr from 1 to 22
df$chr<-factor(substring(df$chr,4,6), levels=c(1:22))

#expand set the upper limit of y axis, switch="both" set the label to the bottom
pdf("number_variant_before_after.pdf")
ggplot(df, aes(x=chr, y=num, fill=cutoff))+geom_bar(stat="identity",position="dodge", colour="gray8")+
  expand_limits(y=2500000) +coord_cartesian(ylim=c(0,2500000))+
  ylab("number of variants")+xlab("Before and after imputation variants comparison")+
  theme(axis.text.x.bottom =element_blank(),axis.ticks.x=element_blank())+
  facet_grid(~chr, scales="free", space="free_x", switch = "both")
dev.off()


