# 1. Merge training and test sets ==============================================================================================
  # Download and unzip data for the project
    if(!file.exists("./accelerometers_data.zip")) 
    {
      fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
      download.file(fileUrl, "./accelerometers_data.zip", method="curl") 
      unzip("accelerometers_data.zip")
    }

  # Load data into R
    # Training data set
      train = read.table("UCI HAR Dataset//train//X_train.txt") # Table with measurements
      trainLabels = read.table("UCI HAR Dataset/train/y_train.txt") # Info to identify activity per row
      trainSubjects = read.table("UCI HAR Dataset/train/subject_train.txt") # Info to identify subject per row
      train = cbind(trainLabels, train) # Merge measurements and activity id
      train = cbind(trainSubjects, train) # Merge measurements and subject id

    # Test data set
      test = read.table("UCI HAR Dataset//test//X_test.txt") # Table with measurements
      testLabels = read.table("UCI HAR Dataset/test/y_test.txt") # Info to identify activity per row
      testSubjects = read.table("UCI HAR Dataset/test/subject_test.txt") # Info to identify subject per row
      test = cbind(testLabels, test) # Merge measurements and activity id
      test = cbind(testSubjects, test) # Merge measurements and subject id

  # Merge training and test data sets
    df = rbind(train, test)



# 2. Extract measurements on the mean and standard deviation for each measurement ==============================================
  # Label variables
    measurements = read.table("UCI HAR Dataset/features.txt", as.is=T) # Names of measurement variables
    names(df) = c("subject", "activity",measurements[,2])
  
  # Define variables that correspond to mean or standard deviation
    variables = grep("mean\\()|std\\()", names(df), value=T, ignore.case=T)

  # Restrict data set to mean and standard deviation variables
    df = df[,c("subject", "activity",variables)]



# 3. Name the activities in the data set =======================================================================================
  # Read in activity names
    activities = read.table("UCI HAR Dataset//activity_labels.txt", as.is=T)

  # Replace activity id by activity names
    df = merge(df, activities, by.x = "activity", by.y = "V1")
    df$activity = df$V2
    df = df[,-ncol(df)]



# 4. Labels the data set with descriptive variable names =======================================================================
  # Remove "()" from variable names
    names(df) = gsub("\\()","",names(df))
  # Replace "-" with "." in variable names
    names(df) = gsub("-",".",names(df))



# 5. Create independent data set with the average of each variable for each activity and each subject ==========================
  # Melt data
    library(reshape2)
    meltedDf = melt(df, id=c("activity", "subject"), measure.vars=names(df)[3:ncol(df)]) # Define id and measurement variables
  # Cast data to get average of each variable
    meanData = dcast(meltedDf, activity + subject ~ variable, mean)

# Save independent data set ====================================================================================================
write.table(meanData, "averageData.txt",row.name=F, quote=F)
