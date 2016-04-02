library(reshape2)

File <- "dataset.zip"

## Downloading, unzipping the dataset
if (!file.exists(File)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, File, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(File) 
}

# Loading activity labels,features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracting only the data with mean and standard deviation
featuresReq <- grep(".*mean.*|.*std.*", features[,2])
featuresReq.names <- features[featuresReq,2]
featuresReq.names = gsub('-mean', 'Mean', featuresReq.names)
featuresReq.names = gsub('-std', 'Std', featuresReq.names)
featuresReq.names <- gsub('[-()]', '', featuresReq.names)


# Loading the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresReq]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresReq]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merging datasets and add labels
clubbedData <- rbind(train, test)
colnames(clubbedData) <- c("subject", "activity", featuresReq.names)

# turning activities,subjects into factors
clubbedData$activity <- factor(clubbedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
clubbedData$subject <- as.factor(clubbedData$subject)

clubbedData.melted <- melt(clubbedData, id = c("subject", "activity"))
clubbedData.mean <- dcast(clubbedData.melted, subject + activity ~ variable, mean)

write.table(clubbedData.mean, "tidyData.txt", row.names = FALSE, quote = FALSE)