#import necessary libraries
library(readr)
library(ggplot2)
library(tidyverse)
library(caTools)
library(caret)
library(MLeval)
library(ROCR)
install.packages('e1071', dependencies=TRUE)
setwd(".../Assignment3_40256761")#set work directory
set.seed(42)
featuresTable<-read.csv(file='40256761_features.csv')#read features list into r
mat<-as.matrix(featuresTable)#set features Table as a matrix
#create empty vectors
type<-c()
for (i in 1:168){#loop through dataset
  if(mat[i,1]=="one"||mat[i,1]=="two"||mat[i,1]=="three"||mat[i,1]=="four"||mat[i,1]=="five"||mat[i,1]=="six"||mat[i,1]=="seven"){
    type<-c(type,0)#assign digits a value of 0
  }else if(mat[i,1]=="a"||mat[i,1]=="b"||mat[i,1]=="c"||mat[i,1]=="d"||mat[i,1]=="e"||mat[i,1]=="f"||mat[i,1]=="g"){
    type<-c(type,0)#assign letters a value of 0
  }else{
    type<-c(type,1)#assign maths symbols a value of 1
  }
}
featuresTable$type <- type#add type column to features table
#create a variable that discriminates between math and other types
featuresTable$is.math<-"no"
featuresTable$is.math
featuresTable$is.math[featuresTable$type=='1']<-"yes"
featuresTable$is.math
featuresTable$is.math<-relevel(featuresTable$dummy.math, ref = "yes")
featuresTable$is.math

type.glm <- glm(as.numeric(type)~as.numeric(nr_pix), data =featuresTable, family=binomial)#fit logistic regression model
predict(type.glm, featuresTable, type="response")#model predictions using dataset
summary(type.glm)

# To plot the fitted curve, let's make a data frame containing the predicted 
# values across the range of feature values (i.e. across the x-axis)
x.range<-range(featuresTable[["nr_pix"]])
x.range
x.values <- seq(x.range[1],x.range[2],length.out=1000)
x.values
fitted.curve <- data.frame(nr_pix = x.values)
fitted.curve[["is.math"]] = predict(type.glm, fitted.curve, type="response")
fitted.curve

# Plot the training data and the fitted curve:
plot <-ggplot(featuresTable, aes(x=nr_pix, y=is.math)) + 
  geom_point(aes(colour = factor(is.math)), 
             show.legend = T, position = "dodge")+
  geom_line(data=fitted.curve, colour="orange", size=1)
plot

featuresTable[["predicted_val"]] = predict(type.glm, featuresTable, type="response")
featuresTable[["predicted_class"]] = "no"
featuresTable[["predicted_class"]][featuresTable[["predicted_val"]] > 0.5] = "yes"

correct_items = featuresTable[["predicted_class"]] == featuresTable[["is.math"]] 
correct_items
#train the model
train.control<-trainControl(method = "cv", number = 5, savePredictions = TRUE, classProbs = TRUE)
model <- train(is.math~nr_pix,data=featuresTable, method="glm", family=binomial, trControl = train.control)
print(model)

#sensitivity, specificity:
cm1 = confusionMatrix(table(factor(model$pred$yes >= 0.5, c(FALSE,TRUE)),model$pred$obs == "yes"), positive="TRUE")
cm1

# precision, recall, f1:
cm2 = confusionMatrix(table(factor(model$pred$yes >= 0.5,c(FALSE,TRUE)),model$pred$obs == "yes"),mode = "prec_recall", positive = "TRUE")
cm2

#plot roc curve
res <- evalm(model)
res$roc

