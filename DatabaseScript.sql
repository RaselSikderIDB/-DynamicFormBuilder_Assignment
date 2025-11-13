
CREATE DATABASE DynamicFormDB2; 
USE DynamicFormDB2;
GO

-- Tables
CREATE TABLE dbo.Forms (
    FormId INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(250) NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE dbo.FormFields (
    FieldId INT IDENTITY(1,1) PRIMARY KEY,
    FormId INT NOT NULL FOREIGN KEY REFERENCES dbo.Forms(FormId),
    Label NVARCHAR(250) NOT NULL,
    IsRequired BIT NOT NULL DEFAULT 0,
    SelectedOption NVARCHAR(100) NULL,
    SortOrder INT NOT NULL DEFAULT 0
);

CREATE TABLE dbo.FixedOptions (
    OptionId INT IDENTITY(1,1) PRIMARY KEY,
    OptionText NVARCHAR(200) NOT NULL
);

-- default options
INSERT INTO dbo.FixedOptions (OptionText) VALUES ('Option 1'), ('Option 2'), ('Option 3');


-- Stored procedures
CREATE PROCEDURE dbo.usp_InsertForm
    @Title NVARCHAR(250),
    @NewFormId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Forms (Title) VALUES (@Title);
    SET @NewFormId = SCOPE_IDENTITY();
END
GO

CREATE PROCEDURE dbo.usp_InsertFormField
    @FormId INT,
    @Label NVARCHAR(250),
    @IsRequired BIT,
    @SelectedOption NVARCHAR(100),
    @SortOrder INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.FormFields (FormId, Label, IsRequired, SelectedOption, SortOrder)
    VALUES (@FormId, @Label, @IsRequired, @SelectedOption, @SortOrder);
END
GO

CREATE PROCEDURE dbo.usp_GetFormsPaged
    @Start INT,
    @Length INT,
    @Search NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT FormId, Title, CreatedDate
    FROM dbo.Forms
    WHERE (@Search = '' OR Title LIKE '%' + @Search + '%')
    ORDER BY CreatedDate DESC
    OFFSET @Start ROWS FETCH NEXT @Length ROWS ONLY;
END
GO

CREATE PROCEDURE dbo.usp_GetFormById
    @FormId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FormId, Title, CreatedDate FROM dbo.Forms WHERE FormId = @FormId;
    SELECT FieldId, Label, IsRequired, SelectedOption, SortOrder
    FROM dbo.FormFields
    WHERE FormId = @FormId
    ORDER BY SortOrder, FieldId;
END
GO


