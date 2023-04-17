library(mvtnorm)
library(plot3D)
library(rgl)
tourists <- read.csv('EWS.csv', header=T)
head(tourists)

tourists.label <- tourists[,1:2]
tourists <- tourists[,-(1:2)]
heatmap(cor(tourists))
n <- dim(tourists)[1]
p <- dim(tourists)[2]

# Boxplot
x11()
par(mar=rep(8,4))
boxplot(tourists, las=2, col='gold')

# We observe that the variability of the number of nights in 3,4 stars hotels and residences
# is higher than that of the others. This may influence the PCA

# Note: PCA is not about the mean, it is about the variability
x11()
par(mar=rep(8,4))
boxplot(scale(x=tourists,center = T, scale=T), las=2, col='gold')

# We perform the PCA on original data
pc.tourists <- princomp(tourists, scores=T)
pc.tourists
summary(pc.tourists)

# To obtain the rows of the summary:
# standard deviation of the components
pc.tourists$sd
# proportion of variance explained by each PC
pc.tourists$sd^2/sum(pc.tourists$sd^2)
# cumulative proportion of explained variance
cumsum(pc.tourists$sd^2)/sum(pc.tourists$sd^2)

# loadings (recall: coefficients of the linear combination of the original 
#           variables that defines each principal component)

load.tour <- pc.tourists$loadings
load.tour

load.tour[,1:3]

# graphical representation of the loadings of the first six principal components
x11()
par(mfcol = c(4,2))
for(i in 1:8) barplot(load.tour[,i], ylim = c(-1, 1), main=paste("PC",i))

x11()
par(mfrow = c(3,1))
for(i in 1:3) barplot(load.tour[,i], ylim = c(-1, 1))

# Interpretation of the loadings:
# First PCs: weighted average of the number of nights in 3,4 stars hotel and residences
# Second PCs: contrast between the number of nights in 3 and 4 stars hotel
# Third PC: residences

# The loadings reflect the previous observation: the first 3 PCs are 
# driven by the variables displaying the highest variability

# Explained variance
x11()
layout(matrix(c(2,3,1,3),2,byrow=T))
plot(pc.tourists, las=2, main='Principal components', ylim=c(0,4.5e7))
barplot(sapply(tourists,sd)^2, las=2, main='Original Variables', ylim=c(0,4.5e7), ylab='Variances')
plot(cumsum(pc.tourists$sd^2)/sum(pc.tourists$sd^2), type='b', axes=F, xlab='number of components', 
     ylab='contribution to the total variance', ylim=c(0,1))
abline(h=1, col='blue')
abline(h=0.8, lty=2, col='blue')
box()
axis(2,at=0:10/10,labels=0:10/10)
axis(1,at=1:ncol(tourists),labels=1:ncol(tourists),las=2)

# The first PC explains more than 98% of the total variability. 
# This is due to the masking effect of those 3 variables over the others

##### Principal component analysis of the dataset 'tourists',
##### but on the standardized variables

##### Principal component analysis of the dataset 'tourists',
##### but on the standardized variables

# We compute the standardized variables
tourists.sd <- scale(tourists)
tourists.sd <- data.frame(tourists.sd)

head(tourists.sd)

pc.tourists <- princomp(tourists.sd, scores=T)
pc.tourists
summary(pc.tourists)

# Explained variance
x11()
layout(matrix(c(2,3,1,3),2,byrow=T))
plot(pc.tourists, las=2, main='Principal Components', ylim=c(0,7))
abline(h=1, col='blue')
barplot(sapply(tourists.sd,sd)^2, las=2, main='Original Variables', ylim=c(0,7), ylab='Variances')
plot(cumsum(pc.tourists$sde^2)/sum(pc.tourists$sde^2), type='b', axes=F, xlab='Number of components', ylab='Contribution to the total variance', ylim=c(0,1))
box()
axis(2,at=0:10/10,labels=0:10/10)
axis(1,at=1:ncol(tourists.sd),labels=1:ncol(tourists.sd),las=2)

# If we wanted to perform dimensionality reduction, we could keep
# 1 or 2 PCs

# loadings
load.tour <- pc.tourists$loadings
load.tour

x11()
par(mar = c(2,2,2,1), mfrow=c(3,1))
for(i in 1:3)barplot(load.tour[,i], ylim = c(-1, 1), main=paste('Loadings PC ',i,sep=''))

# Interpretation of the loadings:
# In this case, the first PC represents an average of the number of nights spent in 
# all the types of hotels and residences, taken with very similar weights.
# The sencond PC contrasts the more expensive solutions (4,5 stars hotels and residences)
# against the cheap solutions (1,2 stars hotels and B&B)

# High PC1: general high flow of tourists
# Low PC1: general low flow of tourists 
# High PC2: high flow for expensive solutions, low flow for cheap solutions
# Low PC2: low flow for expensive solutions, high flow for cheap solutions

# scores
scores.tourists <- pc.tourists$scores
scores.tourists

x11()
plot(scores.tourists[,1:2], col=tourists.label$Y+1)
abline(h=0, v=0, lty=2)
open3
plot3d(scores.tourists[,1:3],col=tourists.label$Y+2)
x11()
layout(matrix(c(1,2),2))
boxplot(tourists.sd, las=2, col='gold', main='Standardized variables')
scores.tourists <- data.frame(scores.tourists)
boxplot(scores.tourists, las=2, col='gold', main='Principal components')

x11()
biplot(pc.tourists)

# Let's use the categorical variables to further interpret the results
head(tourists.label)

# Color according to Month
tourists.label[,1]
# We order the labels according to time order
tourists.label[,1] <- factor(tourists.label[,1], levels=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"))
col.ramp <- rainbow(12)
col.lab1 <- rep(NA, n)
for(i in 1:n)
  col.lab1[i] = col.ramp[which(tourists.label[i,1] == levels(tourists.label[,1]))]

x11()
plot(scores.tourists[,1:2], col=col.lab1, pch=19, xlim=c(-8,25), ylim=c(-3,3.2))
abline(h=-3, v=-8, col=1)
points(scores.tourists[,1], rep(-3, n), col=col.lab1, pch=19)
points(rep(-8, n),scores.tourists[,2], col=col.lab1, pch=19)
abline(h=0, v=0, lty=2, col='grey')
legend('topright',levels(tourists.label[,1]),fill=rainbow(12),bty='n')
