$packageName = 'sql-express-adv'
$fileName = 'SETUP.exe'
$fileType = 'exe'

$config = @{
    ROLE                     = 'AllFeatures_WithDefaults'
    ENU                      = 'True'
    UIMODE                   = 'Normal'
    UPDATEENABLED            = 'False'
    USEMICROSOFTUPDATE       = 'False'
    UPDATESOURCE             = 'MU'
    FEATURES                 = 'SQLENGINE,REPLICATION,ADVANCEDANALYTICS,SQL_INST_MR,SQL_INST_MPY,SQL_INST_JAVA,FULLTEXT'
    X86                      = 'False'
    INSTANCENAME             = 'SQLEXPRESS'
    INSTALLSHAREDIR          = 'C:\Program Files\Microsoft SQL Server'
    INSTALLSHAREDWOWDIR      = 'C:\Program Files (x86)\Microsoft SQL Server'
    INSTANCEID               = 'SQLEXPRESS'
    SQLTELSVCACCT            = 'NT AUTHORITY\NETWORK SERVICE'
    SQLTELSVCSTARTUPTYPE     = 'Disabled'
    INSTANCEDIR              = 'C:\Program Files\Microsoft SQL Server'
    AGTSVCACCOUNT            = 'NT AUTHORITY\NETWORK SERVICE'
    SQLSVCACCOUNT            = 'NT AUTHORITY\NETWORK SERVICE'
    SQLSYSADMINACCOUNTS      = 'BUILTIN\Administrators'
    ADDCURRENTUSERASSQLADMIN = 'True'
    TCPENABLED               = '1'
    NPENABLED                = '1'
    EXTSVCACCOUNT            = 'NT AUTHORITY\NETWORK SERVICE'
    FTSVCACCOUNT             = 'NT AUTHORITY\NETWORK SERVICE'
}

Write-Host 'Building configuration...'
$param = Get-PackageParameters
foreach ($p in $param.GetEnumerator()) {
    if ($p.Name -in $config.Keys) {
        $config[$p.Name] = $p.Value
    }
}

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$fileLocation = Join-Path $toolsDir $fileName

Write-Host 'Writing configuration...'
$configContent = Invoke-EpsTemplate -Path (Join-Path $toolsDir 'config.eps') -Binding $config -Safe
Set-Content -Path (Join-Path $toolsDir 'config.ini') -Value $configContent

Write-Host 'Installing...'
$silentArgs = "/Q /IACCEPTSQLSERVERLICENSETERMS /ConfigurationFile=$(Join-Path $toolsDir 'config.ini')"
Install-ChocolateyInstallPackage `
    -PackageName $packageName `
    -FileType $fileType `
    -File64 $fileLocation `
    -SilentArgs $silentArgs