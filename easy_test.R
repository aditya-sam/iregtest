rm(list = ls())
library(lasso2)
library(reshape2)
library(glmnet)
library(iregnet)
library(ggplot2)
library(microbenchmark)
data("Prostate")
glm_time <- vector()
irg_time <- vector()
ds_size <- vector()
mlm_list <- list()
for(i in 1:(nrow(Prostate)-50))
{
  Y = as.matrix(Prostate[1:50+i, 1])
  X = as.matrix(Prostate[1:50+i, c(2:9)])
  dimnames(Y) <- NULL
  dimnames(X) <- NULL
  mlm <- microbenchmark(
    glmnet(y = Y, x = X, family="gaussian")
  )
  glm_time <- c(glm_time, mean(mlm$time)/1000000)
  Y = matrix(c(Prostate[1:50+i, 1],Prostate[1:50+i, 1]), nrow = 50, ncol = 2)
  dimnames(Y) <- NULL
  mlm <- microbenchmark(
    iregnet(y = Y, x = X, family="gaussian")
  )
  irg_time <- c(irg_time, mean(mlm$time)/1000000)
}
ds_size <- c(51:97)
df <- data.frame(ds_size, glm_time, irg_time)
names(df) <- c("ds_size", "glm_time", "irg_time")
df_long <- melt(df, id = "ds_size")
ggplot(df_long, aes(x = ds_size, y = value), color = variable) +
  geom_line()


mlm <- microbenchmark(
  glmnet(y = Y, x = X, family="gaussian"),
  iregnet(y = Y, x = X, family="gaussian")
)


X = as.matrix(Prostate[1:50, c(2:9)])
Y = matrix(c(Prostate[1:50, 1]))
dimnames(Y) <- NULL
dimnames(X) <- NULL
lasso_glm <- glmnet(y = Y, x = X, family="gaussian")
Y = matrix(c(Prostate[1:50, 1],Prostate[1:50, 1]), nrow = 50, ncol = 2)
dimnames(Y) <- NULL
lasso_irg <- iregnet(y = Y, x = X, family="gaussian")
plot(lasso_irg)
plot(lasso_glm)
lasso_irg
lasso_glm
change <- lasso_irg$lambda - lasso_glm$lambda
