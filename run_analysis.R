# assume test data files  are in the directory ./data/test
# assume train data files  are in the directory ./data/train

# 
packages<-c("data.table", "dplyr","plyr", "reshape2")
sapply(packages, require, character.only = TRUE)
       
       
features<-  "data/features.txt"
activityLabel<-"data/activity_labels.txt"
XtestFile<-  "data/test/X_test.txt"
YtestFile <- "data/test/y_test.txt"
StestFile <-  "data/test/subject_test.txt"

XtrainFile <- "data/train/X_train.txt"
YtrainFile <-  "data/train/y_train.txt"
StrainFile <-  "data/train/subject_train.txt"

DF_Xtest <- read.table(file =XtestFile)
DF_Ytest <- read.table(file =YtestFile)
DF_Stest <- read.table(file =StestFile)

DF_Xtrain <- read.table(file =XtrainFile)
DF_Ytrain <- read.table(file =YtrainFile)
DF_Strain <- read.table(file =StrainFile)

#----------------------------------------------------------------------------------------
#1.Merges the training and the test sets to create one data set.
# add column from X,Y and subject  for each set of data (test, training)
#----------------------------------------------------------------------------------------

DF_allTest<-cbind(DF_Xtest, DF_Stest ,DF_Ytest)

DF_allTrain<-cbind(DF_Xtrain, DF_Strain, DF_Ytrain)

# merge test and training data 
DF_Merge<- rbind(DF_allTest, DF_allTrain)

head(DF_Merge)

#----------------------------------------------------------------------------------------
# naming the columns with  names from feature.txt
#----------------------------------------------------------------------------------------
DF_features <- read.table(file =features,-c("IdData", "feature"))



DF_features<-rbind(DF_features,data.frame("IdData"=562, "feature"="Subject"))
DF_features<-rbind(DF_features,data.frame("IdData"=563, "feature"="IdActivite"))

DF_features$feature <- gsub('-mean', 'Mean', DF_features$feature) # Replace `-mean' by `Mean'
DF_features$feature <- gsub('-std', 'Std', DF_features$feature) # Replace `-std' by 'Std'
DF_features$feature <- gsub('([()])','', DF_features$feature) # Replace `-std' by 'Std'
DF_features$feature <- gsub('-,','', DF_features$feature) # Replace `-std' by 'Std'

DF_features$unique<- make.names(DF_features$feature, unique=TRUE)

#rename column folowing the rule to avoid duplicate colume
colnames(DF_Merge)<-DF_features$unique

#----------------------------------------------------------------------------------------
# Extracts only the measurements on the mean and standard deviation for each measurement. 
#----------------------------------------------------------------------------------------

DF_extract<-select(DF_Merge, Subject,  IdActivite,  
                      contains("Mean"), 
                      contains("Std"))

#----------------------------------------------------------------------------------------
#Uses descriptive activity names to name the activities in the data set
#----------------------------------------------------------------------------------------


DF_activityLabel <- read.table(file =activityLabel, col.names = c("IdActivite", "Activity"))

DF_activityLabel

DF_extract <- join(DF_extract, DF_activityLabel, by = "IdActivite", match = "first")


#----------------------------------------------------------------------------------------
#4. Appropriately labels the data set with descriptive names.
#----------------------------------------------------------------------------------------
# already done before filtering Mean and std



#----------------------------------------------------------------------------------------
#5. From the data set in step 4, creates a second, independent tidy data set  with the 
# average of each variable for each activity and each subject 
#----------------------------------------------------------------------------------------

DF_extract.agg <- aggregate(DF_extract[, 3:ncol(DF_extract)],
                       by=list(subject = DF_extract$Subject, 
                               label = DF_extract$Activity),
                       mean)

#----------------------------------------------------------------------------------------
# correct column name
#----------------------------------------------------------------------------------------

DF_extract_agg_colName<-names(DF_extract.agg)
DF_extract_agg_colName<-sapply(DF_extract_agg_colName, addSuffix, ".mean")
names(finaldata)<-finaldataheaders

DF_extract_agg_colName<-paste("mean", colnames(DF_extract.agg), sep=".")

colnames(DF_extract.agg)<-DF_extract_agg_colName


#----------------------------------------------------------------------------------------
write.table(DF_extract.agg, file = "Peer_Assessments.txt", row.name=FALSE)

