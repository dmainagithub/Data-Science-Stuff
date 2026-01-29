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
--Step 2: Creating a temporary table to help retrieve the names in a folder
--***************************************************************************

CREATE TABLE #BackupFiles (
    FileName NVARCHAR(255)
);

INSERT INTO #BackupFiles
EXEC xp_cmdshell 'dir /b "D:\APHRC\DBs_Raw\Clinic_Link\clinic_backups_june_2025\*.bak"';

--***************************************************************************
--***************************************************************************
DELETE FROM #BackupFiles WHERE FileName IS NULL;

--***************************************************************************
--View what the server found
--***************************************************************************
SELECT * FROM #BackupFiles;




