# Hard Test
We need to perform 5 fold CV on neuroblastomaProcessed with iregnet and penaltyLearning::IntervalRegressionCV and compare the results in terms of test error

## Code
```
rm(list = ls())
library(penaltyLearning)
data("neuroblastomaProcessed")
#Creating function errorpercent to return test error
errorpercent <- function(predicted, output)
{
  len <- length(predicted)
  errors <- 0
  for(i in 1:len)
  {
    if((predicted[i]<output[i,1]) || (predicted[i]>output[i,2]))
    {
      errors <- errors+1
    }
    else{}
  }
  return (errors/len)
}
```
Fitting the model with penaltyLearning::IntervalRegressionCV and calculating the testerror on target.mat
```
fitircv <- with(neuroblastomaProcessed, IntervalRegressionCV(
  feature.mat, target.mat, n.folds = 5L,
  verbose=0))
errorpercent(predict(fitircv, newx = neuroblastomaProcessed$target.mat), neuroblastomaProcessed$target.mat)
>0.01492101
```
Hence we see that the test error for penaltyLearning::IntervalRegressionCV with n.folds = 5 is 1.492101%  
Now, creating a function that performs n folds CV with Iregnet
```
cv.iregnet.predict <- function(X, Y, nfolds, seed = 1218, lambda = NULL)
{
  #Removing features with zero variance
  X = X[,apply(X,2,function(x){
    return(mean(x)!=0)
  })]
  set.seed(seed)
  index <- sample(1:nrow(X))
  pred <- matrix(0,nrow(X), 1)
  folds <- cut(seq(1,nrow(X)),breaks=nfolds,labels=FALSE)
  for (i in seq(nfolds)) 
  {
    x.train <- X[-index[folds == i],]
    y.train <- Y[-index[folds == i],]
    x.test <- X[index[folds == i],]
    y.test <- Y[index[folds == i],]
    fit <- iregnet(x.train, y.train)
    temp <- predict(fit, newx = x.test)[,100]
    pred[index[folds == i],1] <- temp
  }
  return (pred)
}
```
Fitting the model with cv.iregnet.predict with nfolds = 5
```
predireg <- cv.iregnet.predict(neuroblastomaProcessed$feature.mat, neuroblastomaProcessed$target.mat, 5L)
errorpercent(predireg, neuroblastomaProcessed$target.mat)
>0.01813926
```
Hence, we see that, the test error for cv.iregnet.predict is 1.813926%, which is more than the 1.492101% test error obtained with IntervalRegressionCV

Let's evaluate the two functions over 10 iterations and try to evaluate their errors
```
errireg <- vector()
errircv <- vector()
for(i in 1:10)
{
  set.seed(1240)
  seeds <- sample.int(1000, 10)
  set.seed(seeds[i])
  fitircv <- with(neuroblastomaProcessed, IntervalRegressionCV(
    feature.mat, target.mat, n.folds = 5L,
    verbose=0))
  errintreg <- c(errintreg, errorpercent(predict(fitircv, newx = neuroblastomaProcessed$target.mat), neuroblastomaProcessed$target.mat))
  predireg <- cv.iregnet.predict(neuroblastomaProcessed$feature.mat, neuroblastomaProcessed$target.mat, 5L, seeds[i])
  errireg <- errorpercent(predireg, neuroblastomaProcessed$target.mat)
}
> mean(errircv)
[1] 0.01550614
> mean(errireg)
[1] 0.02018724
```
We see that, over 10 iterations, the test error of IntervalRegressionCV is 1.550614% whereas the test error of cv.iregnet.predict is 2.018724% i.e. on an average, the test error of 5 fold CV iregnet is more than that of IntervalRegressionCV
