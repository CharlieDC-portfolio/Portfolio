vec<-c("label","index","nr_pix","row_with_2","cols_with_2","rows_with_3p","cols_with_3p","height","width","left2tile","right2tile","verticalness","top2tile","bottom2tile","horizontalness","isolated")#create a vector containing column headings
featuresList<-matrix(vec,nrow=1,ncol=16,byrow = TRUE,)#create correctly sized matrix with column headings
setwd("E:/CSC2062/Assignment2_40256761/Section1_images")#set work directory
fileList = list.files(pattern = ".csv")#import dataset file list
for (i in 1:length(fileList)){#loop through dataset
  input<-fileList[i]
  file<-read.csv(file = input,header=FALSE, sep = ",")#read csv file into r
  mat<-as.matrix(file)#change csv to matrix
  nr_pix<-table(mat)[names(table(mat))==1]#count number of black pixels
  label <- unlist(strsplit(input,split = '_',fixed=TRUE))[2]#seperate file name to get label
  tempIndex <- unlist(strsplit(input,split = '_',fixed=TRUE))[3]#seperate file name to get index
  index<-gsub("\\.csv$", "",tempIndex)#remove .csv from file index
  #instantiate feature variables
  rows_with_2 <- 0
  rows_with_3p <- 0
  cols_with_2 <- 0
  cols_with_3p <- 0
  topDown <- 0
  bottomUp <- 0
  leftRight<-0
  rightLeft<-0
  left2tile<-0
  right2tile<-0
  top2tile<-0
  bottom2tile<-0
  isolate<-0
  for(j in 1:25){#loop through matrix rows
    rowAvg<-mean(mat[j, ])#take mean of rows
    if (rowAvg!=0.08){#if there are 2 in a row the average is 0.08 as a pixel value is 1
      rows_with_2<-rows_with_2
    }else{rows_with_2 <- rows_with_2 + 1}#assign feature variable its value 
    colAvg<-mean(mat[,j])#take mean of columns
    if (colAvg!=0.08){
      cols_with_2<-cols_with_2
    }else{cols_with_2 <- cols_with_2 + 1}
    
    if(rowAvg>=0.12){rows_with_3p<-rows_with_3p+1}#average for 3 or more pixels is 0.12
    if(colAvg>=0.12){cols_with_3p<-cols_with_3p+1}
    if(topDown!=0){
    }else{
      if(rowAvg > 0){topDown<-j}#count what row the first pixel is on (top to bottom)
    }
    verticalReverse<-26-j
    bottomUpAvg<-mean(mat[verticalReverse,])
    if(bottomUp!=0){
    }else{
      if(bottomUpAvg > 0){bottomUp<-verticalReverse}#count what row the last pixel is on (bottom to top)
    }
    if(leftRight!=0){
    }else{
      if(colAvg > 0){leftRight<-j}#count what column the first pixel is in(left to right)
    }
    horizontalReverse<-26-j
    rightLeftAvg<-mean(mat[,horizontalReverse])
    if(rightLeft!=0){
    }else{
      if(rightLeftAvg > 0){rightLeft<-horizontalReverse}#count what column the last pixel is in(right to left)
    }
  }
  for(o in 1:24){
    for(p in 1:24){#loop through 25 by 25 matrix
      if((mat[o,p]+mat[o,p+1])!=2){#check if top 2 pixels are black in 2x2 sub-matrix
      }else{
        if((mat[o+1,p]+mat[o+1,p+1])!=0){
        }else{
          top2tile<-top2tile+1
        }
      }
      if((mat[o,p]+mat[o,p+1])!=0){
        }else{
          if((mat[o+1,p]+mat[o+1,p+1])!=2){#check if bottom 2 pixels are black in 2x2 sub-matrix
          }else{
            bottom2tile<-bottom2tile+1
          }
        }
      if((mat[o,p]+mat[o+1,p])!=0){#check if right 2 pixels are black in 2x2 sub-matrix
      }else{
        if((mat[o,p+1]+mat[o+1,p+1])!=2){
        }else{
          right2tile<-right2tile+1
        }
      }
      if((mat[o,p]+mat[o+1,p])!=2){#check if left 2 pixels are black in 2x2 sub-matrix
      }else{
        if((mat[o,p+1]+mat[o+1,p+1])!=0){
        }else{
          left2tile<-left2tile+1
        }
      }
    }
  }
  for(q in 1:23){
    for(r in 1:23){#loop through 25 by 25 matrix
      if((mat[q,r]+mat[q+1,r]+mat[q+2,r])>0){#check if middle pixel is black in 3x3 sub-matrix
      }else{
        if(mat[q,r+1]!=0){
        }else{
        if(mat[q+1,r+1]!=1){
        }else{
          if(mat[q+2,r+1]!=0){
          }else{
          if((mat[q,r+2]+mat[q+1,r+2]+mat[q+2,r+2])>0){
          }else{
            isolate<-isolate+1
          }
        }
        }
        }
      }
    }
  }

  height<-bottomUp-topDown#height is the position of the last pixel row - the position of the first pixel row
  width<-rightLeft-leftRight#width is the position of the last pixel column - the position of the first pixel column
  verticalness<-(right2tile+left2tile)/nr_pix
  horizontalness<-(top2tile+bottom2tile)/nr_pix
  output<-paste0(gsub("40256761_","",input),": ")
  features<-c(label,index,nr_pix,rows_with_2,cols_with_2,rows_with_3p,cols_with_3p,height,width,left2tile,right2tile,verticalness,top2tile,bottom2tile,horizontalness,isolate)#create a vector containing feature values for each file
  featuresList<-rbind(featuresList,features)#add the feature vector to the feature list matrix
}
setwd("E:/CSC2062/Assignment2_40256761/Section2_features")
featuresCsv<-write.table(featuresList,file="40256761_features.csv",row.names = FALSE, col.names = FALSE, sep=",")#write the feature list matrix to a csv 




