#Download data file
url<-'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip'
path<-file.path(getwd(),"hpc.zip")
download.file(url,path)
household_power_consumption<-read.csv( unz(path, "household_power_consumption.txt"), sep=";", quote="",na="?")
dim(household_power_consumption) #2075259  9

#subset data
hpc<-household_power_consumption[household_power_consumption$Date %in% c('1/2/2007','2/2/2007'),]
dim(hpc) #2880  9

#Plot1 building
hpc$Global_active_power<-as.numeric(hpc$Global_active_power)

png(filename="plot1.png", width=480, height=480, units="px", bg="transparent")
hist(hpc$Global_active_power, col="red",main="Global Active Power",xlab="Global Active Power (Kilowatts)",breaks=12,ylim=c(0,1200))
dev.off()
