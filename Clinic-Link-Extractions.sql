--***************************************************************************
--***************************************************************************
--Author:     Daniel Maina Nderitu
--Project:    MADIVA - Clinic Link Work
--Year:       2026
--Purpose:    An sql script to help retrieve names of databases in a folder
--***************************************************************************
--Step 1: Changing some configuration options
--***************************************************************************
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

--***************************************************************************
--Step 2: Create and populate the temp table
--***************************************************************************

CREATE TABLE #BackupFiles (
    FileName NVARCHAR(255)
);

INSERT INTO #BackupFiles
EXEC xp_cmdshell 'dir /b "D:\APHRC\DBs_Raw\Clinic_Link\clinic_backups_june_2025\*.bak"';

--DELETE FROM #BackupFiles
--WHERE FileName IS NULL
--   OR FileName = 'Clinic_Linkage_leanDB_no_encryption_tables.bak';
--***************************************************************************
--***************************************************************************
DELETE FROM #BackupFiles WHERE FileName IS NULL;

--***************************************************************************
--View what the server found
--***************************************************************************
SELECT * FROM #BackupFiles;

--***************************************************************************
--Step 3: Database Restoration Happens Here
--***************************************************************************
DECLARE @FileName NVARCHAR(255);
DECLARE @DbName   NVARCHAR(255);
DECLARE @SQL      NVARCHAR(MAX);

DECLARE bak_cursor CURSOR FOR
SELECT FileName FROM #BackupFiles;

OPEN bak_cursor;
FETCH NEXT FROM bak_cursor INTO @FileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Create a clean database name
    SET @DbName = 'ClinicLinkage_' + REPLACE(REPLACE(@FileName, '.bak', ''), '-', '_');

    SET @SQL = '
    RESTORE DATABASE ' + QUOTENAME(@DbName) + '
    FROM DISK = ''D:\APHRC\DBs_Raw\Clinic_Link\clinic_backups_june_2025\' + @FileName + '''
    WITH
        MOVE ''NkatekoTrial''      TO ''D:\live_DBs\DATA\' + @DbName + '.mdf'',
        MOVE ''NkatekoTrial_log''  TO ''D:\live_DBs\DATA\' + @DbName + '_log.ldf'',
        REPLACE,
        RECOVERY;
    ';

    PRINT @SQL;     -- ALWAYS preview first
    EXEC (@SQL); -- uncomment when satisfied

    FETCH NEXT FROM bak_cursor INTO @FileName;
END

CLOSE bak_cursor;
DEALLOCATE bak_cursor;

--***************************************************************************
--Step 5: Check the state of the restored databases
--***************************************************************************
SELECT
    name,
    state_desc,
    recovery_model_desc
FROM sys.databases
WHERE name LIKE '%Clinic%';
--***************************************************************************
--***************************************************************************
SELECT
    r.session_id,
    r.command,
    r.status,
    r.percent_complete,
    r.start_time,
    r.estimated_completion_time / 60000 AS minutes_remaining
FROM sys.dm_exec_requests r
WHERE r.command LIKE 'RESTORE%';
--***************************************************************************
--***************************************************************************
--Check current restore status
SELECT
    name,
    state_desc
FROM sys.databases
ORDER BY name;
--***************************************************************************
--***************************************************************************
SELECT
    session_id,
    command,
    percent_complete,
    estimated_completion_time / 60000 AS minutes_remaining
FROM sys.dm_exec_requests
WHERE command LIKE 'RESTORE%';

--***************************************************************************
--Safely clean a not Fully Restored DB
--***************************************************************************
ALTER DATABASE ClinicLinkage_LLHC_23rd_June_2025
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

DROP DATABASE ClinicLinkage_LLHC_23rd_June_2025;
--***************************************************************************
--Restore one database at a time with progress feedback
--***************************************************************************
RESTORE DATABASE ClinicLinkage_ClinicLinkage_LLHC_2025_06_23
FROM DISK = 'D:\APHRC\DBs_Raw\Clinic_Link\clinic_backups_june_2025\LLHC_23rd_June_2025.bak'
WITH
    MOVE 'NkatekoTrial'     TO 'D:\live_DBs\DATA\ClinicLinkage_ClinicLinkage_LLHC_2025_06_23.mdf',
    MOVE 'NkatekoTrial_log' TO 'D:\live_DBs\DATA\ClinicLinkage_ClinicLinkage_LLHC_2025_06_23.ldf',
    REPLACE,
    STATS = 5,
    RECOVERY;
--***************************************************************************
--Hardened FINAL script (future-proof)
--***************************************************************************
SET NOCOUNT ON;

DECLARE @FileName NVARCHAR(255);
DECLARE @DbName   NVARCHAR(255);
DECLARE @SQL      NVARCHAR(MAX);

DECLARE bak_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT FileName
FROM #BackupFiles
ORDER BY FileName;

OPEN bak_cursor;
FETCH NEXT FROM bak_cursor INTO @FileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @DbName = REPLACE(REPLACE(@FileName, '.bak', ''), '-', '_');

    PRINT 'Restoring ' + @DbName;

    SET @SQL = '
    RESTORE DATABASE ' + QUOTENAME(@DbName) + '
    FROM DISK = ''D:\APHRC\DBs_Raw\Clinic_Link\clinic_backups_june_2025\' + @FileName + '''
    WITH
        MOVE ''NkatekoTrial''     TO ''D:\live_DBs\DATA\' + @DbName + '.mdf'',
        MOVE ''NkatekoTrial_log'' TO ''D:\live_DBs\DATA\' + @DbName + '_log.ldf'',
        REPLACE,
        STATS = 10,
        RECOVERY;
    ';

    EXEC (@SQL);   -- waits until restore completes

    FETCH NEXT FROM bak_cursor INTO @FileName;
END

CLOSE bak_cursor;
DEALLOCATE bak_cursor;
--***************************************************************************
--Quick integrity check
--***************************************************************************
DBCC CHECKDB('ClinicLinkage_BabaDogo_2025_06_23') WITH NO_INFOMSGS;
DBCC CHECKDB('ClinicLinkage_ClinicLinkage_KHC_2025_06_23') WITH NO_INFOMSGS;
DBCC CHECKDB('ClinicLinkage_ClinicLinkage_LLHC_2025_06_23') WITH NO_INFOMSGS;
DBCC CHECKDB('ClinicLinkage_ClinicLinkage_MHC_2025_06_23') WITH NO_INFOMSGS;
DBCC CHECKDB('ClinicLinkage_KochHC_23_June_2025') WITH NO_INFOMSGS;
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************
--***************************************************************************



