-- Query #1
SELECT pr.reportid AS ReportID,
	   reportdate AS ReportDate,
	   completedate AS CompleteDate,
	   pr.description AS ProblemDescription,
	   testid AS TestID,
	   TestDate
FROM pProblemReport AS pr
INNER JOIN pTest 
ON pTest.reportid=pr.reportid
WHERE testdate < reportdate
 
--Query #2
CREATE VIEW vCoIR AS
SELECT typeid,
       COUNT(typeid) AS CountofInjuryReports
FROM pProblemReport
where injury='Yes'
GROUP BY typeid

CREATE VIEW vCoR AS
SELECT typeid,
	   COUNT(typeid) AS CountofReports
FROM pProblemReport
GROUP BY typeid

SELECT ProblemTypeID,
	   description AS TypeDescription,
	   isNull(CountofReports,0) AS CountOfReports,
	   isNull(CountofInjuryReports,0) AS CountOfInjuryReports
FROM pProblemType
LEFT OUTER JOIN vCOR 
ON problemtypeid=vcor.typeid
LEFT OUTER JOIN vCoIR
ON problemtypeid=vcoir.typeid
 
--Query #3 
SELECT CONVERT(varchar,reportdate, 107) AS ReportDateOutput,
	   ReportID,
	   pr.serialnumber AS Serial#,
	   isNULL(CONVERT(varchar,CompleteDate, 107), 'Not Complete') AS CompleteDate,
	   CASE
			WHEN completedate IS NULL THEN DATEDIFF(DAY, reportdate, GETDATE()) 
			ELSE DATEDIFF(day, reportdate, completedate)
	   END AS DaysInSystem,
	   m.modelnumber AS Model#,
	   ModelName,
	   lastname + ', '+SUBSTRING(firstname, 1,1) +'.' AS ReporterName,
	   CASE
			WHEN persontype='C' THEN 'Customer'
			WHEN persontype='D' THEN 'Distributor'
			ELSE 'Employee'
	   END AS ReporterType,
	   pt.description AS ProblemType
FROM pProblemReport pr
LEFT OUTER JOIN pToy t
ON t.serialnumber=pr.serialnumber
LEFT OUTER JOIN pModel m
ON m.modelnumber=t.modelnumber
LEFT OUTER JOIN pPerson p
ON p.personid=pr.reporterid
LEFT OUTER JOIN pProblemType pt
ON pt.problemtypeid=pr.typeid
WHERE reportdate BETWEEN '2020-10-01' AND '2020-10-31'
ORDER BY ReportDateOutput
 
--Query #4 
CREATE VIEW vTesters AS
SELECT testid,
	   lastname + ', '+SUBSTRING(firstname, 1,1) +'.' AS TesterName
FROM pTest as t
INNER JOIN pPerson as p
ON t.testerid=p.personid

SELECT CONVERT(varchar,reportdate, 107) AS ReportDateOutput,
	   pr.ReportID,
	   pr.serialnumber AS Serial#,
	   isNULL(CONVERT(varchar,CompleteDate, 107), 'Not Complete') AS CompleteDate,
	   CASE
			WHEN completedate IS NULL THEN DATEDIFF(DAY, reportdate, GETDATE()) 
			ELSE DATEDIFF(day, reportdate, completedate)
	   END AS DaysInSystem,
	   m.modelnumber AS Model#,
	   ModelName,
	   lastname + ', '+SUBSTRING(firstname, 1,1) +'.' AS ReporterName,
	   CASE
			WHEN persontype='C' THEN 'Customer'
			WHEN persontype='D' THEN 'Distributor'
			ELSE 'Employee'
	   END AS ReporterType,
	   CONVERT(VARCHAR, testdate, 107) AS TestDate,
	   ts.description AS TestDescription,
	   TesterName,
	   complete AS TestComplete
FROM pProblemReport pr
LEFT OUTER JOIN pToy t
ON t.serialnumber=pr.serialnumber
LEFT OUTER JOIN pModel m
ON m.modelnumber=t.modelnumber
LEFT OUTER JOIN pPerson p
ON p.personid=pr.reporterid
LEFT OUTER JOIN pProblemType pt
ON pt.problemtypeid=pr.typeid
LEFT OUTER JOIN pTest ts
ON ts.reportid=pr.reportid
LEFT OUTER JOIN vTesters vt
ON vt.testid=ts.testid
WHERE reportdate BETWEEN '2020-10-01' AND '2020-10-31'
ORDER BY ReportDateOutput
 
--Query #5 
CREATE VIEW vCoT AS
SELECT reportid,
	   COUNT(reportid) AS CountOfTests
FROM pTest
GROUP BY reported
SELECT pr.ReportID,
	   CONVERT(varchar,reportdate, 107) AS ReportDateOutput,
	   pr.serialnumber AS Serial#,
	   isNULL(CONVERT(varchar,CompleteDate, 107), 'Not Complete') AS CompleteDate,
	   CASE
			WHEN completedate IS NULL THEN DATEDIFF(DAY, reportdate, GETDATE()) 
			ELSE DATEDIFF(day, reportdate, completedate)
	   END AS DaysInSystem,
	   m.modelnumber AS Model#,
	   ModelName,
	   lastname + ', '+SUBSTRING(firstname, 1,1) +'.' AS ReporterName,
	   CASE
			WHEN persontype='C' THEN 'Customer'
			WHEN persontype='D' THEN 'Distributor'
			ELSE 'Employee'
	   END AS ReporterType,
	   isNull(CountOfTests,0) as CountOfTests
FROM pProblemReport pr
LEFT OUTER JOIN pToy t
ON t.serialnumber=pr.serialnumber
LEFT OUTER JOIN pModel m
ON m.modelnumber=t.modelnumber
LEFT OUTER JOIN pPerson p
ON p.personid=pr.reporterid
LEFT OUTER JOIN pProblemType pt
ON pt.problemtypeid=pr.typeid
LEFT OUTER JOIN vCoT ct
ON ct.reportid=pr.reportid
ORDER BY CONVERT(INT,pr.reportid)
 
 
--Query #6 
SELECT pr.ReportID,
	   CONVERT(varchar,reportdate, 107) AS ReportDateOutput,
	   pr.serialnumber AS Serial#,
	   isNULL(CONVERT(varchar,CompleteDate, 107), 'Not Complete') AS CompleteDate,
	   CASE
			WHEN completedate IS NULL THEN DATEDIFF(DAY, reportdate, GETDATE()) 
			ELSE DATEDIFF(day, reportdate, completedate)
	   END AS DaysInSystem,
	   m.modelnumber AS Model#,
	   ModelName,
	   lastname + ', '+SUBSTRING(firstname, 1,1) +'.' AS ReporterName,
	   CASE
			WHEN persontype='C' THEN 'Customer'
			WHEN persontype='D' THEN 'Distributor'
			ELSE 'Employee'
	   END AS ReporterType,
	   isNull(CountOfTests,0) as CountOfTests
FROM pProblemReport pr
LEFT OUTER JOIN pToy t
ON t.serialnumber=pr.serialnumber
LEFT OUTER JOIN pModel m
ON m.modelnumber=t.modelnumber
LEFT OUTER JOIN pPerson p
ON p.personid=pr.reporterid
LEFT OUTER JOIN pProblemType pt
ON pt.problemtypeid=pr.typeid
LEFT OUTER JOIN vCoT ct
ON ct.reportid=pr.reportid
WHERE completedate IS NUll AND CountOfTests IN (SELECT MAX(countoftests) FROM vCoT)
ORDER BY CONVERT(INT,pr.reportid)
 
--Query #7
CREATE VIEW vCR AS 
SELECT m.modelnumber,
	   COUNT(reportid) AS CountofReports
FROM pProblemReport pr
LEFT OUTER JOIN pToy t
ON t.serialnumber=pr.serialnumber
LEFT OUTER JOIN pModel m
ON t.modelnumber=m.modelnumber
GROUP BY m.modelnumber
CREATE VIEW vCIR AS
SELECT m.modelnumber,
	   COUNT(reportid) AS CountofInjuryReports
FROM pProblemReport pr
LEFT OUTER JOIN pToy t
ON t.serialnumber=pr.serialnumber
LEFT OUTER JOIN pModel m
ON t.modelnumber=m.modelnumber
WHERE pr.injury='Yes'
GROUP BY m.modelnumber
CREATE VIEW vModelReportDates AS
SELECT m.modelnumber,
	   MAX(reportdate) recent,
	   MIN(reportdate) earliest
FROM pModel AS m
LEFT OUTER JOIN pToy t
ON t.modelnumber=m.modelnumber
LEFT OUTER JOIN pProblemReport pr
ON pr.serialnumber=t.serialnumber
GROUP BY m.modelnumber
CREATE VIEW vModelTestCt AS
SELECT m.modelnumber,
	   COUNT(testid) AS CountofTests
FROM pModel m
LEFT OUTER JOIN pToy t
ON t.modelnumber=m.modelnumber
LEFT OUTER JOIN pProblemReport pr
ON pr.serialnumber=t.serialnumber
LEFT OUTER JOIN pTest ts
ON ts.reportid=pr.reportid
GROUP BY m.modelnumber

CREATE VIEW vModelTestDates AS 
SELECT m.modelnumber,
	   MAX(testdate) recenttest,
	   MIN(testdate) earliesttest
FROM pModel m
LEFT OUTER JOIN pToy t
ON t.modelnumber=m.modelnumber
LEFT OUTER JOIN pProblemReport pr
ON pr.serialnumber=t.serialnumber
LEFT OUTER JOIN pTest ts
ON ts.reportid=pr.reportid
GROUP BY m.modelnumber

SELECT m.ModelNumber,
	   ModelDescription,
	   isNull(CountOfReports,0) AS CountOfReports,
	   isNULL(Countofinjuryreports,0) AS CountOfInjuryReports,
	   isNull(CONVERT(VARCHAR, recent, 107), 'n/a') AS MostRecentReportDate,
	   isNull(CONVERT(VARCHAR, earliest, 107), 'n/a') AS EarliestReportDate,
	   CountOfTests,
	   isNull(CONVERT(VARCHAR, recenttest, 107), 'n/a') AS MostRecentTestDate,
	   isNull(CONVERT(VARCHAR, earliesttest, 107), 'n/a') AS EarliestTestDate
FROM pModel m
LEFT OUTER JOIN vCR as cr
ON m.modelnumber=cr.modelnumber
LEFT OUTER JOIN vCIR as ci
ON ci.modelnumber=m.modelnumber
LEFT OUTER JOIN vModelReportDates mpd
ON m.modelnumber=mpd.modelnumber
LEFT OUTER JOIN vModelTestCt mtc
ON mtc.modelnumber=m.modelnumber
LEFT OUTER JOIN vModelTestDates mtd
ON mtd.modelnumber=m.modelnumber
ORDER BY m.modelnumber
