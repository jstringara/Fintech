graphics.off()
dfNum = dfNum[,c(-12,-13)]
BankClients = BankClients[,c(-18,-19)]
pc.data <- princomp(scale(dfNum), scores=T)
load.data <- pc.data$loadings
x11()
par(mfcol = c(1,3))
for(i in 1:3) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))
# graphics.off()

layout(matrix(c(2,3,1,3),2,byrow=T))
plot(pc.data, las=2, main='Principal Components', ylim=c(0,7))
abline(h=1, col='blue')
barplot(sapply(as.data.frame(data_reduced_scaled),sd)^2, las=2, main='Original Variables', ylim=c(0,7), ylab='Variances')
plot(cumsum(pc.data$sde^2)/sum(pc.data$sde^2), type='b', axes=F, xlab='Number of components', ylab='Contribution to the total variance', ylim=c(0,1))
abline(h=1, col='blue')
abline(h=0.9, lty=2, col='blue')
box()
axis(2,at=0:10/10,labels=0:10/10)
axis(1,at=1:ncol(data_reduced_scaled),labels=1:ncol(data_reduced_scaled),las=2)

scores = pc.data$scores
par(mfrow=c(1,1))
plot(scores[,1], scores[,2], pch = 20, xlab="PC1", ylab="PC2")
plot3d(scores[,1], scores[,2], scores[,3])

# hclust
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

for (j in c(3,6,9,11))
{
  if (j==3)
    inizio = 1
  if (j==6)
    inizio = 4
  if (j==9)
    inizio = 7
  if (j==11)
    inizio = 10
  x11()
  ncol = 3
  massimo = 9
  if (num_clusters==4)
  {
    ncol = 4
    massimo = 12
  }
  layout(matrix(1:massimo, nrow = 3 , ncol = ncol, byrow = TRUE))
  for (i in inizio:j)
  {
    hist(dfNum[which(feature == 1), i], main = names[i], xlab="")
    abline(v=mean(dfNum[,i]), col = "red")
    abline(v=mean(dfNum[i1,i]), col = "blue")
    hist(dfNum[which(feature == 2), i], main = names[i], xlab="")
    abline(v=mean(dfNum[,i]), col = "red")
    abline(v=mean(dfNum[i2,i]), col = "blue")
    hist(dfNum[which(feature == 3), i], main = names[i], xlab="")
    abline(v=mean(dfNum[,i]), col = "red")
    abline(v=mean(dfNum[i3,i]), col = "blue")
    if(num_clusters==4)
    {  hist(dfNum[which(feature == 4), i], main = names[i], xlab="")
      abline(v=mean(dfNum[,i]), col = "red")
    }
  }
}

{par(mfrow=c(1,1))
i=8
hist(dfNum[i1,i], main=names[i], xlab="")
abline(v=mean(dfNum[,i]), col = "red")
abline(v=mean(dfNum[i1,i]), col = "blue")
}

table(cluster.ew.3)

# now we try to work on the first group and divide it even more

i1 = which(cluster.ew.3 == 1)
i2 = which(cluster.ew.3 == 2)
i3 = which(cluster.ew.3 == 3)

graphics.off()
library(corrplot)
corrplot(cor(dfNum[i1,]), type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)


# look at global categorical variables
hist(BankClients$Gender, freq=TRUE, main = "Gender", xlab = "")
hist(BankClients$Job, freq=TRUE, main = "Job", xlab = "") # Imbalanced
hist(BankClients$Area, freq=TRUE, main = "Area", xlab = "") # Imbalanced
hist(BankClients$CitySize, freq=TRUE, main = "CitySize", xlab = "")
hist(BankClients$FamilySize, freq=TRUE, main = "FamilySize", xlab = "") # Imbalanced
hist(BankClients$Investments, freq=TRUE, main = "Investments", xlab = "")

# Checking cluster 1

hist(BankClients[i1,]$Gender, freq=TRUE, main = "Gender", xlab = "")
hist(BankClients[i1,]$Job, freq=TRUE, main = "Job", xlab = "")
# mostly impiegato/operaio
hist(BankClients[i1,]$Area, freq=TRUE, main = "Area", xlab = "")
# mostly nord
hist(BankClients[i1,]$CitySize, freq=TRUE, main = "CitySize", xlab = "")
# living in medie/piccole dimensione
hist(BankClients[i1,]$FamilySize, freq=TRUE, main = "FamilySize", xlab = "")
hist(BankClients[i1,]$Investments, freq=TRUE, main = "Investments", xlab = "")
# mostly capital accumulation


pc_ <- princomp(scale(dfNum[i1,]), scores=T)
summary(pc_)
load.data_ <- pc_$loadings
scores_g1 = pc_$scores

library(fpc)

d = as.matrix(dist(scores_g1[,1:2], method='euclidean'))
k = 200 # 100/150 works
knee_plot = numeric(table(cluster.ew.3)[1])
for (i in 1:table(cluster.ew.3)[1])
{
  d_i = as.numeric(sort(d[i,]))
  knee_plot[i] = mean(d_i[1:k])
}
plot(sort(knee_plot), ylab = "")

set.seed(220)  # Setting seed
Dbscan_cl <- dbscan(scores_g1[,1:4], eps = 1.46, MinPts = k)
# Dbscan_cl
# Dbscan_cl$cluster
table(Dbscan_cl$cluster)

plot(scores[i1,1:2], col = "white", pch = 20)
points(scores[i1,1:2])
points(scores[i1,1:2], col = Dbscan_cl$cluster, pch = 20)


d = as.matrix(dist(dfNum[i1,-1], method='euclidean'))
k = 150 # <= 90 100/150 works
knee_plot = numeric(table(cluster.ew.3)[1])
for (i in 1:table(cluster.ew.3)[1])
{
  d_i = as.numeric(sort(d[i,]))
  knee_plot[i] = mean(d_i[1:k])
}
plot(sort(knee_plot), ylab="")

set.seed(220)  # Setting seed
Dbscan_cl <- dbscan(dfNum[i1,-1], eps = 0.6, MinPts = k)
# Dbscan_cl
# Dbscan_cl$cluster
table(Dbscan_cl$cluster)

# plot(scores[i1,1:2], col = "white", pch = 20)
# points(scores[i1,1:2])
plot3d(scores[i1,1:3], col = Dbscan_cl$cluster+1, pch = 20)

group1 = dfNum[i1,]
group1_glob = BankClients[i1,]
i11 = which(Dbscan_cl$cluster == 1)
i12 = which(Dbscan_cl$cluster == 2)
i13 = which(Dbscan_cl$cluster == 3)
i14 = which(Dbscan_cl$cluster == 4)
i15 = which(Dbscan_cl$cluster == 5)
i16 = which(Dbscan_cl$cluster == 6)
i10 = which(Dbscan_cl$cluster == 0)

#x11(height=30, width=40)
#plot(group1, col = Dbscan_cl$cluster)

pc.data <- princomp(scale(group1), scores=T)
summary(pc.data)
load.data <- pc.data$loadings
x11()
par(mfcol = c(4,3))
for(i in 1:11) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))
x11()
par(mfcol = c(1,3))
for(i in 1:3) barplot(load.data[,i], ylim = c(-1, 1), main=paste("PC",i))
