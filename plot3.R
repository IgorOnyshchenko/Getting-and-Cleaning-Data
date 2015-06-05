#Download data file
url<-'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip'
path<-file.path(getwd(),"hpc.zip")
download.file(url,path)
household_power_consumption<-read.csv( unz(path, "household_power_consumption.txt"), sep=";", quote="",na="?")
dim(household_power_consumption) #2075259  9

#subset data
hpc<-household_power_consumption[household_power_consumption$Date %in% c('1/2/2007','2/2/2007'),]
dim(hpc) #2880  9

#Plot3 building
hpc$DateTime<-paste(hpc$Date,hpc$Time)
hpc$DateTime<-strptime(hpc$DateTime,"%d/%m/%Y %H:%M:%S")

png(filename="plot3.png", width=480, height=480, units="px", bg="transparent")
plot(hpc$DateTime, hpc$Sub_metering_1, type="l", col="black",xlab="",ylab="Energy sub metering")
lines(hpc$DateTime, hpc$Sub_metering_2, col="red")
lines(hpc$DateTime, hpc$Sub_metering_3, col="blue")
legend("topright",col=c("black","red","blue"), c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),lwd=1)
dev.off()
