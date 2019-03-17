# Easy Test for Iregnet

Including the required libraries and loading the Prostate dataset
```
rm(list = ls())
library(glmnet)
library(iregnet)
library(directlabels)
library(ggplot2)
library(microbenchmark)
library(dplyr) 
data("Prostate", package = "lasso2")
X = as.matrix(Prostate[, c(2:9)])#Feature matrix
#Since, the input to iregnet cannot be a one dimensional matrix, replicating column one into two
Y = matrix(c(Prostate[, 1],Prostate[, 1]), nrow = nrow(Prostate), ncol = 2)#Target matrix
colnames(Y)[c(1,2)] <- "lcalvol"
#Centering the data
Y <- apply(Y, 2, function(y) y - mean(y))
X <- apply(X, 2, function(x) x - mean(x))
```
Fitting the data with iregnet and glmnet and obtaining the plots
```
irg <- iregnet(X, Y)
glm <- glmnet(X, Y[,1])
plot(glm)
plot(irg)
```
**Plot obtained with iregnet**
![lasso_irg](https://github.com/aditya-sam/iregtest/blob/master/Images/irg.png)

**Plot obtained with glmnet**
![lasso_glm](https://github.com/theadityasam/iregtest/blob/master/Images/glm.png)

Now, evaluating the runtimes of glmnet and iregnet using microbenchmark and plotting the runtimes
```
res <- data.frame() #Result data frame
for(i in 30:nrow(X))
{
  evaltime <- microbenchmark(iregnet(X[1:i,], Y[1:i,]), glmnet(X[1:i,], Y[1:i,1]), times = 100L)
  res <- bind_rows(res, data.frame(i, list(summary(evaltime)[,c('min','mean','max')])))
}
res <- cbind.data.frame(c("IREGNET", "GLMNET"), res)
names(res) <- c("expr", names(res)[2:5])
p <- ggplot(res, aes(x = i))+
  geom_ribbon(aes(ymin = min, ymax = max, fill = expr, group = expr), alpha = 1/2)+
  geom_line(aes(y = mean, group = expr, colour = expr))+
  ggtitle('Runtime(in milliseconds) vs Dataset Size') +
  xlab('Dataset Size') +
  ylab('Runtime (in milliseconds)')
direct.label(p,"angled.boxes")
```
The plot obtained:  
![irgvsglm](https://github.com/theadityasam/iregtest/blob/master/Images/irgglm.png)  
Hence we see that the runtime of iregnet increases as the dataset size increases, whereas the mean runtime of glmnet doesn't witness much change as the dataset size increases
