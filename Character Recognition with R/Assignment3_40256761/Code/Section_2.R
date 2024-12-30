library(class)
library(dplyr)
library(caret)
import(ggplot2)
setwd(".../Assignment3_40256761")#set work directory
set.seed(42)
featuresTable<-read.csv(file='40256761_features.csv')#read features list into r
mat<-as.matrix(featuresTable)#set features Table as a matrix
par(mar=c(5,5,1,1))

type<-c()
for (i in 1:168){#loop through dataset
  if(mat[i,1]=="one"||mat[i,1]=="two"||mat[i,1]=="three"||mat[i,1]=="four"||mat[i,1]=="five"||mat[i,1]=="six"||mat[i,1]=="seven"){
    type<-c(type,"Digits")#assign digits a string of digit
  }else if(mat[i,1]=="a"||mat[i,1]=="b"||mat[i,1]=="c"||mat[i,1]=="d"||mat[i,1]=="e"||mat[i,1]=="f"||mat[i,1]=="g"){
    type<-c(type,"Letter")#assign letters a string of letter
  }else{
    type<-c(type,"Math")#assign maths symbols a string of math
  }
}
featuresTable$type <- type #add type column to features table

train.X<-featuresTable[, 3:8]#select features

accuracies<-c()

#fit knn model with multiple values of k
for(j in seq(from = 1, to = 25, by=2)){
  knn_pred<-knn(train.X, train.X, featuresTable$type, j)
  table(knn_pred,featuresTable$type)
  accuracies <- cbind(accuracies, mean(knn_pred==featuresTable$type))
}

accuracies

ks<-c(1,3,5,7,9,11,13,15,17,19,21,23,25)
#5 fold cross validation of knn models with different k values
train.control<-trainControl(method = "cv", number = 5)
model<-train(type~nr_pix+row_with_2+cols_with_2+rows_with_3p+cols_with_3p+height, data=featuresTable,method="knn", trControl=train.control, metric="Accuracy", tuneGrid = expand.grid(k=ks))
print(model)

k_inverse<-c(1,1/3,1/5,1/7,1/9,1/11,1/13,1/15,1/17,1/19,1/21,1/23,1/25)
model_accuracy<-c(model$results$Accuracy)
print(model_accuracy)

#plot accuracy rate against inverse k
class_accuracy_rate<-data.frame(k_inverse, accuracy<-t(accuracies))
cross_class_accuracy_rate<-data.frame(k_inverse,accuracy<-model_accuracy)

cols<-c("kInverse","AccuracyRate")
colnames(class_accuracy_rate)<-cols
colnames(cross_class_accuracy_rate)<-cols
x<-k_inverse
y1<-class_accuracy_rate$AccuracyRate
y2<-cross_class_accuracy_rate$AccuracyRate
plot(x, y1, type="o",pch=19, col="red", xlab="1/k", ylab="Accuracy Rate", ylim = c(0.5,1))
lines(x, y2, pch=18, col="blue", type="o", lty=1)
legend("topleft",legend = c("Classification", "Cross Validated Classification"),col=c("red","blue"), lty=1,cex=0.8)



