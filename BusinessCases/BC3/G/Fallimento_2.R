library(car)
library(mvtnorm)

dat <- read.csv('EWS.csv', header=T)
head(dat)

dat.label <- dat[,1:2]
dat <- dat[,-(1:2)]
heatmap(cor(dat))
n <- dim(dat)[1]
p <- dim(dat)[2]

for(i in 1:42)
  lambda.x <- powerTransform(dat[,i],family="bcnPower")
  # lambda<1: observations <1 are "spread", observations >1 are "shrinked"
  # Transformed sample with the optimal lambda (command bcPower of library car)
  dat[,i] <- bcPower(dat[,i], lambda.x$lambda)      # it transforms the data of the first argument through the Box-Cox 
  # transformation with lambda given as second argument


hist(dat[,2])
lambda.x <- powerTransform(dat[,2],family="bcPower")
# lambda<1: observations <1 are "spread", observations >1 are "shrinked"
# Transformed sample with the optimal lambda (command bcPower of library car)
dat[,2] <- bcPower(dat[,2], lambda.x$lambda) 

