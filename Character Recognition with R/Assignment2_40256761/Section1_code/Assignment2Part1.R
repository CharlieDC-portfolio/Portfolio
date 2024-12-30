setwd("E:/CSC2062/Assignment2_40256761/Section1_images")#set work directory
filelist = list.files(pattern = ".pgm")#import dataset file list
for (i in 1:length(filelist)){#loop through dataset files
  input<-filelist[i]
  output<-paste0(gsub("\\.pgm$", "",input), ".csv")#switch from pgm to csv
  print(paste("Processing the file:", input))
  data = read.delim(input, header = TRUE, skip = 3)#read in the pgm file as a text file
  data<-t(data)#rotate data so it is the correct orientation
  data[data<128]<- 1#make black pixels 1
  data[data>=128]<-0#make white pixels 0
  mat<-matrix(data, nrow=25,ncol=25)#create a 25 by 25 matrix populated with the image data
  write.table(t(mat), file = output, sep=",",col.names = FALSE, row.names = FALSE)#write the populated matrix to a csv file
}








