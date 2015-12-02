
# Attempt to recreate table 3.3 from "Elements of statistical learning" 2nd ed 
# Written by Jean-Philippe.Vert@mines.org
# Modified by Kevin Murphy (12/2/15)
#http://cbio.ensmp.fr/~jvert/svn/tutorials/practical/linearregression/linearregression.R


####################################
## Prepare data
####################################

# Download prostate data
#con = url("http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/prostate.data")
con = url("http://statweb.stanford.edu/~tibs/ElemStatLearn/datasets/prostate.data")
prost=read.csv(con,row.names=1,sep="\t")
# Alternatively, load the file and read from local file as follows
# prost=read.csv('prostate.data.txt',row.names=1,sep="\t")


# Scale data and prepare train/test split
prost.std <- data.frame(cbind(scale(prost[,1:8]),prost$lpsa))
names(prost.std)[9] <- 'lpsa'
data.train <- prost.std[prost$train,]
data.test <- prost.std[!prost$train,]
y.test <- data.test$lpsa
n.train <- nrow(data.train)
n.test <- nrow(data.test)

####################################
## Ordinary least squares
####################################

m.ols <- lm(lpsa ~ . , data=data.train)
summary(m.ols)
y.pred.ols <- predict(m.ols,data.test)
summary((y.pred.ols - y.test)^2)

# Summary stats
ls.coef <- as.vector(m.ols$coefficients)
ls.sq.errors <- (y.pred.ols - y.test)^2
ls.mse <- mean(ls.sq.errors)
ls.std <- sqrt(var(ls.sq.errors)/n.test)



####################################
## Ridge regression
####################################

library(MASS)
m.ridge <- lm.ridge(lpsa ~ .,data=data.train, lambda = seq(0,20,0.1))
plot(m.ridge)

# select parameter by minimum GCV
plot(m.ridge$GCV)

# Predict is not implemented so we need to do it ourselves
params <- m.ridge$coef[,which.min(m.ridge$GCV)]
ybar <- m.ridge$ym # mean(data.train$lpsa)
Xtest <- scale(data.test[,1:8],center = F, scale = m.ridge$scales)
y.pred.ridge = Xtest %*% params + ybar
summary((y.pred.ridge - y.test)^2)

# Summary stats
ridge.coef <- append(as.vector(params), ybar, 0)
ridge.sq.errors <- (y.pred.ridge - y.test)^2
ridge.mse <- mean(ridge.sq.errors)
ridge.std <- sqrt(var(ridge.sq.errors)/n.test)

####################################
## Lasso
####################################

library(lars)

m.lasso <- lars(as.matrix(data.train[,1:8]),data.train$lpsa)
plot(m.lasso)

# Cross-validation
r <- cv.lars(as.matrix(data.train[,1:8]),data.train$lpsa)
#bestfraction <- r$fraction[which.min(r$cv)]
##### Note 5/8/11: in the new lars package 0.9-8, the field r$fraction seems to have been replaced by r$index. The previous line should therefore be replaced by:
bestfraction <- r$index[which.min(r$cv)]

# Observe coefficients
coef.lasso <- predict(m.lasso,as.matrix(data.test[,1:8]),s=bestfraction,type="coefficient",mode="fraction")
coef.lasso

# Prediction
y.pred.lasso <- predict(m.lasso,as.matrix(data.test[,1:8]),s=bestfraction,type="fit",mode="fraction")$fit
summary((y.pred.lasso - y.test)^2)

# Summary stats
lasso.coef <- append(as.vector(coef.lasso$coefficients), ybar, 0)
lasso.sq.errors <- (y.pred.lasso - y.test)^2
lasso.mse <- mean(lasso.sq.errors)
lasso.std <- sqrt(var(lasso.sq.errors)/n.test)

###################################
## Best subset selection
####################################

library(leaps)
l <- leaps(data.train[,1:8],data.train[,9],method='r2')
plot(l$size,l$r2)
l <- leaps(data.train[,1:8],data.train[,9],method='Cp')
plot(l$size,l$Cp)

# Select best model according to Cp
bestfeat <- l$which[which.min(l$Cp),]

# Train and test the model on the best subset
m.bestsubset <- lm(lpsa ~ .,data=data.train[,bestfeat])
summary(m.bestsubset)
y.pred.bestsubset <- predict(m.bestsubset,data.test[,bestfeat])
summary((y.pred.bestsubset - y.test)^2)

