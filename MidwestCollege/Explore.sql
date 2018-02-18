  
  USE StudentDataMart
  GO

  
  SELECT TOP 5
            Event_name ,
            SUM(Donation_Amount) AS Donation_Amount
  FROM      [Fact].[Donation] dd
            JOIN Dim.Event ee ON dd.event_id = ee.event_ID
            JOIN Dim.Date_Day_Year da ON da.datekeySK = dd.datekey
  GROUP BY  Event_name
  ORDER BY  Donation_Amount DESC;


  SELECT TOP 5
            Event_Department ,
            SUM(Donation_Amount) AS Donation_Amount
  FROM      [Fact].[Donation] dd
            JOIN Dim.Event ee ON dd.event_id = ee.event_ID
            JOIN Dim.Date_Day_Year da ON da.datekeySK = dd.datekey
  GROUP BY  Event_Department
  ORDER BY  Donation_Amount DESC;



  --Drill Down

  SELECT    QuarterName
 --,MonthName
            ,
            SUM(Donation_amount) AS Donation_Amount
  FROM      [Fact].[Donation] dd
            JOIN Dim.Event ee ON dd.event_id = ee.event_ID
            JOIN Dim.Date_Day_Year da ON da.datekeySK = dd.datekey
  GROUP BY  QuarterName
   -- ,MonthName
  ORDER BY  Donation_Amount DESC;

  --Scale
