library(readxl)
library(rgl)
BankClients <- read_excel("BankClients.xlsx")
BankClients = data.frame(BankClients)
head(BankClients)
dim(BankClients)
BankClients = BankClients[, -1]
colnames(BankClients)
CatVar = c("Gender", "Job", "Area", "CitySize", "FamilySize", "Investments")
CatVar_index = c(which(colnames(BankClients)==CatVar[1]),
                 which(colnames(BankClients)==CatVar[2]),
                 which(colnames(BankClients)==CatVar[3]),
                 which(colnames(BankClients)==CatVar[4]),
                 which(colnames(BankClients)==CatVar[5]),
                 which(colnames(BankClients)==CatVar[6])
                 )
NumVar = colnames(BankClients)[-CatVar_index]
length(NumVar) + length(CatVar) == dim(BankClients)[2]
NumVar_index = numeric(length(NumVar))
for (i in 1:length(NumVar))
{
  NumVar_index[i] = which(colnames(BankClients)==NumVar[i])
}
dfNum = BankClients[, NumVar_index]
head(dfNum)

########### Exploratory Data Analysis

# boxplot
x11()
par(mfrow = c(1,2))
boxplot(dfNum, col = "azure3", main="with age")
# temporarily remove age because it's horrible
boxplot(dfNum[,-1], col = "orange", main = "without age")

x11()
par(mfrow = c(1,1))
boxplot(scale(dfNum), col = "azure3", main ="rescaled dataset")

# there seem to be some similar boxplots: 
# lifestyle, luxury and debt:
x11()
plot(dfNum[,c(which(names(dfNum)=="LifeStyle"),which(names(dfNum)=="Luxury"),which(names(dfNum)=="Debt"))])
#x11()
#bagplot_matrix <- aplpack::bagplot.pairs(dfNum[,c(which(names(dfNum)=="LifeStyle"),which(names(dfNum)=="Luxury"),which(names(dfNum)=="Debt"))])

# income, wealth, ESG
x11()
plot(dfNum[,c(which(names(dfNum)=="Income"),which(names(dfNum)=="Wealth"),which(names(dfNum)=="ESG"))])
x11()
bagplot_matrix <- aplpack::bagplot.pairs(dfNum[,c(which(names(dfNum)=="Income"),which(names(dfNum)=="Wealth"),which(names(dfNum)=="ESG"))])
# actually ESG does not seem to be correlated

# pair plot of a subset
set.seed(123)
x11()
plot(dfNum[sample(1:dim(dfNum)[1], size = 1000),], pch = 20)

# correlation plot 
x11()
library(corrplot)
dfNum_temp = dfNum
dfNum_temp$Age = dfNum_temp$Age + rnorm(dim(dfNum_temp)[1], mean=0, sd=0.01)
corrplot(cor(dfNum_temp), type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)
cor(dfNum)


# density of features
dim(dfNum)
x11()
par(mfrow = c(2,3))
for (i in 1:6)
{
  hist(dfNum[,i], main = colnames(dfNum)[i], freq = FALSE)
}
x11()
par(mfrow = c(2,3))
for (i in 7:length(NumVar))
{
  hist(dfNum[,i], main = colnames(dfNum)[i], freq = FALSE)
}
# dataset has more "old" clients
# debt seems to be a mixture of normals

# pca
pc.data <- princomp(scale(dfNum), scores=T)
summary(pc.data)
load.data <- pc.data$loadings
x11()
par(mfcol = c(4,3))
for(i in 1:11) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))
x11()
par(mfcol = c(1,3))
for(i in 1:3) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))
# graphics.off()

data_reduced_scaled = scale(dfNum)
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

#load("C:/Users/giuli/OneDrive/Desktop/Polimi/APPLIED/AppliedStatTDE-master/Applied/mcshapiro.test.RData")
#mcshapiro.test(data.frame(PC1 = scores[,1], PC2 = scores[,2])) Non finisce di runnare

layout(matrix(c(1,1,3,3,5,5, 2,2,4,4,6,6), 2, 6, byrow = TRUE))
for (i in 1:3)
{
  shapiro.test(scores[,i])
  # layout(matrix(c(1,1,2,2)))
  string = paste("PC",toString(i), sep="")
  string = paste(string,  " - p.value shapiro: ", sep="")
  hist(scores[,i], breaks = 100, main = paste(string, 
                                              toString(shapiro.test(scores[,i])$p.value)),
                                  xlab="")
  qqnorm(scores[,i])
  qqline(scores[,i])
}

scores_dataset = data.frame(PC1 = scores[,1],
                            PC2 = scores[,2],
                            PC3 = scores[,3])

# kmeans with k = 3 and k = 4
set.seed(123)
km_3 = kmeans(scores_dataset, 3)
set.seed(123)
km_4 = kmeans(scores_dataset, 4)

plot3d(scores_dataset, col = km_3$cluster, main="3 clusters")
plot3d(scores_dataset, col = km_4$cluster, main="4 clusters")

# cluster analysis
#   TO DO

# understand the persona in each group
# BankClients
dfNum$km3 = km_3$cluster
dfNum$km4 = km_4$cluster
BankClients$km3 = km_3$cluster
BankClients$km4 = km_4$cluster

names = colnames(dfNum)

# for (i in 1:(length(names)-2))
# {
#   x11()
#   layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
#   hist(dfNum[which(dfNum$km4 == 1), i], main = names[i])
#   abline(v=mean(dfNum[,i]), col = "red")
#   hist(dfNum[which(dfNum$km4 == 2), i], main = names[i])
#   abline(v=mean(dfNum[,i]), col = "red")
#   hist(dfNum[which(dfNum$km4 == 3), i], main = names[i])
#   abline(v=mean(dfNum[,i]), col = "red")
#   hist(dfNum[which(dfNum$km4 == 4), i], main = names[i])
#   abline(v=mean(dfNum[,i]), col = "red")
# }
# 
# for (i in 1:(length(names)-2))
# {
#   x11()
#   layout(matrix(c(1,2,3), 1, 3, byrow = TRUE))
#   hist(dfNum[which(dfNum$km3 == 1), i], main = names[i])
#   abline(v=mean(dfNum[,i]), col = "red")
#   hist(dfNum[which(dfNum$km3 == 2), i], main = names[i])
#   abline(v=mean(dfNum[,i]), col = "red")
#   hist(dfNum[which(dfNum$km3 == 3), i], main = names[i])
#   abline(v=mean(dfNum[,i]), col = "red")
# }

# # 3 groups:
# for (j in c(3,6,9,11))
# {
# if (j==3)
#   inizio = 1
# if (j==6)
#   inizio = 4
# if (j==9)
#   inizio = 7
# if (j==11)
#   inizio = 10
# x11()
# layout(matrix(1:9, nrow = 3 , ncol = 3, byrow = TRUE))
# for (i in inizio:j)
# {
#   hist(dfNum[which(dfNum$km3 == 1), i], main = names[i], xlab="")
#   abline(v=mean(dfNum[,i]), col = "red")
#   hist(dfNum[which(dfNum$km3 == 2), i], main = names[i], xlab="")
#   abline(v=mean(dfNum[,i]), col = "red")
#   hist(dfNum[which(dfNum$km3 == 3), i], main = names[i], xlab="")
#   abline(v=mean(dfNum[,i]), col = "red")
# }
# }
# 
# # 4 groups:
# for (j in c(3,6,9,11))
# {
#   if (j==3)
#     inizio = 1
#   if (j==6)
#     inizio = 4
#   if (j==9)
#     inizio = 7
#   if (j==11)
#     inizio = 10
#   x11()
#   layout(matrix(1:12, nrow = 3 , ncol = 4, byrow = TRUE))
#   for (i in inizio:j)
#   {
#     hist(dfNum[which(dfNum$km4 == 1), i], main = names[i], xlab="")
#     abline(v=mean(dfNum[,i]), col = "red")
#     hist(dfNum[which(dfNum$km4 == 2), i], main = names[i], xlab="")
#     abline(v=mean(dfNum[,i]), col = "red")
#     hist(dfNum[which(dfNum$km4 == 3), i], main = names[i], xlab="")
#     abline(v=mean(dfNum[,i]), col = "red")
#     hist(dfNum[which(dfNum$km4 == 4), i], main = names[i], xlab="")
#     abline(v=mean(dfNum[,i]), col = "red")
#   }
# }

# source("C:/Users/Michele/Desktop/POLIMI - MAGISTRALE/FINTECH/ZENTI/BusinessCase1/plot_histograms.R")
# plot_histograms(dfNum, "km",3)
# plot_histograms(dfNum, "km",4)
# 
# ########################################################################
# ########################################################################
# ########################################################################
# 
# # try with hclust
# Age = dfNum$Age
# dfNum$Age = (dfNum$Age - min(dfNum$Age))/(max(dfNum$Age) - min(dfNum$Age))
# dfNum.e <- dist(dfNum, method='euclidean')
# dfNum.m <- dist(dfNum, method='manhattan')
# dfNum.c <- dist(dfNum, method='canberra')
# 
# dfNum.es <- hclust(dfNum.e, method='single')
# dfNum.ea <- hclust(dfNum.e, method='average')
# dfNum.ec <- hclust(dfNum.e, method='complete')
# dfNum.ew <- hclust(dfNum.e, method='ward.D2')
# 
# x11()
# par(mfrow=c(1,4))
# plot(dfNum.es, main='euclidean-single', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
# plot(dfNum.ec, main='euclidean-complete', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
# plot(dfNum.ea, main='euclidean-average', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
# plot(dfNum.ew, main='euclidean-ward d2', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
# 
# # proceed with ward d2 and average
# # inspect average:
# cluster.ea.3 <- cutree(dfNum.ea, k=3) # euclidean-single
# cluster.ea.4 <- cutree(dfNum.ea, k=4) # euclidean-single
# par(mfrow = c(1,2))
# plot(scores_dataset[,1:2], col = cluster.ea.3, pch=19, main = "average - 3 clusters")
# plot(scores_dataset[,1:2], col = cluster.ea.4, pch=19, main = "average - 4 clusters")
# par(mfrow=c(1,1))
# plot3d(scores_dataset, col = cluster.ea.3, pch=19, main = "average - 3 clusters")
# plot3d(scores_dataset, col = cluster.ea.4, pch=19, main = "average - 4 clusters")
# 
# # inspect average:
# cluster.ew.3 <- cutree(dfNum.ew, k=3) # euclidean-single
# cluster.ew.4 <- cutree(dfNum.ew, k=4) # euclidean-single
# par(mfrow = c(1,2))
# plot(scores_dataset[,1:2], col = cluster.ew.3, pch=19, main = "Ward D2 - 3 clusters")
# plot(scores_dataset[,1:2], col = cluster.ew.4, pch=19, main = "Ward D2 - 4 clusters")
# par(mfrow=c(1,1))
# plot3d(scores_dataset, col = cluster.ew.3, pch=19, main = "Ward D2 - 3 clusters")
# plot3d(scores_dataset, col = cluster.ew.4, pch=19, main = "Ward D2 - 4 clusters")
# 
# dfNum$ward3 = cluster.ew.3
# dfNum$ward4 = cluster.ew.4
# dfNum$average3 = cluster.ea.3
# dfNum$average4 = cluster.ea.4
# 
# BankClients$ward3 = cluster.ew.3
# BankClients$ward4 = cluster.ew.4
# BankClients$average3 = cluster.ea.3
# BankClients$average4 = cluster.ea.4
# 
# 
# # they seem to be equivalent, in 2D average seems better, but in 3d
# # the winner seems to be Ward D2
# 
# source("C:/Users/Michele/Desktop/POLIMI - MAGISTRALE/FINTECH/ZENTI/BusinessCase1/plot_histograms.R")
# plot_histograms(dfNum, "ward",3)
# 
# # library(Rtsne)
# # set.seed(42) # Sets seed for reproducibility
# # tsne_out <- Rtsne(as.matrix(dfNum))
# # plot(tsne_out$Y,asp=1)
# 
# i1 = which(cluster.ew.3 == 1)
# i2 = which(cluster.ew.3 == 2)
# i3 = which(cluster.ew.3 == 3)
# 
# data1 = BankClients[i1,]
# data2 = BankClients[i2,]
# data3 = BankClients[i3,]
# 
# # group 2 wrt categorical CatVar
# hist(data2$Gender)
# plot(data2)
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# # group 2
# 
# pc.data <- princomp(dfNum[i2,2:11], scores=T)
# summary(pc.data)
# load.data <- pc.data$loadings
# x11()
# par(mfcol = c(4,3))
# for(i in 1:11) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))
# x11()
# par(mfcol = c(1,3))
# for(i in 1:3) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))
# # graphics.off()
# 
# data_reduced_scaled = scale(dfNum)
# layout(matrix(c(2,3,1,3),2,byrow=T))
# plot(pc.data, las=2, main='Principal Components', ylim=c(0,7))
# abline(h=1, col='blue')
# barplot(sapply(as.data.frame(data_reduced_scaled),sd)^2, las=2, main='Original Variables', ylim=c(0,7), ylab='Variances')
# plot(cumsum(pc.data$sde^2)/sum(pc.data$sde^2), type='b', axes=F, xlab='Number of components', ylab='Contribution to the total variance', ylim=c(0,1))
# abline(h=1, col='blue')
# abline(h=0.9, lty=2, col='blue')
# box()
# axis(2,at=0:10/10,labels=0:10/10)
# axis(1,at=1:ncol(data_reduced_scaled),labels=1:ncol(data_reduced_scaled),las=2)
# data_reduced_scaled = as.data.frame(data_reduced_scaled)
# 
# scores = pc.data$scores
# par(mfrow=c(1,1))
# plot(scores[,1], scores[,2], pch = 20, xlab="PC1", ylab="PC2")
# plot3d(scores[,1], scores[,2], scores[,3])
# 
# dfNum.e <- dist(dfNum[i2,2:11], method='euclidean')
# 
# dfNum.es <- hclust(dfNum.e, method='single')
# dfNum.ea <- hclust(dfNum.e, method='average')
# dfNum.ec <- hclust(dfNum.e, method='complete')
# dfNum.ew <- hclust(dfNum.e, method='ward.D2')
# 
# x11()
# par(mfrow=c(1,4))
# plot(dfNum.es, main='euclidean-single', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
# plot(dfNum.ec, main='euclidean-complete', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
# plot(dfNum.ea, main='euclidean-average', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
# plot(dfNum.ew, main='euclidean-ward d2', hang=-0.1, xlab='', labels=F, cex=0.6, sub='')
# 
# cluster.ew.2 <- cutree(dfNum.ew, k=3)
# plot(scores[,1], scores[,2], col = cluster.ew.2, pch = 20)
# plot3d(scores[,1], scores[,2], scores[,3], col = cluster.ew.2, pch = 20)
# 
# par(mfrow = c(1,3))
# i = 8
# data = dfNum[i2,]
# hist(data[which(cluster.ew.2==1), i],main=names(dfNum)[i])
# abline(v=mean(data[,i]), col = "red")
# abline(v=mean(data[which(cluster.ew.2==2), i]), col="blue")
# hist(data[which(cluster.ew.2==2), i],main=names(dfNum)[i])
# abline(v=mean(data[,i]), col = "red")
# abline(v=mean(data[which(cluster.ew.2==2), i]), col="blue")
# hist(data[which(cluster.ew.2==3), i],main=names(dfNum)[i])
# abline(v=mean(data[,i]), col = "red")
# abline(v=mean(data[which(cluster.ew.2==2), i]), col="blue")
# 
# 
