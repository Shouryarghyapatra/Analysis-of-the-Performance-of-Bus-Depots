rm(list=ls())
library(readxl)
D=read_excel("C:/Users/hp/Downloads/PMPML dataset.xlsx")
#View(D)

summary(D) # some numeric variable turns out to be character
unique(D$`Total no. of breakdown`) # ---- making the variable as character
unique(D$`Kilometer per litre of Engine oil`) # - making the variable character

# missing value imputation
## spare vehicles, vehicles off road, total no of breakdown, breakdown rate, km per litre of oil, km per retreated tyres seems to have extreme values.knn can not be used.
cor_mat=cor(D[,-c(1,2)],use="pairwise.complete.obs")
#install.packages("corrplot")
library(corrplot)
par(mfrow=c(1,1))
corrplot(cor_mat,method="number",type="lower") # there is correlation between some variables so we can not use mice with reg

## let us go for missing value imputation using random forest
#install.packages("missForest")
library(missForest)
set.seed(123)
D_ran=missForest(as.matrix(D[,-c(1,2)]))
D1=cbind(D[,c(1,2)],D_ran$ximp)
#View(D1) 
summary(D1) # all missing values are removed
km_per_unit_fuel=D1$"Kms. per litre of diesel (KMPL)"+D1$"Kms. per Kg.of CNG (KMPG)"
D2=cbind(D1[-c(10,11,14)],km_per_unit_fuel)
Dnew=cbind(D2,D1$"Earning Per Vehicle Per day in Rs.") 
#View(Dnew)
names(Dnew)
colnames(Dnew)=c("Month","Depo","Avg. Spare Vehicles Per Day","Total Vehicles off Road Per Day","Effective Km Per Bus Per day","% of fleet utilisation (pmpml only)","Vehicle utilisation in kms. (Gross) (pmpml only)","Total no. of breakdown","Breakdown rate per 10000 Kms.","Kilometer per litre of Engine oil","Avg. kms.per retreaded tyres","km per unit fuel","Earning Per Vehicle Per day in Rs")
names(Dnew)

# data set for each depot
swar=subset(Dnew,Dnew$Depo=="Swargate")
ntw=subset(Dnew,Dnew$Depo=="N.T.Wadi")
koth=subset(Dnew,Dnew$Depo=="Kothrud")
kat=subset(Dnew,Dnew$Depo=="Katraj")
had=subset(Dnew,Dnew$Depo=="Hadapsar")
mark=subset(Dnew,Dnew$Depo=="Marketyard")
pstat=subset(Dnew,Dnew$Depo=="Pune Station")
nig=subset(Dnew,Dnew$Depo=="Nigadi")
bhos=subset(Dnew,Dnew$Depo=="Bhosari")
pimp=subset(Dnew,Dnew$Depo=="Pimpri")
bhek=subset(Dnew,Dnew$Depo=="Bhekrainagar")
shew=subset(Dnew,Dnew$Depo=="Shewalwadi")
bal=subset(Dnew,Dnew$Depo=="Balewadi")
df=rbind(swar,ntw,koth,kat,had,mark,pstat,nig,bhos,pimp,bhek,shew,bal) # final data set
df_scaled=scale(df[,-c(1,2)])
df=cbind(df[,c(1,2)],df_scaled)
summary(df) # since all variables are of different units and ranges are far apart, we need to scale them
#View(df)
# data set taking avg of 12 months for each depot
swar_mu=colMeans(df[1:12,-c(1,2)])
ntw_mu=colMeans(df[13:24,-c(1,2)])
koth_mu=colMeans(df[25:36,-c(1,2)])
kat_mu=colMeans(df[37:48,-c(1,2)])
had_mu=colMeans(df[49:60,-c(1,2)])
mark_mu=colMeans(df[61:72,-c(1,2)])
pstat_mu=colMeans(df[73:84,-c(1,2)])
nig_mu=colMeans(df[85:96,-c(1,2)])
bhos_mu=colMeans(df[97:108,-c(1,2)])
pimp_mu=colMeans(df[109:120,-c(1,2)])
bhek_mu=colMeans(df[121:132,-c(1,2)])
shew_mu=colMeans(df[133:144,-c(1,2)])
bal_mu=colMeans(df[145:156,-c(1,2)])
df_mu=rbind(swar_mu,ntw_mu,koth_mu,kat_mu,had_mu,mark_mu,pstat_mu,nig_mu,bhos_mu,pimp_mu,bhek_mu,shew_mu,bal_mu)
df_mu=data.frame(df_mu) # data set consisting row of avg of each variable for a depot across the year 2021
#View(df_mu) 
# quarterly data set 
q1=as.data.frame(rbind(colMeans(df[1:3,-c(1,2)]),colMeans(df[13:15,-c(1,2)]),colMeans(df[25:26,-c(1,2)]),colMeans(df[37:39,-c(1,2)]),colMeans(df[49:51,-c(1,2)]),colMeans(df[61:63,-c(1,2)]),colMeans(df[73:75,-c(1,2)]),colMeans(df[85:87,-c(1,2)]),colMeans(df[97:99,-c(1,2)]),colMeans(df[109:111,-c(1,2)]),colMeans(df[121:123,-c(1,2)]),colMeans(df[133:135,-c(1,2)]),colMeans(df[145:147,-c(1,2)])))
rownames(q1)=c("swar","ntw","koth","kat","had","mark","pstat","nig","bhos","pimp","bhek","shew","bal")
#View(q1) # data set for 1st quarter
q2=as.data.frame(rbind(colMeans(df[4:6,-c(1,2)]),colMeans(df[16:18,-c(1,2)]),colMeans(df[27:29,-c(1,2)]),colMeans(df[40:42,-c(1,2)]),colMeans(df[52:54,-c(1,2)]),colMeans(df[64:66,-c(1,2)]),colMeans(df[76:78,-c(1,2)]),colMeans(df[88:90,-c(1,2)]),colMeans(df[100:102,-c(1,2)]),colMeans(df[112:114,-c(1,2)]),colMeans(df[124:126,-c(1,2)]),colMeans(df[136:138,-c(1,2)]),colMeans(df[148:150,-c(1,2)])))
rownames(q2)=c("swar","ntw","koth","kat","had","mark","pstat","nig","bhos","pimp","bhek","shew","bal")
#View(q2) # data set for 2nd quarter
q3=as.data.frame(rbind(colMeans(df[7:9,-c(1,2)]),colMeans(df[19:21,-c(1,2)]),colMeans(df[30:32,-c(1,2)]),colMeans(df[43:45,-c(1,2)]),colMeans(df[55:57,-c(1,2)]),colMeans(df[67:69,-c(1,2)]),colMeans(df[79:81,-c(1,2)]),colMeans(df[91:93,-c(1,2)]),colMeans(df[103:105,-c(1,2)]),colMeans(df[115:117,-c(1,2)]),colMeans(df[127:129,-c(1,2)]),colMeans(df[139:141,-c(1,2)]),colMeans(df[151:153,-c(1,2)])))
rownames(q3)=c("swar","ntw","koth","kat","had","mark","pstat","nig","bhos","pimp","bhek","shew","bal")
#View(q3) # data set for 3rd quarter
q4=as.data.frame(rbind(colMeans(df[10:12,-c(1,2)]),colMeans(df[22:24,-c(1,2)]),colMeans(df[33:36,-c(1,2)]),colMeans(df[46:48,-c(1,2)]),colMeans(df[58:60,-c(1,2)]),colMeans(df[70:72,-c(1,2)]),colMeans(df[82:84,-c(1,2)]),colMeans(df[94:96,-c(1,2)]),colMeans(df[106:108,-c(1,2)]),colMeans(df[118:120,-c(1,2)]),colMeans(df[130:132,-c(1,2)]),colMeans(df[142:144,-c(1,2)]),colMeans(df[154:156,-c(1,2)])))
rownames(q4)=c("swar","ntw","koth","kat","had","mark","pstat","nig","bhos","pimp","bhek","shew","bal")
#View(q4) # data set for 1st quarter


#Q1) checking if there is any similarity among depots using cluster analysis
## based on utilization variables
par(mfrow=c(1,3))
u1=as.data.frame(df_mu[,c(3,4,5)])
#View(u1)
d1=dist(u1)
#View(d1)
h1=hclust(d1,method="ward.D2");plot(h1,main="utilization variables");rect.hclust(h1,k=3)
## based on performance variable
u2=as.data.frame(df_mu[,c(6,8,9,10)])
#View(u2)
d2=dist(u2)
h2=hclust(d2,method="ward.D2");plot(h2,main="performance variable");rect.hclust(h2,k=3)
## based on earning influence factors
u3=as.data.frame(df_mu[,c(1,2,5,6)])
#View(u3)
d3=dist(u3)
h3=hclust(d3,method="ward.D2");plot(h3,main="earning influence factors");rect.hclust(h3,k=3)

# Checking if these findings remain same quarterly
## based on utilization variables
d1=dist(q1[,c(3,4,5)]);d2=dist(q2[,c(3,4,5)]);d3=dist(q3[,c(3,4,5)]);d4=dist(q4[,c(3,4,5)])
h1=hclust(d1,method="ward.D2");h2=hclust(d2,method="ward.D2");h3=hclust(d3,method="ward.D2");h4=hclust(d4,method="ward.D2")
par(mfrow=c(2,2))
plot(h1,main="1st quarter");rect.hclust(h1,k=3)
plot(h2,main="2nd quarter");rect.hclust(h2,k=3)
plot(h3,main="3rd quarter");rect.hclust(h3,k=3)
plot(h4,main="4th quarter");rect.hclust(h4,k=3) # similarity is not consistent for all quarters

## based on performance variables
d1=dist(q1[,c(6,8,9,10)]);d2=dist(q2[,c(6,8,9,10)]);d3=dist(q3[,c(6,8,9,10)]);d4=dist(q4[,c(6,8,9,10)])
h1=hclust(d1,method="ward.D2");h2=hclust(d2,method="ward.D2");h3=hclust(d3,method="ward.D2");h4=hclust(d4,method="ward.D2")
par(mfrow=c(2,2))
plot(h1,main="1st quarter");rect.hclust(h1,k=3)
plot(h2,main="2nd quarter");rect.hclust(h2,k=3)
plot(h3,main="3rd quarter");rect.hclust(h3,k=3)
plot(h4,main="4th quarter");rect.hclust(h4,k=3) # similarity is not consistent for all quarters

## based on earning influence variables
d1=dist(q1[,c(1,2,5,6)]);d2=dist(q2[,c(1,2,5,6)]);d3=dist(q3[,c(1,2,5,6)]);d4=dist(q4[,c(1,2,5,6)])
h1=hclust(d1,method="ward.D2");h2=hclust(d2,method="ward.D2");h3=hclust(d3,method="ward.D2");h4=hclust(d4,method="ward.D2")
par(mfrow=c(2,2))
plot(h1,main="1st quarter");rect.hclust(h1,k=3)
plot(h2,main="2nd quarter");rect.hclust(h2,k=3)
plot(h3,main="3rd quarter");rect.hclust(h3,k=3)
plot(h4,main="4th quarter");rect.hclust(h4,k=3) # similarity is not consistent for all quarters

#Q3) performance of depots 
#install.packages("psych")
library(psych)
## based on utilization variables
par(mfrow=c(1,1))
pc1=pca(u1,nfactors=dim(u1)[2],rotate="none") # PCA 
var1=pc1$Vaccounted[2,];var1;barplot(pc1$Vaccounted[2,],main=" based on utilization variable",col="green") # 1st PC is explaining around 60% variability
pc1$loadings[,1] # composite utilization index 
                # fleet utilisation has less effect than other two and all of them have positive contribution in 1st PC
sc1=as.data.frame(pc1$scores) # scores based on 1st PC
library(dplyr)
u1=u1 %>%
  mutate(score_no_rot=(sc1$PC1*var1[1]+sc1$PC2*var1[2]))  # scoring of depots
u1=u1 %>%
  mutate(rank=dense_rank(desc(score_no_rot)))
View(u1) # ranking of depots
## based on performance variables
pc2=pca(u2,nfactors=dim(u2)[2],rotate="none") # PCA 
var2=pc2$Vaccounted[2,];var2;barplot(pc2$Vaccounted[2,],main="based on performance variable",col="green") # 1st PC is explaining around 40% variability
pc2$loadings[,1] # composite performance index 
                 # avg km per retreated tyre , km per lit of oil and total no of breakdown have more effect,effect of km per unit fuel is very less
sc2=as.data.frame(pc2$scores) # scores based on 1st PC
u2=u2[] %>%
  mutate(score_no_rot=sc2$PC1*var2[1]+sc2$PC2*var2[2])  # scoring of depots
u2=u2 %>%
  mutate(rank=dense_rank(desc(score_no_rot)))
View(u2) # ranking of depots

## based on earning influence variables
pc3=pca(u3,nfactors=dim(u3)[2],rotate="none") # PCA 
var3=pc3$Vaccounted[2,];var3;barplot(pc3$Vaccounted[2,],main="based on earning variables",col="green") # 1st PC is explaining around 60% variability
pc3$loadings[,1] # composite performance index 
                 # spare vehicles, vehicles off road, utilisation have very large influence
sc3=as.data.frame(pc3$scores) # scores
u3=u3 %>%
  mutate(score_no_rot=sc3$PC1*var3[1]+sc3$PC2*var3[2])  # scoring of depots
u3=u3 %>%
  mutate(rank=dense_rank(desc(score_no_rot)))
View(u3) # ranking of depots

## overall ranking in various quarters
pc_q1=pca(q1,nfactors=dim(q1)[2],rotate="none");pc_q2=pca(q2,nfactors=dim(q2)[2],rotate="none");pc_q3=pca(q3,nfactors=dim(q2)[2],rotate="none");pc_q4=pca(q4,nfactors=dim(q3)[2],rotate="none") # PCA for 4 quarters
sc_q1=as.data.frame(pc_q1$scores);sc_q2=as.data.frame(pc_q2$scores);sc_q3=as.data.frame(pc_q3$scores);sc_q4=as.data.frame(pc_q4$scores)
var_q1=pc_q1$Vaccounted[2,];var_q2=pc_q2$Vaccounted[2,];var_q3=pc_q3$Vaccounted[2,];var_q4=pc_q4$Vaccounted[2,]
s1=(sc_q1$PC1*var_q1[1]+sc_q1$PC2*var_q1[2]);s2=(sc_q2$PC1*var_q2[1]+sc_q2$PC2*var_q2[2]);s3=(sc_q3$PC1*var_q3[1]+sc_q3$PC2*var_q3[2]);s4=(sc_q4$PC1*var_q4[1]+sc_q4$PC2*var_q4[2])
Q1=quantile(s1,probs=c(0.25,0.5,0.75));Q2=quantile(s2,probs=c(0.25,0.5,0.75));Q3=quantile(s3,probs=c(0.25,0.5,0.75));Q4=quantile(s4,probs=c(0.25,0.5,0.75)) # quartiles for scores based of different performance variable
q1$Performance=c()
for(i in 1:13){
  if(s1[i]<=Q1[1]) q1$Performance[i]="low"
  if(s1[i]>Q1[1] & s1[i]<=Q1[3]) q1$Performance[i]="avg"
  if(s1[i]>Q1[3]) q1$Performance[i]="high"
}
View(q1)
q2$Performance=c()
for(i in 1:13){
  if(s2[i]<=Q2[1]) q2$Performance[i]="low"
  if(s2[i]>Q2[1] & s2[i]<=Q2[3]) q2$Performance[i]="avg"
  if(s2[i]>Q2[3]) q2$Performance[i]="high"
}
q3$Performance=c()
for(i in 1:13){
  if(s3[i]<=Q3[1]) q3$Performance[i]="low"
  if(s3[i]>Q3[1] & s3[i]<=Q3[3]) q3$Performance[i]="avg"
  if(s3[i]>Q3[3]) q3$Performance[i]="high"
}
q4$Performance=c()
for(i in 1:13){
  if(s4[i]<=Q4[1]) q4$Performance[i]="low"
  if(s4[i]>Q4[1] & s4[i]<=Q4[3]) q4$Performance[i]="avg"
  if(s4[i]>Q4[3]) q4$Performance[i]="high"
}
library(ggplot2)
ggplot(q1,mapping=aes(x=1:13,y=s1,col=Performance))+geom_point()+ggtitle("performance scores in 1st quarter")+geom_text(label=rownames(q1),check_overlap = T)+xlab("index")+ylab("scores")
ggplot(q2,mapping=aes(x=1:13,y=s2,col=Performance))+geom_point()+ggtitle("performance scores in 2nd quarter")+geom_text(label=rownames(q1),check_overlap = T)+xlab("index")+ylab("scores")
ggplot(q3,mapping=aes(x=1:13,y=s3,col=Performance))+geom_point()+ggtitle("performance scores in 3rd quarter")+geom_text(label=rownames(q1),check_overlap = T)+xlab("index")+ylab("scores")
ggplot(q4,mapping=aes(x=1:13,y=s4,col=Performance))+geom_point()+ggtitle("performance scores in 4th quarter")+geom_text(label=rownames(q1),check_overlap = T)+xlab("index")+ylab("scores")
## as we can see performance of each depot is changing in different quarters

#Q4) outlier detection
summary(q1)
par(mfrow=c(1,2))
boxplot(q1$`Kilometer per litre of Engine oil`,main="Kilometer per litre of Engine oil",col="red")
boxplot(q1$`Avg. kms.per retreaded tyres`,main="Avg. kms.per retreaded tyres",col="red")
summary(q2)
par(mfrow=c(1,3))
boxplot(q2$`Avg. Spare Vehicles Per Day`,main="Avg. Spare Vehicles Per Day",col="blue")
boxplot(q2$`Total no. of breakdown`,main="Total no. of breakdown",col="blue")
boxplot(q2$`Kilometer per litre of Engine oil`,main="Kilometer per litre of Engine oil",col="blue")
summary(q3)
boxplot(q3$`Avg. Spare Vehicles Per Day`,main="Avg. Spare Vehicles Per Day",col="pink")
boxplot(q3$`Breakdown rate per 10000 Kms.`,main="Breakdown rate per 10000 Kms.",col="pink")
boxplot(q3$`Avg. kms.per retreaded tyres`,main="Avg. kms.per retreaded tyres",col="pink")
summary(q4)
boxplot(q4$`Avg. Spare Vehicles Per Day`,main="Avg. Spare Vehicles Per Day",col="green")
boxplot(q4$`Total Vehicles off Road Per Day`,main="Total Vehicles off Road Per Day",col="green")

