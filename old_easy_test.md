# Easy Test for the Iregnet Proposal
****This is an old erroneous test which I attempted without much knowledge of L1, L2 regression and benchmarking. I attempted this test again after a lot of research and my new test is in the same repo with the name [easy_test.md](https://github.com/theadityasam/iregtest/blob/master/easy_test.md).   
Now it's only a memoir of the progress that I underwent throughout the week while attempting the tests**
## Console Output (Raw Code at the end of the Readme)
Including the required library files and initializing empty variables
```
> rm(list = ls())
> library(reshape2)
> library(glmnet)
> library(iregnet)
> library(ggplot2)
> library(microbenchmark)
> #Prostate dataset
> data("Prostate", package = "lasso2")
> #Benchmark times for glmnet and irgnet respectively
> glm_time <- vector()
> irg_time <- vector()
> #The data set size vector
> ds_size <- vector()
```

Checking the difference between the results produced by irgnet and glmnet for a dataset size of 50
```
> #Reshaping as matrix
> X = as.matrix(Prostate[1:50, c(2:9)])
> Y = matrix(c(Prostate[1:50, 1]))
> dimnames(Y) <- NULL
> dimnames(X) <- NULL
> #Setting the minimum fractional change in deviance for stoppinng path to 0 so that function 
> #continues all along the path, even without much change(effectively, 100 lambda values are obtained)
> glmnet.control(fdev = 0)
> #Building the model with glmnet(Lasso is selected by default)
> lasso_glm <- glmnet(y = Y, x = X, family="gaussian")
> #Since, the input to iregnet cannot be a one dimensional matrix, replicating column one into two
> Y = matrix(c(Prostate[1:50, 1],Prostate[1:50, 1]), nrow = 50, ncol = 2)
> dimnames(Y) <- NULL
> #Building the model with irgnet(Lasso selected by default)
> lasso_irg <- iregnet(y = Y, x = X, family="gaussian")
> #Plotting
> plot(lasso_irg)
> plot(lasso_glm)
> #Finding the change in lambda values obtained
> change <- lasso_irg$lambda - lasso_glm$lambda
> summary(change)
      Min.    1st Qu.     Median       Mean    3rd Qu.       Max. 
-3.332e-02 -3.335e-03 -3.336e-04 -3.751e-03 -3.660e-05 -3.660e-06 
```
We see that the mean change of lambda over the two functions is -3.751 x 10^(-3), i.e. can be considered "almost similar" upto a certain degree of error.  
Even the lasso regression plots of the two functions are almost identical.

**Plot obtained for lasso_irg**
![lasso_irg](https://github.com/aditya-sam/iregtest/blob/master/Images/lasso_irg.png)

**Plot obtained for lasso_glm**
![lasso_glm](https://github.com/aditya-sam/iregtest/blob/master/Images/lasso_glm.png)

**Now,**   
Evaluating the runtime of both the functions using the package microbenchmark over the data set size from 50 to 97
```
> #Iterating i from 1 to 47 and then adding 50 to it
> for(i in 1:47)
+ {
+   #Creating the Y and X matrices
+   Y = as.matrix(Prostate[1:50+i, 1])
+   X = as.matrix(Prostate[1:50+i, c(2:9)])
+   dimnames(Y) <- NULL
+   dimnames(X) <- NULL
+   #Setting the minimum fractional change in deviance for stoppinng path to 0
+   glmnet.control(fdev = 0)
+   #Timing the glmnet function using microbenchmark
+   mlm <- microbenchmark(
+     glmnet(y = Y, x = X, family="gaussian")
+   )
+   #Microbenchmark executes 100 times to evaluate runtime and hence taking mean of all the observation
+   # and dividing by 1000000 to obtain the time in milliseconds and storing in a vector
+   glm_time <- c(glm_time, mean(mlm$time)/1000000)
+   #Replicating column one into two for irgnet input
+   Y = matrix(c(Prostate[1:50+i, 1],Prostate[1:50+i, 1]), nrow = 50, ncol = 2)
+   dimnames(Y) <- NULL
+   #Timing irgnet using microbenchmark
+   mlm <- microbenchmark(
+     iregnet(y = Y, x = X, family="gaussian")
+   )
+   irg_time <- c(irg_time, mean(mlm$time)/1000000)
+ }
> #Defining the dataset sizse for which the benchmarks were performed
> ds_size <- c(51:97)
> #Storing the observations in a data frame
> df <- data.frame(ds_size, glm_time, irg_time)
> names(df) <- c("ds_size", "glmnet", "irgnet")
> #Melting the dataframe to make it ggplot friendly
> df_long <- melt(df, id = "ds_size")
> #Plotting the two runtimes using ggplot
> p <- ggplot(df_long, aes(x = ds_size, y = value, color = variable)) +
+       geom_line() +
+       ggtitle('Runtime(in milliseconds) vs Dataset Size') +
+       xlab('Dataset Size') +
+       ylab('Runtime (in milliseconds)')
> direct.label(p,"angled.boxes")
```

**The resulting plot obtained**  
![irgnetvsglmnet](https://github.com/aditya-sam/iregtest/blob/master/Images/time_comparison.png)

## Raw Source Code
```
#Including the required libraries
rm(list = ls())
library(reshape2)
library(glmnet)
library(directlabels)
library(iregnet)
library(ggplot2)
library(microbenchmark)
#Prostate dataset
data("Prostate", package = "lasso2")
#Benchmark times for glmnet and irgnet respectively
glm_time <- vector()
irg_time <- vector()
#The data set size vector
ds_size <- vector()

#-----------------------------------------------------------------

#Reshaping as matrix
X = as.matrix(Prostate[1:50, c(2:9)])
Y = matrix(c(Prostate[1:50, 1]))
dimnames(Y) <- NULL
dimnames(X) <- NULL
#Setting the minimum fractional change in deviance for stoppinng path to 0 so that function 
#continues all along the path, even without much change(effectively, 100 lambda values are obtained)
glmnet.control(fdev = 0)
#Building the model with glmnet(Lasso is selected by default)
lasso_glm <- glmnet(y = Y, x = X, family="gaussian")
#Since, the input to iregnet cannot be a one dimensional matrix, replicating column one into two
Y = matrix(c(Prostate[1:50, 1],Prostate[1:50, 1]), nrow = 50, ncol = 2)
dimnames(Y) <- NULL
#Building the model with irgnet(Lasso selected by default)
lasso_irg <- iregnet(y = Y, x = X, family="gaussian")
#Plotting
plot(lasso_irg)
plot(lasso_glm)
#Finding the change in lambda values obtained
change <- lasso_irg$lambda - lasso_glm$lambda
summary(change)

#-----------------------------------------------------------------

#Iterating i from 1 to 47 and then adding 50 to it
for(i in 1:47)
{
  #Creating the Y and X matrices
  Y = as.matrix(Prostate[1:50+i, 1])
  X = as.matrix(Prostate[1:50+i, c(2:9)])
  dimnames(Y) <- NULL
  dimnames(X) <- NULL
  #Setting the minimum fractional change in deviance for stoppinng path to 0
  glmnet.control(fdev = 0)
  #Timing the glmnet function using microbenchmark
  mlm <- microbenchmark(
    glmnet(y = Y, x = X, family="gaussian")
  )
  #Microbenchmark executes 100 times to evaluate runtime and hence taking mean of all the observation
  # and dividing by 1000000 to obtain the time in milliseconds and storing in a vector
  glm_time <- c(glm_time, mean(mlm$time)/1000000)
  #Replicating column one into two for irgnet input
  Y = matrix(c(Prostate[1:50+i, 1],Prostate[1:50+i, 1]), nrow = 50, ncol = 2)
  dimnames(Y) <- NULL
  #Timing irgnet using microbenchmark
  mlm <- microbenchmark(
    iregnet(y = Y, x = X, family="gaussian")
  )
  irg_time <- c(irg_time, mean(mlm$time)/1000000)
}
#Defining the dataset sizse for which the benchmarks were performed
ds_size <- c(51:97)
#Storing the observations in a data frame
df <- data.frame(ds_size, glm_time, irg_time)
names(df) <- c("ds_size", "glmnet", "irgnet")
#Melting the dataframe to make it ggplot friendly
df_long <- melt(df, id = "ds_size")
#Plotting the two runtimes using ggplot
p <- ggplot(df_long, aes(x = ds_size, y = value, color = variable)) +
      geom_line() +
      ggtitle('Runtime(in milliseconds) vs Dataset Size') +
      xlab('Dataset Size') +
      ylab('Runtime (in milliseconds)')
direct.label(p,"angled.boxes")
```
