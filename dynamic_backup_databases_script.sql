--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Name: Daniel Maina Nderitu
--Date: 2026
--Purpose:  Dynamically backup databases you want
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DECLARE @DBName SYSNAME;
DECLARE @SQL NVARCHAR(MAX);
DECLARE @BackupPath NVARCHAR(4000);
DECLARE @Today CHAR(8);

-- Date suffix: YYYYMMDD
SET @Today = CONVERT(CHAR(8), GETDATE(), 112);

-- Cursor over selected databases
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

OPEN SourceDBs;
FETCH NEXT FROM SourceDBs INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Build backup file path
    SET @BackupPath = 
        'D:\APHRC\DBs_Raw\Clinic_Link\Clinic_Link_processed_2026\' + @DBName + '_processed_' + @Today + '.bak';

    -- Build BACKUP DATABASE command
    SET @SQL = '
    BACKUP DATABASE ' + QUOTENAME(@DBName) + '
    TO DISK = ''' + @BackupPath + '''
    WITH
        INIT,
        COMPRESSION,
        STATS = 10;
    ';

    PRINT 'Backing up database: ' + @DBName;
    PRINT @SQL;

    EXEC (@SQL);

    FETCH NEXT FROM SourceDBs INTO @DBName;
END

CLOSE SourceDBs;
DEALLOCATE SourceDBs;
