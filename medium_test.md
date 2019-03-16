# Medium Test
## Console Output
Including the required library files and neuroblastomaProcessed dataset
```
> rm(list = ls())
> library("iregnet")
> library("glmnet")
> data("neuroblastomaProcessed", package = "penaltyLearning")
> #Processing the data, removing the features with variance zero
> X = as.matrix(neuroblastomaProcessed$feature.mat)
> Y = as.matrix(neuroblastomaProcessed$target.mat)
> X = X[,apply(X,2,function(x){
+   return(var(x)!=0)
+ })]
```
Fitting the model
```
fitireg <- iregnet(X, Y)
plot(fitireg)
```
Plot obtained  
![plot1](https://github.com/theadityasam/iregtest/blob/master/Images/mediumtest1.png)  

Since one of the coefficient's magnitude is much more than the others, the graph cannot be clearly evaluated
```
#Finding the variable with the most negative value
plot(fit$beta[,100])
which.min(fit$beta[,100]
```
![plot2](https://github.com/theadityasam/iregtest/blob/master/Images/mediumtest2.png)

Much cleaner plot obtained after removing that variable
```
fit$beta <- fit$beta[-c(which.min(fit$beta[,100])),]
plot(fit)
```
![plot3](https://github.com/theadityasam/iregtest/blob/master/Images/mediumtest3.png)
