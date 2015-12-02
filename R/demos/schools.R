# R code for entering the data and fitting the Bugs model for 8 schools
# analysis from Section 5.5 of "Bayesian Data Analysis".

# To run, the Bugs model must be in the file "schools.txt" in your working
# directory and you must load in the functions in the bugs.R file (see
# http://www.stat.columbia.edu/~gelman/bugsR/).


#J <- 8
#y <- c(28,8,-3,7,-1,1,18,12)
#sigma.y <- c(15,10,16,11,9,11,10,18)

schools <- read.table("schools.dat", header=T)
J <- nrow(schools)
y <- schools$estimate
sigma.y <- schools$sd

schools.data <- list ("J", "y", "sigma.y")
schools.inits <- function()
  list (theta=rnorm(J,0,1), mu.theta=rnorm(1,0,100),
        sigma.theta=runif(1,0,100))
schools.parameters <- c("theta", "mu.theta", "sigma.theta") 

#run in winbugs14

schools.sim <- bugs (schools.data, schools.inits, schools.parameters,
    "schools.bug", n.chains=3, n.iter=1000,  debug=T)

schools.sim <- bugs (schools.data, schools.inits, schools.parameters,
"schools.bug", n.chains=3, n.iter=1000, debug=F, codaPkg=TRUE)

# run in openbugs
# SORRY--IT DOESN'T WORK WITH OPENBUGS

#schools.sim <- bugs (schools.data, schools.inits, schools.parameters,
"schools.bug", n.chains=3, n.iter=1000, version=2)

# KPM
attach.all(schools.sim$sims.list)

y.rep <- array(NA, c(n.sims, J))
for (sim in 1:n.sims)
  y.rep[sim,] <- rnorm(J, theta[sim,], sigma.y)

par (mfrow=c(5,4), mar=c(4,4,2,2) )
hist (y, xlab="", main="y")
for (sim in 1:19)
  hist (y.rep[sim,], xlab="", main=paste("y.rep", sim))


