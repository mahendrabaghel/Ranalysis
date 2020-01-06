# check we will need it later
if (!"reshape2" %in% installed.packages()) {
  install.packages("reshape2")
}
library("reshape2")

# file download
fileName <- "UCIHARdata.zip"
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- "UCI HAR Dataset"

# check.
if(!file.exists(fileName)){
  download.file(url,fileName, mode = "wb") 
}

# check.
if(!file.exists(dir)){
  unzip("UCIHARdata.zip", files = NULL, exdir=".")
}


## Read data into tables
subject_test_table <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train_table <- read.table("UCI HAR Dataset/train/subject_train.txt")
X_test_table <- read.table("UCI HAR Dataset/test/X_test.txt")
X_train_table <- read.table("UCI HAR Dataset/train/X_train.txt")
y_test_table <- read.table("UCI HAR Dataset/test/y_test.txt")
y_train_table <- read.table("UCI HAR Dataset/train/y_train.txt")

activity_labels_table <- read.table("UCI HAR Dataset/activity_labels.txt")
features_table <- read.table("UCI HAR Dataset/features.txt")  


# bind training and test into one data set.
dataSet <- rbind(X_train_table,X_test_table)

#vector of mean and std
MeanStdOnly <- grep("mean()|std()", features_table[, 2]) 
dataSet <- dataSet[,MeanStdOnly]


#change the data labels
CleanFeatureNames <- sapply(features_table[, 2], function(x) {gsub("[()]", "",x)})
names(dataSet) <- CleanFeatureNames[MeanStdOnly]

#combine test and train for subject and activity
subject <- rbind(subject_train_table, subject_test_table)
names(subject) <- 'subject'
activity <- rbind(y_train_table, y_test_table)
names(activity) <- 'activity'

# combine subject, activity, and mean and std only data set to create final data set.
dataSet <- cbind(subject,activity, dataSet)


#descriptive names
act_group <- factor(dataSet$activity)
levels(act_group) <- activity_labels_table[,2]
dataSet$activity <- act_group


# melt data to tall skinny data and cast means. Finally write the tidy data to the working directory as "clean_data.txt"
baseData <- melt(dataSet,(id.vars=c("subject","activity")))
secondDataSet <- dcast(baseData, subject + activity ~ variable, mean)
names(secondDataSet)[-c(1:2)] <- paste("[mean of]" , names(secondDataSet)[-c(1:2)] )
write.table(secondDataSet, "clean_data.txt", sep = ",")

