USE [StudentDataMart]
GO

/****** Object:  StoredProcedure [DIM].[usp_loadEvent]    Script Date: 2/17/2018 4:09:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [DIM].[usp_loadEvent]
AS

MERGE dim.event AS target
USING (
SELECT event_ak,
Event_name
,Event_Category
,CASE WHEN Event_Location IS NULL OR event_location = 'null' THEN 'N/A' ELSE event_location END AS Event_Location
,COALESCE(Event_Department,'N/A') AS Event_Department
,COALESCE(Event_Sponsor,'N/A') AS Event_Sponsor
FROM stg.event
) AS Source(event_ak,Event_Name,Event_Category, Event_Location, Event_Department,Event_Sponsor)
ON (target.event_ak = source.event_ak)
WHEN MATCHED THEN UPDATE 
  SET target.event_ak = source.event_ak,
      target.event_name = source.event_name,
      target.event_category = source.event_category,
	  target.Event_location = source.event_location,
	  target.event_department = source.event_department,
	  target.event_sponsor = source.event_sponsor
WHEN NOT MATCHED BY TARGET THEN 
INSERT (Event_ak,Event_Name,Event_Category, Event_Location, Event_Department,Event_Sponsor)
VALUES (source.event_ak,source.Event_Name,source.Event_Category, source.Event_Location, source.Event_Department,source.Event_Sponsor);
GO


USE [StudentDataMart]
GO

/****** Object:  StoredProcedure [DIM].[usp_loadStudent]    Script Date: 2/17/2018 4:09:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [DIM].[usp_loadStudent]
AS

UPDATE dns
SET donor_ak = 2478
FROM stg.donations dns
JOIN stg.donor 
ON donor.donor_ak = dns.donor_ak 
WHERE student_ak = 1190

DELETE 
FROM stg.donor 
WHERE donor_ak = 148



;WITH dedup_student_CTE 
AS (
Select
 donor_ak 
,First_Name,Last_Name
,Coalesce(Income_Level, 'N/A') as Income_Level
,Coalesce(Country      ,'N/A') as  Country
,Coalesce(State		   ,'N/A')  as  State	
,Coalesce(City		   ,'N/A')  as  City
,Coalesce(Zip_Code	   ,'N/A')  as  Zip_Code	
,Coalesce(Relationship ,'N/A')   as Relationship
,Coalesce(Giving_Level ,'N/A')   as Giving_Level
,ROW_NUMBER() Over(Partition BY student_ak order by donor_ak Desc) as RN
,student_ak
From stg.donor 
WHERE student_ak <> ''
), student_cte AS 
(

Select st.Student_AK
,st.First_Name
,st.Last_Name
,Coalesce(st.Birth_Date,'N/A') as Birth_Date
,Case Marital_Status When '1' then 'Married' When '0' then 'Single' ELSE 'N/A' END as Marital_Status
,Coalesce(Gender,'N/A') as Gender
,Coalesce(Race					,'N/A') AS Race
,Coalesce(mj1.Major				,'N/A') AS Major
,Coalesce(mj2.Major             ,'N/A')      As SecondMajor
,Coalesce(mn.Major              ,'N/A')      As Minor
,Coalesce(Housing_Status		,'N/A') AS Housing_Status
,Coalesce([Full_Time_Part_Time],'N/A') AS Enrollement_Status
,Coalesce(Legacy_Status			,'N/A') AS Legacy_Status
,Coalesce(Transfer_Flag			,'N/A') AS Transfer_Flag
,Coalesce(Financial_Aid			,'N/A') AS Finacial_Aid
,Coalesce([Current]				,'N/A') AS Current_Status
,Coalesce(st.Country				,'N/A') AS Country
,Coalesce(st.State					,'N/A') AS State_Code
,Coalesce(st.City					,'N/A') AS City
,Coalesce(st.Zip_Code				,'N/A') AS Zip_Code
,Coalesce(st.Financial_Aid_Type,	 'N/A') AS Financial_Aid_Type
,Coalesce(dd.relationship,'N/A') AS RelationShip, COALESCE(dd.giving_level,'N/A') AS giving_level,COALESCE(income_level,'N/A') AS  Income_level,donor_ak
FROM stg.student st
LEFT JOIN stg.major mj1
ON st.major_1_ak = mj1.major_ak
LEFT JOIN stg.major mj2
ON st.major_2_ak = mj2.major_ak
LEFT JOIN stg.major mn
ON st.minor_ak = mn.Major_ak
LEFT JOIN dedup_student_CTE dd
ON (dd.student_ak  = st.student_ak AND RN = 1)
)





MERGE dim.student AS target
USING ( SELECT * FROM student_cte) AS Source(Student_AK,	First_Name,	Last_Name,	Birth_Date,	Marital_Status,	Gender,	Race	,Major	,SecondMajor	
,Minor	,Housing_Status,	Enrollement_Status,	Legacy_Status,	Transfer_Flag,	Finacial_Aid,	Current_Status,	Country	,State_Code,	City,	Zip_Code,	Financial_Aid_Type,
	RelationShip,	giving_level	,Income_level,donor_ak
)
ON (target.student_ak= source.student_ak)
WHEN MATCHED THEN UPDATE 
  SET 
  target.First_Name		=	source.First_Name                          ,  
target.Last_Name		=	source.Last_Name						   ,
target.Birth_Date		=	source.Birth_Date						   ,
target.Marital_Status		=	source.Marital_Status				   ,
target.Gender		=	source.Gender								   ,
target.Race		=	source.Race										   ,
target.Major		=	source.Major								   ,
target.SecondMajor		=	source.SecondMajor						   ,
target.Minor		=	source.Minor								   ,
target.Housing_Status		=	source.Housing_Status				   ,
target.Enrollement_Status		=	source.Enrollement_Status		   ,
target.Legacy_Status		=	source.Legacy_Status				   ,
target.Transfer_Flag		=	source.Transfer_Flag				   ,
target.Finacial_Aid		=	source.Finacial_Aid						   ,
target.Current_Status		=	source.Current_Status				   ,
target.Country		=	source.Country								   ,
target.State_Code		=	source.State_Code						   ,
target.City		=	source.City										   ,
target.Zip_Code		=	source.Zip_Code								   ,
target.Financial_Aid_Type		=	source.Financial_Aid_Type		   ,
target.RelationShip		=	source.RelationShip						   ,
target.giving_level		=	source.giving_level						   ,
target.Income_level		=	source.Income_level					,
	target.donor_ak		=	source.donor_ak	   


WHEN NOT MATCHED BY TARGET THEN 
INSERT (Student_AK,	First_Name,	Last_Name,	Birth_Date,	Marital_Status,	Gender,	Race	,Major	,SecondMajor	
,Minor	,Housing_Status,	Enrollement_Status,	Legacy_Status,	Transfer_Flag,	Finacial_Aid,	Current_Status,	Country	,State_Code,	City,	Zip_Code,	Financial_Aid_Type,
	RelationShip,	giving_level	,Income_level,donor_ak)
VALUES (
Source.Student_AK,
source.First_Name          ,
source.Last_Name		   ,
source.Birth_Date		   ,
source.Marital_Status	   ,
source.Gender			   ,
source.Race				   ,
source.Major			   ,
source.SecondMajor		   ,
source.Minor			   ,
source.Housing_Status	   ,
source.Enrollement_Status  ,
source.Legacy_Status	   ,
source.Transfer_Flag	   ,
source.Finacial_Aid		   ,
source.Current_Status	   ,
source.Country			   ,
source.State_Code		   ,
source.City				   ,
source.Zip_Code			   ,
source.Financial_Aid_Type  ,
source.RelationShip		   ,
source.giving_level		   ,
source.Income_level,
SOURCE.donor_ak
);


GO



USE [StudentDataMart]
GO

/****** Object:  StoredProcedure [Fact].[usp_loaddonation]    Script Date: 2/17/2018 4:09:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [Fact].[usp_loaddonation]
AS

 TRUNCATE TABLE  Fact.Donation

 DROP TABLE IF EXISTS #donation;
 
 SELECT ds.donor_ak,ds.donation_ak,ds.Donation_Amount, CONVERT (char(8),ds.donation_date,112) as DateKey,ds.event_ak
 INTO #Donation
 FROM stg.donations ds
 JOIN stg.donor dr
 ON dr.donor_ak = ds.donor_ak



INSERT INTO Fact.Donation
        ( studentID ,
          event_ID ,
          DateKey ,
          Donation_Amount
        )
SELECT studentID ,
       ev.event_ID,
	   dot.DateKey,
       dot.Donation_Amount	  
FROM #Donation dot
LEFT JOIN Dim.Student dr
ON dr.donor_ak = dot.donor_ak
LEFT JOIN Dim.Event ev
ON ev.event_ak = dot.event_ak

GO



USE [StudentDataMart]
GO

/****** Object:  StoredProcedure [Fact].[usp_loadevent]    Script Date: 2/17/2018 4:09:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE   PROCEDURE [Fact].[usp_loadevent]
AS

TRUNCATE TABLE Fact.event

INSERT INTO Fact.event
SELECT CONVERT (char(8),CAST(REPLACE(event_date,',','') AS DATETIME),112) as DateKey
,event_cost
,dv.event_ID
From stg.[event] ev
JOIN dim.Event dv
ON dv.event_ak = ev.event_ak
Where event_date is not NULL AND event_date <> ''

GO

USE [StudentDataMart]
GO

/****** Object:  StoredProcedure [Fact].[usp_loadstudentperformance]    Script Date: 2/17/2018 4:10:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [Fact].[usp_loadstudentperformance]
AS

TRUNCATE TABLE Fact.StudentPerformance


INSERT INTO Fact.StudentPerformance
        ( DateKey ,
         StudentID ,
          sat ,
         act ,
          high_school_gpa ,
         highschoolrank
        )
SELECT CONVERT (char(8),Start_Date,112) as DateKey,
       dstu.StudentID,
      sat, 
	  act,
	   high_school_gpa,
	 highschoolrank  
 FROM stg.student ostu
 JOIN Dim.Student dstu
 ON ostu.Student_AK = dstu.Student_AK
 
GO

