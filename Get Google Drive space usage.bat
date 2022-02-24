@echo off
cls
pushd "%~dp0"

echo.
echo Getting drive space for user Google Drives
gam report users fields accounts:used_quota_in_mb,accounts:drive_used_quota_in_mb,accounts:gmail_used_quota_in_mb,accounts:gplus_photos_used_quota_in_mb>"%~dp0storage_usage.csv"

gam user fsisd.gam@fsisd.net update drivefile <Google Sheet> newfilename "Storage Reports" localfile "%~dp0storage_usage.csv" csvsheet id:<Sheet Tab ID>

echo.
echo Getting drive space for Google Shared Drives
gam redirect csv ./TeamDrives.csv print teamdrives fields id,name
gam redirect csv ./TeamDriveACLs.csv multiprocess csv ./TeamDrives.csv gam print drivefileacls "~id" fields emailaddress,role,type
python GetTeamDriveOrganizers.py TeamDriveACLs.csv TeamDrives.csv TeamDriveOrganizers.csv
gam redirect csv ./TeamDriveFiles.csv multiprocess csv ./TeamDriveOrganizers.csv matchfield organizers "^.+$" gam user "~organizers" print filelist select teamdriveid "~id" fields id,name,driveid,size
python GetTeamDriveCountsSize.py TeamDriveFiles.csv TeamDrives.csv TeamDriveCountsSize.csv
gam user fsisd.gam@fsisd.net update drivefile <Google Sheet> newfilename "Storage Reports" localfile "%~dp0TeamDriveCountsSize.csv" csvsheet id:<Sheet Tab ID>

popd
