# Attempt to recreate table 3.3 from "Elements of statistical learning" 2nd ed 
# Written by Engin Alper
# Modified by Kevin Murphy (12/2/15)
# Info on data is here: http://statweb.stanford.edu/~tibs/ElemStatLearn/datasets/prostate.info.txt

suppressPackageStartupMessages({
  library(cvTools)
  library(glmnet)
  library(leaps)
})

# Read the prostate data.
kProstateDataUrl <-
  "http://statweb.stanford.edu/~tibs/ElemStatLearn/datasets/prostate.data"
prostate.data <- read.table(
  kProstateDataUrl, sep="\t", header=TRUE, row.names=1)

# Scale the features and split data into test and training sets.
scaled.data <- cbind(scale(prostate.data[1:8]), as.matrix(prostate.data[9]))
train.x <- scaled.data[prostate.data$train, -9]
train.y <- scaled.data[prostate.data$train, 9, drop=FALSE]
test.x <- scaled.data[!prostate.data$train, -9]
test.y <- scaled.data[!prostate.data$train, 9, drop=FALSE]

# Create folds for the cross-validation to be used for all models.
set.seed(1101)
folds <- cvFolds(nrow(train.x), K=10, type="random")

# Construct an empty table to display at the end.
var.rows <- c("Intercept", colnames(train.x))
perf.rows <- c("Test Error", "Std Error")
nfeatures <- ncol(train.x)
nrows <- length(var.rows) + length(perf.rows) 
method.names <-c("LS", "Subset", "Ridge", "Lasso")
results <- matrix(
  0.0, nrow=nrows, ncol=length(method.names),
  dimnames=list(c(var.rows, perf.rows), method.names))

StoreResults <- function(method, coef, perf) {
  row.num <- match(names(coef), var.rows)
  row.num[is.na(row.num)] <- 1
  results[row.num, method] <<- coef
  results[perf.rows, method] <<- unlist(perf)
}

# Least squares
train.df <- data.frame(cbind(train.x, train.y))
m.ols <- lm(lpsa ~ . , data=train.df)
summary(m.ols)
y.pred.ols <- predict(m.ols,data.test)
summary((y.pred.ols - y.test)^2)
ls.sq.errors <- (y.pred.ols - y.test)^2
ls.mse <- mean(ls.sq.errors)
ls.std <- sqrt(var(ls.sq.errors)/n.test)
perf.ls <- mspe(test.y, y.pred.ols, includeSE=TRUE)
coef.ls <- m.ols$coefficients
StoreResults("LS", coef.ls, perf.ls)



# Best subset selection
predict.bestsubsetn <- function(object, newdata=NULL) {
  coef.n <- coef(object, id=object$N)
  x <- if(is.null(newdata)) object$x else newdata
  x <- cbind(1, x[, names(coef.n)[-1], drop=FALSE])
  return(c(x %*% coef.n))
}

BestSubsetN <- function(x, y, N) {
  fit <- regsubsets(x, y, nvmax=N)
  fit$N <- N
  fit$x <- x
  class(fit) <- c("bestsubsetn", class(fit))
  return(fit)
}

subset.cv <- cvTuning(
  call("BestSubsetN"), x=train.x, y=train.y, folds=folds, cost=mspe,
  costArgs=list(includeSE=TRUE), tuning=list(N=seq_len(ncol(train.x))),
  selectBest="hastie")
bestsubsetn <- BestSubsetN(train.x, train.y, subset.cv$best)
coef.subset <- coef(bestsubsetn, subset.cv$best)
perf.subset <- mspe(test.y, predict(bestsubsetn, test.x), includeSE=TRUE)
StoreResults("Subset", coef.subset, perf.subset)

# Ridge regression
ridge.cv <- cv.glmnet(
  train.x, train.y, alpha=0, nlambda=100,
  foldid=folds$which[order(folds$subsets)])
coef.ridge <- coef(ridge.cv, s="lambda.1se", exact=TRUE)
coef.ridge <- setNames(as.vector(coef.ridge), rownames(coef.ridge))
perf.ridge  <- mspe(test.y, predict(ridge.cv, newx=test.x, s="lambda.1se", exact=TRUE),
                    includeSE=TRUE)
StoreResults("Ridge", coef.ridge, perf.ridge)

# Lasso  regression
lasso.cv <- cv.glmnet(
  train.x, train.y, alpha=1, nlambda=100,
  foldid=folds$which[order(folds$subsets)])
coef.lasso <- coef(lasso.cv, s="lambda.1se", exact=TRUE)
coef.lasso <- setNames(as.vector(coef.lasso), rownames(coef.lasso))
perf.lasso <- mspe(test.y, predict(lasso.cv, newx=test.x, s="lambda.1se", exact=TRUE),
                   includeSE=TRUE)
StoreResults("Lasso", coef.lasso, perf.lasso)

round(results, 3)