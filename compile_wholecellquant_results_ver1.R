# select Percent-Puncta-Results
rm(list=ls()) # clears R environment
setwd(choose.dir(default = "Y:/LiviaSongster/10-Analysis/2022-01-27-CHX-replicates-HMG2-yeast", caption = "Select Whole-Cell-Quant-SumZ-Results"))

#save the names of the files you want to import
file_names <- list.files(path = ".", full.names = FALSE, recursive = FALSE) #where you have your files
#combines all the csv files and adds a column at the end with the name of the file the data came from
# install.packages("data.table")
library(data.table)
# first we need to trim each file to exclude cells we don't want
# we also need to calculate corrected total cell fluorescence - CTCF
# more info here https://www.slu.se/contentassets/a454886b9b154b189ae2a7ded6baa4db/pacho-imagej-measuring-cell-fluorescence.pdf?si=3DB4E043D825F6E1513677D2512296DB&rid=1141616124&sn=sluEPi6-prodSearchIndex
image_names <- file_names[grep("WholeCellQuant",file_names)]
background_names <- file_names[grep("Background",file_names)]
dir.create("../Compiled_SumZ_data")
# make final dataframe for analysis
df.colnames <- c("File.Name","Strain","Chx","time","clone","Avg.CTCF","Avg.IntDen","n.cells","Avg.area")
finaldf <- data.frame(matrix(ncol = length(df.colnames), nrow = (length(file_names)/2)))
colnames(finaldf) <- df.colnames

# read in each image file and trim to exclude cells
# do not want cells below 7 um area, or below 0.7 roundness, aspect ratio greater than 1.3
for (x in 1:length(image_names)){
  temp_df <- read.csv(image_names[x])
  temp_new <- subset(temp_df, Area>7 & Round>0.7)
  
  temp_bkgd <- read.csv(background_names[x])
  
  # make new CTCF column
  temp_new[,12] <- temp_new[,7] - (temp_new[,2] * temp_bkgd[,3])
  colnames(temp_new)[12] <- c("CTCF")
  # start populating final data frame with values
  # metadata
  finaldf[x,1] <- image_names[x]
  finaldf[x,2] <- unlist(strsplit(image_names[x],split="_"))[2]
  finaldf[x,3] <- unlist(strsplit(image_names[x],split="_"))[3]
  finaldf[x,4] <- unlist(strsplit(image_names[x],split="_"))[4]
  finaldf[x,5] <- unlist(strsplit(image_names[x],split="_"))[5]
  # CTCF
  finaldf[x,6] <- mean(temp_new[,12])
  # IntDen
  finaldf[x,7] <- mean(temp_new[,7])
  # n cells
  finaldf[x,8] <- nrow(temp_new)
  # avg area
  finaldf[x,9] <- mean(temp_new[,2])
  write.csv(temp_new,paste0("../Compiled_SumZ_data/",image_names[x]))
  write.csv(finaldf,"../Compiled_SumZ_Data.csv")
  rm(temp_bkgd)
  rm(temp_df)
  rm(temp_new)
}
