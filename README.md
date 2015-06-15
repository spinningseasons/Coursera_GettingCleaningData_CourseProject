#README for Coursera Getting and Cleaning Data Class Project

-Explains analyses conducted in run_analysis.R (which creates a tidy data file, CourseProjectData.txt)

-See also the specific description of the tidy data file contents in ProjectCodeBook.R

-Utilizes the Human Acitivity Recognition Using Smartphones Dataset (See data at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)


--------------------------------------------------------------------------------------------------------------------------------------------------------

##PROJECT REQUIREMENTS:
Create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

---------------------------------------------------------------------------------------------------------------------------------------------------------

##STEP-BY-STEP EXPLANATIONS:

(All important packages are loaded prior to starting the analysis. As per assignment instructions, it is assumed the data is in the current working directory)

###Step 1: Merge training and test sets to create one data set.
1. The data is stored in the X_test.txt and X_training.txt files
2. Load those files into data frames in R using the read.table() function
3. Since we do not need to keep the test and training data separate for machine learning purposes (as the original authors intended), the test and training data frames are merged into one data frame using the rbindlist() funciton

####Notes: 
At this point, we have all the raw data collected into one data frame. However, the variables names are not appropriately labeled

###Step 2: Extract only the measurements on the mean and standard deviation for each measurement.

1. The variables names for the columns in our data frame are stored in features.txt
2. Load these names into a vector called varNames using the scan() function 
3. Label the columns in our data frame using the values in varName and the colnames() function
4. We only want the column variables that look at mean or standard deviation. I chose to define this as pure mean() or std() and exclude measures such as meanFreq(). This is in line with guidelines our TAs gave in the Discussion Forums allowing us to choose how we define which variables meet inclusion criteria.
5. Search the varNames vector for "mean()" or "std()" and output the indices into the whichCol variable using the grep() function
6. Create a new data frame that only includes the mean or std variables using the select() function and whichCol
	
####Notes: 
We now have a data frame that includes only the variables (columns) we are interested in. It also has more meaningful labels for the variables, but they are not in a "tidy", descriptive format yet.

###Step 3: Use descriptive activity names to name the activities in the data set.
1. The activity labels for the data are stored in the Y_test.txt and T_train.txt files
2. Load those files into data frames using the read.table() function and merge into one data frame using the rbind() function
3. Add the activity labels to the first column of our data frame from Step 2 using the data.frame() function (put the data frames in the desired order)
4. The activity labels are still in numeric format. However, we want descriptive labels. The descriptive to numeric label mapping is as follows (found 
	   in the activity_labels.txt file):
1-Walking
2-Walking Upstairs
3-Walking Downstairs
4-Sitting
5-Standing
6-Laying
5. Turn the activity column of data frame into a factor class (it originally defaulted to numeric) and assign the levels of the factor their appropriate descriptive names based on the above mapping

####Notes: 
Since the row order was not changed, we could simply add the activity labels directly onto our old data frame without any special matching (as long as the test and train rows were stacked in the same order (and in this case, test came first and then train))

Our data frame now has what activity was happening when each measurement was collected, and that activity has a descriptive names (e.g., standing)
rather than an untidy numeric code (e.g., 5). However, the column names are still not in a tidy, descriptive format.

###Step 4: Appropriately label the data set with descriptive variable names.
1. The column names are untidy. The activity column still has the default name of "V1". In Step 2.3, we gave the other columns names based on the
features.txt file (stored in varNames), but they are not syntactically correct for R (they contain "()", "-", & " ") and they start with numbers.
2. Pull the variable names that match the variables we care about (those with mean() or std()) and assign to new variable, origValNames
3. Transform origValNames to newValNames using the function gsub(): 
		-Remove the leading numbers and space
		-Replace the syntactically inappropriate "mean()" and "std()" with "Mean" and "STD", respectively
		-Replace the syntactically inappropriate and misleading "-" with "_"
4. Create allNewNames variable that has the first column labeled as "activity" and includes the names stored in the newValNames variable
5. Assign the tidy names stored in allNewNames to our data frame

####Notes: 
Our data frame now has tidy variable names. An important aspect of "tidy" data is readability, so I made the following decisions: 

(1) Not to make all
all the letters of the variables lowercase. I find it is much easier to parse "tBodyAccJerk_Mean_X" than "tbodyaccjerk_mean_x" so it made sense to
leave the beginning of words uppercase

(2) To change the "-" to "_" rather than "". The underscore allows for a separation between the  measure, 
function, and dimension that otherwise might be misunderstood if it was not there. Again, I find it easier to understand "tBodyAccJerk_Mean_X" than 
"tBodyAccJerkMeanX"

(3) To leave words like "Accelerometer" abbrevaited as "Acc". The variables names are already very long, and I did not think
it would be approriate to make them even longer by spelling out the words when the abbreviations were intuitive.

Again, I believe these decisions are in line with the advice offered by our TAs in the Discussion Forum instructing us to make judgment calls
but explain our reasoning to our readers. I believe the decisions made in this step optimized the readability and efficiency of the variable labels.

We now have a data frame that has tidy variable lables, descriptive values for all qualitative variables (e.g., activity), collapses across the test
and training data, and only includes variables about means or standard devations. However, it does not include subject information.

###Step 5: Create a second data set with the average of each variable for each activity and each subject
1. The subject labels for the data are stored in hte subject_test.txt and subject_train.txt files
2. Load those files into data frames using the read.table() function and merge into one data frame using the rbind() function
3. Add the subject labels to the first column of our data frame from Step 4 using the data.frame() function (put the data frames in the desired order)
4. Rename the subject variable from the default "V1" to "subject" and turn that variable into a factor variable
5. Melt the data from wide format into long format so that it will be simple to extract the averages of each measure, using the melt() function and setting the 
6. id variables to subject and activity
6. Transform that long format data frame back into a wide format data frame, applying the mean() function to each measure by using the dcast() function

####Notes: 
We now have a new data frame which includes the average of each mean or standard devation measure for each subject at each activity level. The variables have tidy labels, the qualitive variables have descriptive labels (e.g., "walking" rather than "1"), it's in wide format with one variable in each column
and no duplicate variables. This meets the criteria outlined by our professor in his lecture videos, the TAs in the Discussion Forums, the assignment, 
guidelines, and the original paper on tidy data by Hadley Wickham (http://www.jstatsoft.org/v59/i10/paper).

###Create text file
Finally, we save that final data frame to the text file, "CourseProjectData.txt" using the write.table() function.
