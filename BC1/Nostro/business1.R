# Import used libraries

library(readxl)
library(rgl)

# Remember to set the correct working directory!
# Import dataset

data <- read_excel("BankClients.xlsx")
data = data.frame(data)
head(data)
dim(data)
data = data[, -1]
colnames(data)

# Divide cathegorical and numerical variables

ctg = c("Gender", "Job", "Area", "CitySize", "FamilySize", "Investments")
ctg_id = c(which(colnames(data)==ctg[1]),
           which(colnames(data)==ctg[2]),
           which(colnames(data)==ctg[3]),
           which(colnames(data)==ctg[4]),
           which(colnames(data)==ctg[5]),
           which(colnames(data)==ctg[6])
)
num = colnames(data)[-ctg_id]
num_id = numeric(length(num))
for (i in 1:length(num))
{
  num_id[i] = which(colnames(data)==num[i])
}
d_num = data[, num_id]
head(d_num)

# Some data visualization

par(mfrow = c(1,2))
boxplot(d_num, col = "azure3", main="with age")

# Age variable is out of scale

boxplot(d_num[,-1], col = "orange", main = "without age")

# Rescale Age variable

par(mfrow = c(1,1))
boxplot(scale(d_num), col = "azure3", main ="rescaled dataset")

# Correlation plot to analyze the general behaviour
x11()
library(corrplot)
corrplot(cor(d_num), type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)
cor(d_num)


dim(d_num)
x11()
par(mfrow = c(2,3))
for (i in 1:6)
{
  hist(d_num[,i], main = colnames(d_num)[i], freq = FALSE)
}
x11()
par(mfrow = c(2,3))
for (i in 7:length(num))
{
  hist(d_num[,i], main = colnames(d_num)[i], freq = FALSE)
}



d_sc=data.frame(scale(data[,num_id]))
d_ctg=data[,ctg_id]
dnew=cbind(d_sc,d_ctg)



# PCA

pc.data <- princomp(scale(dnew), scores=T)
summary(pc.data)
load.data <- pc.data$loadings
x11()
par(mfcol = c(1,3))
for(i in 1:3) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))



data_reduced_scaled = dnew
layout(matrix(c(2,3,1,3),2,byrow=T))
plot(pc.data, las=2, main='Principal Components', ylim=c(0,7))
abline(h=1, col='blue')
barplot(sapply(as.data.frame(data_reduced_scaled),sd)^2, las=2, main='Original Variables', ylim=c(0,7), ylab='Variances')
plot(cumsum(pc.data$sde^2)/sum(pc.data$sde^2), type='b', axes=F, xlab='Number of components', ylab='Contribution to the total variance', ylim=c(0,1))
abline(h=1, col='blue')
abline(h=0.62, lty=2, col='blue')
box()
axis(2,at=0:10/10,labels=0:10/10)
axis(1,at=1:ncol(data_reduced_scaled),labels=1:ncol(data_reduced_scaled),las=2)
data_reduced_scaled = as.data.frame(data_reduced_scaled)

scores = pc.data$scores
par(mfrow=c(1,1))
plot(scores[,1], scores[,2], pch = 20, xlab="PC1", ylab="PC2")
plot3d(scores[,1], scores[,2], scores[,3])



# Hierarchical Clustering

dfNum.e <- dist(scores[,1:3], method='euclidean')
dfNum.es <- hclust(dfNum.e, method='single')
dfNum.ea <- hclust(dfNum.e, method='average')
dfNum.ec <- hclust(dfNum.e, method='complete')
dfNum.ew <- hclust(dfNum.e, method='ward.D2')

par(mfrow=c(1,4))
plot(dfNum.es, main='Euclidean Distance - Single Linkage', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
plot(dfNum.ec, main='Euclidean Distance - Complete Linkage', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
plot(dfNum.ea, main='Euclidean Distance - Average Linkage', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
plot(dfNum.ew, main='Euclidean Distance - Ward D2 Linkage', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')

cluster.ew.3 <- cutree(dfNum.ew, k=3)

par(mfrow=c(1,1))
plot(scores[,1], scores[,2], pch = 20, xlab="PC1", ylab="PC2", col=cluster.ew.3)
plot3d(scores[,1], scores[,2], scores[,3], col=cluster.ew.3)

feature = cluster.ew.3
num_clusters = 3

i1 = which(cluster.ew.3 == 1)
i2 = which(cluster.ew.3 == 2)
i3 = which(cluster.ew.3 == 3)
names = colnames(dnew)

table(cluster.ew.3)

library(corrplot)
corrplot(cor(dnew[i1,]), type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)


x11()
par(mfrow=c(2,4))
hist(data$Gender, freq=TRUE, main = "Gender", xlab = "")
hist(data$Job, freq=TRUE, main = "Job", xlab = "") 
hist(data$Area, freq=TRUE, main = "Area", xlab = "") 
hist(data$CitySize, freq=TRUE, main = "CitySize", xlab = "")
hist(data[i2,]$Gender, freq=TRUE, main = "Gender", xlab = "")
hist(data[i2,]$Job, freq=TRUE, main = "Job", xlab = "")
hist(data[i2,]$Area, freq=TRUE, main = "Area", xlab = "")
hist(data[i2,]$CitySize, freq=TRUE, main = "CitySize", xlab = "")

par(mfrow=c(2,3))
hist(data$FamilySize, freq=TRUE, main = "FamilySize", xlab = "") 
hist(data$Investments, freq=TRUE, main = "Investments", xlab = "")
hist(data$Age, main = "Age", xlab = "")
hist(data[i2,]$FamilySize, freq=TRUE, main = "FamilySize", xlab = "")
hist(data[i2,]$Investments, freq=TRUE, main = "Investments", xlab = "")
hist(data[i2,]$Age, main = "Age", xlab = "")

x11()
par(mfrow=c(2,4))
hist(data$Income, main = "Income", xlab = "")
hist(data$Wealth, main = "Wealth", xlab = "")
hist(data$Debt, main = "Debt", xlab = "")
hist(data$FinEdu, main = "FinEdu", xlab = "")
hist(data[i2,]$Income, main = "Income", xlab = "")
hist(data[i2,]$Wealth, main = "Wealth", xlab = "")
hist(data[i2,]$Debt, main = "Debt", xlab = "")
hist(data[i2,]$FinEdu, main = "FinEdu", xlab = "")

par(mfrow=c(2,4))
hist(data$Digital, main = "Digital", xlab = "")
hist(data$BankFriend, main = "BankFriend", xlab = "")
hist(data$LifeStyle, main = "LifeStyle", xlab = "")
hist(data$Saving, main = "Saving", xlab = "")
hist(data[i2,]$Digital, main = "Digital", xlab = "")
hist(data[i2,]$BankFriend, main = "BankFriend", xlab = "")
hist(data[i2,]$LifeStyle, main = "LifeStyle", xlab = "")
hist(data[i2,]$Saving, main = "Saving", xlab = "")


x11()
par(mfrow=c(2,4))
hist(data$Gender, freq=TRUE, main = "Gender", xlab = "")
hist(data$Job, freq=TRUE, main = "Job", xlab = "") 
hist(data$Area, freq=TRUE, main = "Area", xlab = "") 
hist(data$CitySize, freq=TRUE, main = "CitySize", xlab = "")
hist(data[i3,]$Gender, freq=TRUE, main = "Gender", xlab = "")
hist(data[i3,]$Job, freq=TRUE, main = "Job", xlab = "")
hist(data[i3,]$Area, freq=TRUE, main = "Area", xlab = "")
hist(data[i3,]$CitySize, freq=TRUE, main = "CitySize", xlab = "")

par(mfrow=c(2,3))
hist(data$FamilySize, freq=TRUE, main = "FamilySize", xlab = "") 
hist(data$Investments, freq=TRUE, main = "Investments", xlab = "")
hist(data$Age, main = "Age", xlab = "")
hist(data[i3,]$FamilySize, freq=TRUE, main = "FamilySize", xlab = "")
hist(data[i3,]$Investments, freq=TRUE, main = "Investments", xlab = "")
hist(data[i3,]$Age, main = "Age", xlab = "")


x11()
par(mfrow=c(2,4))
hist(data$Income, main = "Income", xlab = "")
hist(data$Wealth, main = "Wealth", xlab = "")
hist(data$Debt, main = "Debt", xlab = "")
hist(data$FinEdu, main = "FinEdu", xlab = "")
hist(data[i3,]$Income, main = "Income", xlab = "")
hist(data[i3,]$Wealth, main = "Wealth", xlab = "")
hist(data[i3,]$Debt, main = "Debt", xlab = "")
hist(data[i3,]$FinEdu, main = "FinEdu", xlab = "")


par(mfrow=c(2,4))
hist(data$Digital, main = "Digital", xlab = "")
hist(data$BankFriend, main = "BankFriend", xlab = "")
hist(data$LifeStyle, main = "LifeStyle", xlab = "")
hist(data$Saving, main = "Saving", xlab = "")
hist(data[i3,]$Digital, main = "Digital", xlab = "")
hist(data[i3,]$BankFriend, main = "BankFriend", xlab = "")
hist(data[i3,]$LifeStyle, main = "LifeStyle", xlab = "")
hist(data[i3,]$Saving, main = "Saving", xlab = "")

x11()
par(mfrow=c(2,4))
hist(data$Gender, freq=TRUE, main = "Gender", xlab = "")
hist(data$Job, freq=TRUE, main = "Job", xlab = "") 
hist(data$Area, freq=TRUE, main = "Area", xlab = "") 
hist(data$CitySize, freq=TRUE, main = "CitySize", xlab = "")
hist(data[i1,]$Gender, freq=TRUE, main = "Gender", xlab = "")
hist(data[i1,]$Job, freq=TRUE, main = "Job", xlab = "")
hist(data[i1,]$Area, freq=TRUE, main = "Area", xlab = "")
hist(data[i1,]$CitySize, freq=TRUE, main = "CitySize", xlab = "")

par(mfrow=c(2,3))
hist(data$FamilySize, freq=TRUE, main = "FamilySize", xlab = "") 
hist(data$Investments, freq=TRUE, main = "Investments", xlab = "")
hist(data$Age, main = "Age", xlab = "")
hist(data[i1,]$FamilySize, freq=TRUE, main = "FamilySize", xlab = "")
hist(data[i1,]$Investments, freq=TRUE, main = "Investments", xlab = "")
hist(data[i1,]$Age, main = "Age", xlab = "")





x11()
par(mfrow=c(2,4))
hist(data$Income, main = "Income", xlab = "")
hist(data$Wealth, main = "Wealth", xlab = "")
hist(data$Debt, main = "Debt", xlab = "")
hist(data$FinEdu, main = "FinEdu", xlab = "")


hist(data[i1,]$Income, main = "Income", xlab = "")
hist(data[i1,]$Wealth, main = "Wealth", xlab = "")
hist(data[i1,]$Debt, main = "Debt", xlab = "")
hist(data[i1,]$FinEdu, main = "FinEdu", xlab = "")

par(mfrow=c(2,4))
hist(data$Digital, main = "Digital", xlab = "")
hist(data$BankFriend, main = "BankFriend", xlab = "")
hist(data$LifeStyle, main = "LifeStyle", xlab = "")
hist(data$Saving, main = "Saving", xlab = "")
hist(data[i1,]$Digital, main = "Digital", xlab = "")
hist(data[i1,]$BankFriend, main = "BankFriend", xlab = "")
hist(data[i1,]$LifeStyle, main = "LifeStyle", xlab = "")
hist(data[i1,]$Saving, main = "Saving", xlab = "")

# pc_ <- princomp(scale(dnew[i1,]), scores=T)
# summary(pc_)
# load.data_ <- pc_$loadings
# scores_g1 = pc_$scores
# 
# library(fpc)
# 
# d = as.matrix(dist(scores_g1[,1:2], method='euclidean'))
# k = 200 # 100/150 works
# knee_plot = numeric(table(cluster.ew.3)[1])
# for (i in 1:table(cluster.ew.3)[1])
# {
#   d_i = as.numeric(sort(d[i,]))
#   knee_plot[i] = mean(d_i[1:k])
# }
# plot(sort(knee_plot), ylab = "")
# 
# set.seed(220)  # Setting seed
# Dbscan_cl <- dbscan(scores_g1[,1:4], eps = 1, MinPts = k)
# # Dbscan_cl
# # Dbscan_cl$cluster
# table(Dbscan_cl$cluster)
# 
# plot(scores[i1,1:2], col = "white", pch = 20)
# points(scores[i1,1:2])
# points(scores[i1,1:2], col = Dbscan_cl$cluster, pch = 20)
# 
# 
# d = as.matrix(dist(dnew[i1,-1], method='euclidean'))
# k = 150 # <= 90 100/150 works
# knee_plot = numeric(table(cluster.ew.3)[1])
# for (i in 1:table(cluster.ew.3)[1])
# {
#   d_i = as.numeric(sort(d[i,]))
#   knee_plot[i] = mean(d_i[1:k])
# }
# plot(sort(knee_plot), ylab="")
# 
# set.seed(29061999)
# Dbscan_cl <- dbscan(dnew[i1,-1], eps = 2.7, MinPts = k)
# table(Dbscan_cl$cluster)
# 
# plot3d(scores[i1,1:3], col = Dbscan_cl$cluster+1, pch = 20)
# 
# group1 = dnew[i1,]
# group1_glob = data[i1,]
# i11 = which(Dbscan_cl$cluster == 1)
# i12 = which(Dbscan_cl$cluster == 2)
# i13 = which(Dbscan_cl$cluster == 3)
# i14 = which(Dbscan_cl$cluster == 4)
# i15 = which(Dbscan_cl$cluster == 5)
# i16 = which(Dbscan_cl$cluster == 6)
#i10 = which(Dbscan_cl$cluster == 0)



#pc.data <- princomp(scale(group1), scores=T)
#summary(pc.data)
#load.data <- pc.data$loadings
#x11()
#par(mfcol = c(4,3))
#for(i in 1:11) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))
#x11()
#par(mfcol = c(1,3))
#for(i in 1:3) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))


