# Read the files
dtTrain<-fread(file.path(path,"train","subject_train.txt"))
dtTest<-fread(file.path(path,"test","subject_test.txt"))

dt_Act_train<-fread(file.path(path,"train","Y_train.txt"))
dt_Act_test<-fread(file.path(path,"test","Y_test.txt"))

Train<-read.table(file.path(path,"train","X_train.txt"))
Test<-read.table(file.path(path,"test","X_test.txt"))

# Merge the train and test sets
Subject<-rbind(dtTrain,dtTest)
setnames(Subject,"V1","subject")
Activity<-rbind(dt_Act_train,dt_Act_test)
setnames(Activity,"V1","activityNum")
dt<-rbind(Train,Test)
Subj<-cbind(Subject,Activity)
dt<-cbind(Subj,dt)
setkey(dt,subject,activityNum)

# Extract only the mean and standard deviation
Features<-fread(file.path(path,"features.txt"))
setnames(Features, names(Features), c("featureNum","featureName"))
Features<-Features[grepl("mean\\(\\)|std\\(\\)",featureName)]
Features$featureCode<-Features[,paste0("V",featureNum)]
Subset<-c(key(dt),Features$featureCode)
dt<-dt[,Subset,with=FALSE]

# Use descriptive activity names
Act_names<-fread(file.path(path,"activity_labels.txt"))
setnames(Act_names,names(Act_names),c("activityNum","activityName"))

# Appropriately labels with descriptive activity names
dt<-merge(dt,Act_names,by="activityNum",All.x=TRUE)
setkey(dt,subject,activityNum,activityName)
dt<-data.table(melt(dt,key(dt),variable.name="featureCode"))
dt<-merge(dt,Features[,list(featureNum,featureCode,featureName)],by="featureCode",all.x=TRUE)
dt$activity<-factor(dt$activityName)
dt$feature<-factor(dt$featureName)

# features with 1 category
dt$featJerk<-factor(grepl("Jerk",dt$feature),labels=c(NA,"Jerk"))
dt$featMag<-factor(grepl("Mag",dt$feature),labels=c(NA,"Magnitude"))

# features with 2 categories
n<-2
y<-matrix(seq(1,n),nrow=n)
x<-matrix(c(grepl("^t",dt$feature),grepl("^f",dt$feature)),ncol=nrow(y))
dt$featDomain<-factor(x%*%y,labels=c("Time","Freq"))
x<-matrix(c(grepl("Acc",dt$feature),grepl("Gyro",dt$feature)),ncol=nrow(y))
dt$featInstrument<-factor(x%*%y,labels=c("Accelerometer","Gyroscope"))
x<-matrix(c(grepl("BodyAcc",dt$feature), grepl("GravityAcc",dt$feature)),ncol=nrow(y))
dt$featAcceleration<-factor(x%*%y,labels=c(NA,"Body","Gravity"))
x<-matrix(c(grepl("mean()",dt$feature),grepl("std()",dt$feature)),ncol=nrow(y))
dt$featVar<-factor(x%*%y,labels=c("Mean","Std"))

# features with 3 categories
n<-3
y<-matrix(seq(1,n),nrow=n)
x<-matrix(c(grepl("-X",dt$feature),grepl("-Y",dt$feature),grepl("-Z",dt$feature)),ncol=nrow(y))
dt$featAxis<-factor(x%*%y, labels=c(NA, "X", "Y", "Z"))

# Create a tidy data set
setkey(dt,subject,activity,featDomain, featAcceleration, featInstrument, featJerk, featMag, featVar, featAxis)
dtTidy<-dt[,list(count= .N, average=mean(value)),by=key(dt)]

# Write Tidy data
write.table(dtTidy,file.path(path,"Tidy.txt"),row.name=FALSE)

# Return Tidy data
dtTidy