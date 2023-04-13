CREATE DATABASE layoff_management;
GO
USE Layoff_Management;
GO


/*User*/
CREATE TABLE [USER] (
  user_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  first_name VARCHAR(20) NOT NULL,
  last_name VARCHAR(20) NOT NULL,
  sex VARCHAR(10),
  address_street_name VARCHAR(50),
  address_state VARCHAR(50),
  address_country VARCHAR(56),
  zip_code INT,
  date_of_birth DATE,
  Age int,
  email VARCHAR(50) UNIQUE NOT NULL,
  CONSTRAINT email_chk CHECK (email LIKE '%@%.%' AND email NOT LIKE '@%' AND email NOT LIKE '%@%@%'),
  phone CHAR(10) UNIQUE NOT NULL,
  CONSTRAINT phone_chk CHECK (phone not like '%[^0-9]%'),
  user_password VARCHAR(400) NOT NULL,
  user_type VARCHAR(10) NOT NULL,
  CONSTRAINT user_type_chk CHECK (user_type IN ('E','R','J'))
);


/*COMPANY*/
CREATE TABLE COMPANY (
    company_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    company_name VARCHAR(50) UNIQUE NOT NULL,
    company_website VARCHAR(100) NOT NULL,
    company_industry VARCHAR(50) NOT NULL
);
 
/*Employee*/
CREATE TABLE EMPLOYEE (
    employee_user_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL FOREIGN KEY REFERENCES [USER](user_id),
    company_id INT NOT NULL FOREIGN KEY REFERENCES [COMPANY](company_id),
    employee_role VARCHAR(50) NOT NULL,
    employee_start_date DATE
);


/*Recruiter*/
CREATE TABLE RECRUITER (
    recruiter_user_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL FOREIGN KEY REFERENCES [USER](user_id),
    company_id INT NOT NULL FOREIGN KEY REFERENCES [COMPANY](company_id),
    recruiter_role VARCHAR(50) NOT NULL,
    recruiter_start_date DATE
);
 
/*JOB_SEEKER*/
CREATE TABLE JOB_SEEKER (
    job_seeker_user_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL FOREIGN KEY REFERENCES [USER](user_id),
    job_required_by DATE,
    visa_issue VARCHAR(5),
    CONSTRAINT visa_issue CHECK (visa_issue IN ('True', 'False', 'TRUE', 'FALSE')),
    dependent_count INT,
    summarize_job_isse VARCHAR(500)
);
 
/*School*/
CREATE TABLE SCHOOL (
    school_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    school_name VARCHAR(250) NOT NULL UNIQUE,
    school_address VARCHAR(250),
    ranking INT
);
 
/*Degree*/
CREATE TABLE DEGREE (
    degree_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    degree_title VARCHAR(255) UNIQUE,
    degree_level VARCHAR(50),
    degree_desc VARCHAR(500)
);
 
/*Education*/
CREATE TABLE EDUATION (
    user_id INT NOT NULL FOREIGN KEY REFERENCES [USER](user_id),
    school_id INT NOT NULL FOREIGN KEY REFERENCES [SCHOOL](school_id),
    degree_id INT NOT NULL FOREIGN KEY REFERENCES [DEGREE](degree_id),
    e_start_date DATE,
    e_end_date DATE,
    PRIMARY KEY (user_id, school_id, degree_id),
);


 
/*Teaches*/
CREATE TABLE TEACHES (
    school_id INT NOT NULL FOREIGN KEY REFERENCES [SCHOOL](school_id),
    degree_id INT NOT NULL FOREIGN KEY REFERENCES [DEGREE](degree_id),
    PRIMARY KEY (school_id, degree_id)
);
 
/*Job Opening*/
CREATE TABLE JOB_OPENING (
    job_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    job_title VARCHAR(20) NOT NULL,
    job_desc VARCHAR(500) NOT NULL,
    company_id INT NOT NULL FOREIGN KEY REFERENCES [COMPANY](company_id),
    posting_date DATE,
    yearly_salary INT NOT NULL,
    exp_domain VARCHAR(20) NOT NULL,
    exp_years INT NOT NULL
);
 
/*Skill*/
CREATE TABLE SKILL (
    skill_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    skill_title VARCHAR(20) NOT NULL,
    skill_type VARCHAR(20) NOT NULL,
    skill_desc VARCHAR(50) NOT NULL
);
 
/*Skills Required*/
CREATE TABLE SKILLS_REQUIRED (
    job_id INT NOT NULL FOREIGN KEY REFERENCES [JOB_OPENING](job_id),
    skill_id INT NOT NULL FOREIGN KEY REFERENCES [SKILL](skill_id),
    PRIMARY KEY (job_id, skill_id)
);
 
/*Possesses*/
CREATE TABLE POSSESSES (
    user_id INT NOT NULL FOREIGN KEY REFERENCES [USER](user_id),
    skill_id INT NOT NULL FOREIGN KEY REFERENCES [SKILL](skill_id),
    PRIMARY KEY (user_id, skill_id)
);
 
/*Experience*/
CREATE TABLE EXPERIENCE(
    user_id INT NOT NULL FOREIGN KEY REFERENCES [USER](user_id),
    company_id INT NOT NULL FOREIGN KEY REFERENCES [COMPANY](company_id),
    j_start_date DATE,
    j_end_date DATE,
    experience_role VARCHAR(50) NOT NULL,
    exp_role_responsibilities VARCHAR(500),
    experience_domain VARCHAR(50),
    PRIMARY KEY (user_id, company_id)
);
 
/*Degree_required*/
CREATE TABLE DEGREE_REQUIRED(
    degree_id INT NOT NULL FOREIGN KEY REFERENCES [DEGREE](degree_id),
    job_id INT NOT NULL FOREIGN KEY REFERENCES [JOB_OPENING](job_id),
    PRIMARY KEY (degree_id, job_id)
);
 
/*Application_Status*/
CREATE TABLE APPLICATION_STATUS(
    job_id INT NOT NULL FOREIGN KEY REFERENCES [JOB_OPENING](job_id),
    job_seeker_user_id INT NOT NULL FOREIGN KEY REFERENCES [JOB_SEEKER](job_seeker_user_id),
    recruiter_user_id INT NOT NULL FOREIGN KEY REFERENCES [RECRUITER](recruiter_user_id),
    application_status VARCHAR(10),
    application_date DATE,
    PRIMARY KEY (job_id, job_seeker_user_id, recruiter_user_id)
);

----Trigger ---

--- Trigger for Age 
CREATE TRIGGER CalculateAge
ON dbo.[user]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;


    UPDATE dbo.[user]
    SET Age = DATEDIFF(year, date_of_birth, GETDATE())
END

--Trigger for application update
CREATE OR ALTER TRIGGER dbo.APPLICATION_UPDATE
    ON dbo.APPLICATION_STATUS
    AFTER UPDATE
AS
BEGIN
    IF UPDATE(application_status)
    BEGIN
        DECLARE @job_seeker_user INT
        DECLARE @job INT
        DECLARE @company_id_recruiter INT
        DECLARE @status VARCHAR(15);
        SELECT @status = application_status, @job_seeker_user = job_seeker_user_id, @job = job_id from inserted;


        IF @status = 'Hired' OR @status = 'HIRED'
            BEGIN
                EXEC MoveHired @job_seeker_user, @job
            END
    END
END




--ENCRYPTION/DECRYPTION-----------------------------------------------------------------------------------------------------------------

CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'damg6210';
-- drop master key

-- very that master key exists
SELECT name KeyName,
  symmetric_key_id KeyID,
  key_length KeyLength,
  algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;


go
--Create a self signed certificate and name it InsuranceNo
CREATE CERTIFICATE UserPass  
   WITH SUBJECT = 'damg6210';  
GO  

-- drop CERTIFICATE InsuranceNo  

--Create a symmetric key  with AES 256 algorithm using the certificate
-- as encryption/decryption method

CREATE SYMMETRIC KEY UserPass_SM
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE UserPass;  
GO  
-- drop SYMMETRIC KEY InsuranceNo_SM


--Now we are ready to encrypt the password and also decrypt


-- Open the symmetric key with which to encrypt the data.  
OPEN SYMMETRIC KEY UserPass_SM  
   DECRYPTION BY CERTIFICATE UserPass;  


-- Encrypt the value in column Password  with symmetric  key, and default everyone with
-- a password of damg1234  
ALTER TABLE [USER] ADD encrypted_password VARBINARY(400);


UPDATE [USER] SET encrypted_password = EncryptByKey(Key_GUID('UserPass_SM'), CONVERT(varbinary, user_password));

select * from [USER]
-- First open the symmetric key with which to decrypt the data.  
OPEN SYMMETRIC KEY UserPass_SM  
   DECRYPTION BY CERTIFICATE UserPass;  


SELECT user_password, CONVERT(varchar, DecryptByKey(encrypted_password))
FROM [USER];

---Indexes---
-- INDEX for Company_id in Job opening
CREATE NONCLUSTERED INDEX Job_Opening_Company_Id ON JOB_OPENING(company_id);

-- INDEX for User_id and Company_id in Job Experience
CREATE NONCLUSTERED INDEX Experience_User_Id_Company_Id ON EXPERIENCE(user_id, company_id);

--INDEX for job_id and Skil_id in Skill_required 
CREATE NONCLUSTERED INDEX Skills_Required_Job_Id_Skill_Id ON SKILLS_REQUIRED(job_id, skill_id);

-----Stored Procedures ----

-- Stored Procedure fro Job Seekers who got the job

CREATE OR ALTER PROCEDURE MoveHired @job_seeker_user INT, @job INT
AS
BEGIN
    SELECT 'Hello';
    DECLARE @user_id_js INT;
    DECLARE @company_id INT;
    DECLARE @employee_role VARCHAR(20);


    SELECT @user_id_js = USER_ID FROM JOB_SEEKER WHERE  job_seeker_user_id = @job_seeker_user;
    SELECT @company_id = company_id, @employee_role = job_title FROM JOB_OPENING WHERE job_id = @job;


    INSERT INTO EMPLOYEE (user_id, company_id, employee_role, employee_start_date)
    VALUES (@user_id_js, @company_id, @employee_role, GETDATE());
    UPDATE [USER] SET user_type = 'E' WHERE user_id = @user_id_js;
    DELETE FROM JOB_SEEKER WHERE job_seeker_user_id = @job_seeker_user;
END

-- Stored Procedure for Job openings
CREATE PROCEDURE GetJobOpeningsByCompanyName
    @companyName VARCHAR(50)
AS
BEGIN
    SELECT j.job_id, j.job_title, j.job_desc, c.company_name, j.posting_date, j.yearly_salary, j.exp_domain, j.exp_years
    FROM JOB_OPENING j
    JOIN COMPANY c ON j.company_id = c.company_id
    WHERE c.company_name = @companyName;
END


EXEC GetJobOpeningsByCompanyName 'Amazon';

---Stored procedure To get Employee count by company 
CREATE PROCEDURE [dbo].[GetEmployeeCountByCompany]
    @companyName VARCHAR(50),
    @employeeCount INT OUTPUT
AS
BEGIN
    SELECT @employeeCount = COUNT(*)  
    FROM EMPLOYEE 
    WHERE company_id = (SELECT company_id FROM COMPANY WHERE company_name = @companyName) ;
END


DECLARE @employeeCount INT;
EXEC [dbo].[GetEmployeeCountByCompany] @companyName = 'Google', @employeeCount = @employeeCount OUTPUT;
SELECT @employeeCount;


------- VIEWS -------

-- Latest Jobs
CREATE VIEW [Latest_Jobs] AS
SELECT job_id, job_title, company_id, yearly_salary, exp_domain, exp_years
FROM dbo.JOB_OPENING
WHERE dbo.JOB_OPENING.posting_date >= DATEADD(day, -1, GETDATE())




-- Visa required job seekers
CREATE VIEW [Visa_required_jobseekers] AS
SELECT job_seeker_user_id, job_required_by, dependent_count, summarize_job_isse
FROM dbo.JOB_SEEKER
WHERE dbo.JOB_SEEKER.visa_issue = 'FALSE'




-- 2+ Years experience
CREATE VIEW [users_min_2year_exp] AS
SELECT user_id, company_id, experience_role, experience_domain,
   DATEDIFF(year, dbo.EXPERIENCE.j_start_date, dbo.EXPERIENCE.j_end_date) AS years_of_exp
FROM dbo.EXPERIENCE
WHERE DATEDIFF(year, dbo.EXPERIENCE.j_start_date, dbo.EXPERIENCE.j_end_date) >= 2;

---UDF---
 
CREATE FUNCTION dbo.GetExperienceYears(@user_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @experience_years INT;
    SELECT @experience_years = DATEDIFF(year, j_start_date,COALESCE(j_end_date, GETDATE()) )
    FROM EXPERIENCE
    WHERE user_id = @user_id;
    RETURN @experience_years;
END;


ALTER TABLE Experience 
ADD experience_years AS dbo.GetExperienceYears(user_id);
