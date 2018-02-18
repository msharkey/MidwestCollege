

#install.packages("RODBC")
install.packages("RSNNS")


library(party)
library(RSNNS)
library(RODBC)
library(rpart)


myServer <- ".\\SNAPMAN" #local server, change to your server  
myDatabase <- "StudentDataMart"
myDriver <- "SQL Server"

connectionString <- paste0(
	"Driver=", myDriver,
	";Server=", myServer,
	";Database=", myDatabase,
   ';trusted_connection = true ')

conn <- odbcDriverConnect(connectionString)


my.data <- sqlQuery(conn, '  SELECT Quarter,Year AS Year,SUM(ISNULL(ny.Donation_Amount,0)) AS Donation 
  FROM dim.date_day_year dy
  LEFT JOIN
  (

  SELECT    Date
            ,datekey,
            SUM(Donation_amount) AS Donation_Amount
  FROM      [Fact].[Donation] dd
            JOIN Dim.Event ee ON dd.event_id = ee.event_ID
            JOIN Dim.Date_Day_Year da ON da.datekeySK = dd.datekey
  GROUP BY  date,datekey
   ) ny
   ON dateKeySK = datekey
   WHERE dy.date BETWEEN  \'02-01-2007\' AND \'11-01-2009\'
   GROUP BY Quarter,Year 
   ORDER BY Year,Quarter
')


my.data <- my.data$Donation

my.timeseries <- ts(data = my.data,
					start = c(2007, 1),
					frequency = 4)



plot(my.timeseries)



#How about GPA metics?


my.data2 <- sqlQuery(conn, '   SELECT Cast(REPLACE(REPLACE(ISNULL(act,\'\'),\' \', \'\'), char(9), \'\') as INT) AS act 
  FROM Fact.StudentPerformance
WHERE act is not NULL AND act NOT LIKE \'%NULL%\'')




hist(my.data2$act)




my.data3 <- sqlQuery(conn, 'SELECT  REPLACE(REPLACE(ISNULL(Gender, \'\'), \' \', \'\'), char(9), \'\')  as Gender
   , Cast(REPLACE(REPLACE(ISNULL(high_school_gpa, \'\'), \' \', \'\'), char(9), \'\') as DECIMAL(6, 2)) AS high_school_gpa
FROM[DIM] .[STUDENT] st
JOIN Fact.StudentPerformance sp
ON st.StudentID = sp.studentID')




# 5 number summary

plot(y = my.data3$high_school_gpa,x = my.data3$Gender)






my.data4 <- sqlQuery(conn,'Select high_school_gpa,act FROM rep.vwdonor')




plot(y= my.data4$act,x=my.data4$high_school_gpa)





attach(mtcars)
par(mfrow = c(2, 2))
plot(my.timeseries)
hist(my.data2$act)
plot(y = my.data3$high_school_gpa, x = my.data3$Gender)
plot(y = my.data4$act, x = my.data4$high_school_gpa)




my.data5 <- sqlQuery(conn, 'Select * FROM rep.vwdonor')

my.input <- my.data5[,1:8]
my.target <- my.data5[,9]

splitdata <- splitForTrainingAndTest(my.input, my.target,
		  ratio = .33 )


DTREEdataTrain <- cbind(splitdata$inputsTrain,splitdata$targetsTrain)


DTREEdataTrain <- as.data.frame(DTREEdataTrain)

names(DTREEdataTrain) <- names(my.data5)


fit <- ctree(PastDonor ~ AgeYears + Marital_Status + Major + high_school_gpa, data = DTREEdataTrain)


plot(fit)


close(conn)