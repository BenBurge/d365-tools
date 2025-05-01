## How to setup a new cloud-hosted development VM

### Create the new development VM
1. Go to LCS > Cloud Hosted Environments.
2. Click on Add at the top of the page.
3. Select the latest version (should be selected by default)
4. Select DevTest as the enviornment topology
5. Select Finance and Operations - Develop
6. Provide a name for the enviornment
7. Select advanced settings:
  * Under customize SQL Database Configuration select “None” for the AX Database type
  * Under Customize virtual machine names, use the same name as the environment.
  * Under Customize virtual network, use New virtual network, and give it the machine name + network. Ex. Afs-dev1-network
  * Hit “done”
8. For the virtual machine, size column, select D13 v2
9. Select the check box to agree to create the new virtual machine.
10. Hit “Next”
11. You’re new VM will now be created; which can take a little time.
---
### Refresh Stage with Production
1. Go to the Stage enviornment for D365 in LCS
2. Under the maintain menu, select move database
3. Click Refresh Database from the options
4. Source should be production
5. Ensure target enviornment is the stage environment
6. Click the checkbox, and then submit
---
### Export Data from Stage
1. Go to the Stage enviornment for D365 in LCS
2. Under the maintain menu, select export database
3. Click the checkbox, and click submit
4. This will place a bacpac file in your assets library under database backups in LCS. You can access it through the hamburger menu at the top of the page.
---
### Download Data into the Dev Enviornment
1. In your development VM go to LCS.
2. Head into the assets library and download the latest bacpac file from database backups. You can access it through the hamburger menu at the top of the page.
3. Download the bacpac and place it anywhere on your machine. Recommended to place it the MSSQL Backup drive.
---
### Setup Data and Code
1. Make sure you have downloaded the scripts from this repository onto your dev machine.
2. Add Visual Studio to your taskbar
3. Right click it on the task bar, then right click the name Visual Studio in the context menu, then properties
4. Go to advanced and check teh Run as Administrator
5. Next, open PowerShell as an Administrator
6. Go into the scripts folder you downloaded
7. Run 01-stop-services.ps1
8. Next, run 02-import-sql.ps1. It should ask you for the location of your bacpac file and may download the sql importer app if it's not installed. This step can take 24-48 hours to complete.
9. Open SSMS
10. In SSMS run 03-modify-new-axdb.sql
11. In SSMS run 04-replace-old-db.sql
12. In SSMS run 05-enable-users.sql
13. Create a backup of your new database AxDB_New. This is to make sure we don't have to wait for the indexes to build again if we mess up the next steps
14. In PowerShell run 06-start-services.ps1
15. Open Visual Studio as an Administrator (Or via the taskbar if you followed steps 2-4.
16. Clone your D365 repository. In our case we will be using Azure DevOps.
17. Open the Team Explorer panel and click on the workspace listed, then click Manage Workspaces
18. Ensure that your metadata for your development folder is mapped to K:\AosService\PackagesLocalDirectory\
19. Make sure your projects for your development folder is mapped to C:\Users\[YourAccount]\source\repos
20. Next, from Visual Studio, go to Extensions in the top bar and select Dynamics 365 > Build Models and build all models.
21. If you have any errors, STOP! You need to figure out how to resolve those errors before continuing.
22. If you do NOT have any errors, go to Extensions in the top bar and select Dynamics 365 > Synchronize Database
23. Confirm your custom tables are found in the database via SSMS. If not, restore your backup your created and start over again.
24. You should now be ready to start developing.
