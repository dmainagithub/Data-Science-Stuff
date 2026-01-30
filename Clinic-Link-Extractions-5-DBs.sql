--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Name:     Daniel Maina Nderitu
--Date:     2026
--Purpose:  Dynamically data from multiple tables from 5 databases
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--TABLES TO EXTRACT
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE TABLE ClinicLinkMainDB.dbo.ExtractionTables (
    table_name SYSNAME PRIMARY KEY,
    where_clause NVARCHAR(MAX) NULL
);
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--SPECIFY THE TABLES TO EXTRACT
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO ClinicLinkMainDB.dbo.ExtractionTables (table_name, where_clause)
VALUES
('Individuals', NULL),
('Treatments', NULL),
('Visits', 'VisitDate >= ''2024-01-01''');
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
USE ClinicLinkMainDB;
GO

-- Table metadata: table name, key columns, dedupe mode
DECLARE @Tables TABLE (
    TableName SYSNAME,
    KeyColumns NVARCHAR(500),
    DedupeMode VARCHAR(10)
);

INSERT INTO @Tables VALUES
('Individuals', 'PatientId', 'KEY'),
('DataProfile', NULL, 'NONE'),
('DataSheet', NULL, 'NONE'),
('Treatments',  NULL, 'NONE'),
('Diagnoses',  NULL, 'NONE'),
('ViralLoads', NULL, 'NONE'),
('LookupCodes', NULL, 'NONE'),
('Matches', NULL, 'NONE'),
('VitalSigns', NULL, 'NONE'),
('LabResults', NULL, 'NONE');

-------------------------------------------------
-- VARIABLES
-------------------------------------------------
DECLARE @DBName SYSNAME;
DECLARE @TableName SYSNAME;
DECLARE @KeyCols NVARCHAR(500);
DECLARE @DedupeMode VARCHAR(10);

DECLARE @ColumnList NVARCHAR(MAX);
DECLARE @JoinCondition NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);

-------------------------------------------------
-- SOURCE DATABASE LIST
-------------------------------------------------
DECLARE SourceDBs CURSOR LOCAL FAST_FORWARD FOR
SELECT name
FROM sys.databases
WHERE name IN (
    'ClinicLinkage_ClinicLinkage_LLHC_2025_06_23',
    'ClinicLinkage_ClinicLinkage_KHC_2025_06_23',
    'ClinicLinkage_ClinicLinkage_MHC_2025_06_23',
    'ClinicLinkage_KochHC_23_June_2025',
    'ClinicLinkage_ClinicLinkage_BabaDogo_2025_06_23'
);

-------------------------------------------------
-- TABLE METADATA CURSOR
-------------------------------------------------
DECLARE TableCursor CURSOR LOCAL FAST_FORWARD
FOR SELECT TableName, KeyColumns, DedupeMode FROM @Tables;

-------------------------------------------------
-- START PROCESS
-------------------------------------------------
OPEN SourceDBs;
FETCH NEXT FROM SourceDBs INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '====================================';
    PRINT 'Processing database: ' + @DBName;

    OPEN TableCursor;
    FETCH NEXT FROM TableCursor INTO @TableName, @KeyCols, @DedupeMode;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '--- Table: ' + @TableName + ' | Mode: ' + @DedupeMode;

        -------------------------------------------------
        -- Get column list dynamically
        -------------------------------------------------
        SELECT @ColumnList = STUFF((
        SELECT ',' + QUOTENAME(COLUMN_NAME)
        FROM ClinicLinkMainDB.INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = @TableName
        FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 1, '');


        -------------------------------------------------
        -- Build dedupe condition
        -------------------------------------------------
        SET @JoinCondition = NULL;

        IF @DedupeMode = 'KEY'
        BEGIN
            SELECT @JoinCondition = STRING_AGG(
                'd.' + QUOTENAME(value) + ' = s.' + QUOTENAME(value),
                ' AND '
            )
            FROM ClinicLinkMainDB.dbo.SplitString(@KeyCols, ',');
        END
        ELSE IF @DedupeMode = 'ROW'
        BEGIN
            SELECT @JoinCondition = STUFF((
            SELECT ' AND ISNULL(d.' + QUOTENAME(COLUMN_NAME) + ','''') = ISNULL(s.' + QUOTENAME(COLUMN_NAME) + ','''')'
            FROM ClinicLinkMainDB.INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = @TableName
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 5, '');

        END

        -------------------------------------------------
        -- Build INSERT statement
        -------------------------------------------------
        SET @SQL = '
INSERT INTO ClinicLinkMainDB.dbo.' + QUOTENAME(@TableName) + ' (
    ' + @ColumnList + '
)
SELECT
    ' + @ColumnList + '
FROM [' + @DBName + ']..' + QUOTENAME(@TableName) + ' s
';

        IF @DedupeMode <> 'NONE'
        BEGIN
            SET @SQL += '
WHERE NOT EXISTS (
    SELECT 1
    FROM ClinicLinkMainDB.dbo.' + QUOTENAME(@TableName) + ' d
    WHERE ' + @JoinCondition + '
)';
        END

        SET @SQL += ';';

        -------------------------------------------------
        -- Execute
        -------------------------------------------------
        PRINT @SQL;  -- Optional: for debugging
        EXEC sp_executesql @SQL;

        PRINT 'Rows inserted: ' + CAST(@@ROWCOUNT AS VARCHAR(20));

        FETCH NEXT FROM TableCursor INTO @TableName, @KeyCols, @DedupeMode;
    END

    CLOSE TableCursor;
    FETCH NEXT FROM SourceDBs INTO @DBName;
END

-------------------------------------------------
-- Cleanup
-------------------------------------------------
DEALLOCATE TableCursor;
CLOSE SourceDBs;
DEALLOCATE SourceDBs;

PRINT '===== LOAD COMPLETE =====';
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------

