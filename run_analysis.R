#run_analysis.R: Script for Coursera Getting and Cleaning Data course project
#       -As per assignment direction, this script assumes the HCI HAR data set is in the current working directory
#       -See README.md for further information
#       -Last updated 06.15.15


#Load important packages:
library(data.table)
library(plyr)
library(dplyr)
library(reshape2)

###################################################################
# Step 1: Merge the training and test sets to create one data set #
###################################################################

#Load in test and training data
testdata <- read.table("./UCI_HAR_Dataset/test/X_test.txt")
traindata <- read.table("./UCI_HAR_Dataset/train/X_train.txt")

#Merge test and training data into one data set
data <- rbindlist(list(testdata,traindata))


####################################################################################
# Step 2: Extract only the measurements on the mean and stdev for each measurement #
####################################################################################

#Pull column names from features.txt and assign to data set
varNames <- scan("./UCI_HAR_Dataset/features.txt",what="",sep ="\t")
colnames(data) <- varNames

#Find the indices of the names that contain "mean()" or "std()" and assign to whichCol vector
meanList <- grep("mean\\(\\)",varNames)
stdList <- grep("std\\(\\)",varNames)
whichCol <- c(meanList,stdList)

#Use whichCol vector to select mean & std data
datameanstd <- select(data,whichCol)


#################################################################################
# Step 3: Use descriptive activity names to name the activities in the data set #
#################################################################################

#Load in test and training activity labels (these are still numeric)
testAct <- read.table("./UCI_HAR_Dataset/test/Y_test.txt")
trainAct <- read.table("./UCI_HAR_Dataset/train/Y_train.txt")

#Merge the test and train activity labels
allAct <- rbind(testAct,trainAct)

#Add to beginning of data set from Step 2
dataAct <- data.frame(allAct,datameanstd)

#Treat the activity labels as factors and change from numeric to descriptive
dataAct$V1=factor(dataAct$V1,labels=c("walking","walkingupstairs","walkingdownstairs","sitting","standing","laying"))


############################################################################
# Step 4: Appropriately label the data set with descriptive variable names #
############################################################################

#Remove numbers and space from beginning of data variables names; Make variable names syntactically appropriate for R
origValNames=varNames[whichCol]
newValNames=gsub("[0-9]+ ","",origValNames)
newValNames=gsub("mean\\(\\)","Mean",newValNames)
newValNames=gsub("std\\(\\)","STD",newValNames)
newValNames=gsub("-","_",newValNames)

#Include name for new activity label variable
allNewNames=c("activity",newValNames)

#Assign new tidy names to data set
names(dataAct)=allNewNames


#########################################################################################################
# Step 5: Create a second data set with the average of each variable for each activity and each subject #
#########################################################################################################

#Load in test and training subject labels
testSubj <- read.table("./UCI_HAR_Dataset/test/subject_test.txt")
trainSubj <- read.table("./UCI_HAR_Dataset/train/subject_train.txt")

#Merge the test and train subject labels
allSubj <- rbind(testSubj,trainSubj)

#Add to beginning of data set from Step 4
dataSubj <- data.frame(allSubj,dataAct)

#Get tidy data names (importantly changing subject label name from "V1" to "subject)
names(dataSubj)=c("subject",allNewNames)
dataSubj$subject=as.factor(dataSubj$subject)

#Melt data into long format 
dataLong <- melt(dataSubj, id.vars = c("subject","activity"))

#Recast data into wide format, applying the mean function to each variable for the levels of subject and activity
dataWideAvg <- dcast(dataLong, subject + activity ~ variable, fun.aggregate=mean, na.rm = TRUE)


########################################
# Create .txt file from data in Step 5 #
########################################

write.table(dataWideAvg,file = "CourseProjectData.txt",row.names=FALSE)
