library(caret)
library(randomForest)
require(caTools)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(nnet)
setwd(".../Assignment3_40256761")#set work directory
set.seed(42)
par(mar=c(5,5,1,1))
featuresTable<-read.csv("40256761_2100items_features.csv",sep="\t",header=FALSE)
names(featuresTable)<-c("label","index","nr_pix","rows_with_2","cols_with_2","rows_with_3p","cols_with_3p","height","width","left2tile","right2tile","verticalness","top2tile","bottom2tile","horizontalness")
featuresTable<-transform(featuresTable, label = as.factor(label))
train.control<-trainControl(method = "cv", number = 5)
Np<-c(2,4,6,8)
best_res<-c()
trees<-c(25,50,75,100,125,150,175,200,225,250,275,300,325,350,375,400)
colours<-rainbow(16)
plot(NA,xlim=c(2,8),ylim=c(0.63,0.68), xlab="Np",ylab="Accuracy")
#train rf model with multiple values of Nt and Np using cross-validation
for(i in 1:16){
    rfTrain<-train(label~nr_pix+rows_with_2+cols_with_2+rows_with_3p+cols_with_3p+height+width+left2tile+right2tile+verticalness+top2tile+bottom2tile+horizontalness,
                   data=featuresTable, 
                   method = "rf", 
                   trControl=train.control, 
                   tuneGrid = expand.grid(mtry=Np), 
                   ntree = trees[i])
    max_Acc<-(max(rfTrain$results$Accuracy))#find best accuracy of model
    max_Acc_ind<-which(rfTrain$results==max_Acc, arr.ind = TRUE)#find index of max accuracy
    best_mtry<-rfTrain$results[max_Acc_ind[1,1],1]#get corresponding Np value
    max_Acc_for_Np<-c(trees[i],best_mtry,max_Acc)
    best_res<-rbind(best_res,max_Acc_for_Np)
    
    lines(rfTrain$results$mtry,rfTrain$results$Accuracy,type="o",lty=1, col=colours[i])#plot results of each model
}
legend("topleft",legend=paste(trees),lwd=2,col=colours,cex=0.8)
print(best_res)
overall_best_Acc<-max(best_res[,3])
overall_best_Acc_ind<-which(best_res==overall_best_Acc,arr.ind = TRUE)
Best<-best_res[overall_best_Acc_ind[1,1],]
print(Best)
refitted_acc<-c()
#using best Np and Nt values refit model 15 times
for(i in 1:15){
    best_rf_model<-train(label~nr_pix+rows_with_2+cols_with_2+rows_with_3p+cols_with_3p+height+width+left2tile+right2tile+verticalness+top2tile+bottom2tile+horizontalness,
                                data=featuresTable, 
                                method = "rf", 
                                trControl=train.control, 
                                tuneGrid = expand.grid(mtry=Best[2]), 
                                ntree = Best[1])
    refitted_acc<-rbind(refitted_acc,best_rf_model$results$Accuracy)
}
mean_acc<-mean(refitted_acc[,1])#mean of accuracies
sd_acc<-sd(refitted_acc[,1])#standard deviation of accuracies
print(paste("The mean accuracy for the 15 crossvalidated accuracies of the best random forest model is ", mean_acc, ", the standard deviation is ",sd_acc))

best_rf_res<-c()
#train rf model with multiple values of Nt and Np using cross-validation
for(i in seq(from=25, to=400, by=25)){
    bestRf<-train(label~rows_with_2+cols_with_2+rows_with_3p+cols_with_3p+height+width+left2tile+right2tile+verticalness+top2tile+bottom2tile+horizontalness,
                   data=featuresTable, 
                   method = "rf", 
                   trControl=train.control, 
                   tuneGrid = expand.grid(mtry=Np), 
                   ntree = i)
    max_Acc<-(max(bestRf$results$Accuracy))
    max_Acc_ind<-which(bestRf$results==max_Acc, arr.ind = TRUE)
    best_mtry<-bestRf$results[max_Acc_ind[1,1],1]
    max_Acc_for_Np<-c(i,best_mtry,max_Acc)
    best_rf_res<-rbind(best_res,max_Acc_for_Np)
}
best_Rf_Acc<-max(best_rf_res[,3])
best_Rf_Acc_ind<-which(best_rf_res==best_Rf_Acc,arr.ind = TRUE)
Best_Rf_model<-best_rf_res[best_Rf_Acc_ind[1,1],]

ks<-c(1,3,5,7,9,11,13,15,17,19,21,23,25)

#5 fold cross validation of knn models with different k values
knn_model<-train(label~rows_with_2+cols_with_2+rows_with_3p+cols_with_3p+height+width+left2tile+right2tile+verticalness+top2tile+bottom2tile+horizontalness,
             data=featuresTable,method="knn",
             trControl=train.control,
             metric="Accuracy", 
             tuneGrid = expand.grid(k=ks))
max_knn_acc<-max(knn_model$results$Accuracy)
max_knn_acc_ind<-which(knn_model$results==max_knn_acc, arr.ind = TRUE)
best_knn_model<-knn_model$results[max_knn_acc_ind[1,1],]

refitted_Rf_acc<-c()
refitted_knn_acc<-c()

#refit knn and rf with best k, Np and Nt values to account for random variance
for(i in 1:5){
    rf_model<-train(label~rows_with_2+cols_with_2+rows_with_3p+cols_with_3p+height+width+left2tile+right2tile+verticalness+top2tile+bottom2tile+horizontalness,
                         data=featuresTable, 
                         method = "rf", 
                         trControl=train.control, 
                         tuneGrid = expand.grid(mtry=Best_Rf_model[2]), 
                         ntree = Best_Rf_model[1])
    refitted_Rf_acc<-rbind(refitted_Rf_acc,rf_model$results$Accuracy)
    
    knn_model<-train(label~rows_with_2+cols_with_2+rows_with_3p+cols_with_3p+height+width+left2tile+right2tile+verticalness+top2tile+bottom2tile+horizontalness,
                     data=featuresTable,method="knn",
                     trControl=train.control,
                     metric="Accuracy", 
                     tuneGrid = expand.grid(k=best_knn_model[1]))
    refitted_knn_acc<-rbind(refitted_knn_acc, knn_model$results$Accuracy)
}
mean_rf_acc<-mean(refitted_Rf_acc[,1])
mean_knn_acc<-mean(refitted_knn_acc[,1])
print(mean_rf_acc)
print(mean_knn_acc)
