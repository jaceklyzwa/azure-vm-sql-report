# azure-vm-sql-report
PowerShell script and Power BI report for reporting Azure VM and Azure SQL VM licensing info

# Prerequisites
1. An Azure Subscription(s)
2. PowerShell
3. Power BI Desktop: https://powerbi.microsoft.com/en-us/desktop/
4. Enable the Automatic Registration of the Azure SQL Server IaaS Agent extension. This is required to extract SQL Licensing and version information and can be enabled using the following PowerShell script: https://github.com/jaceklyzwa/tigertoolbox/blob/master/AzureSQLVM/RegisterSubscriptionsToSqlVmAutomaticRegistration.ps1

# Steps

1. Download/extract the folder GetVMSQLInfo.
2. Run the PowerShell script Get-VM-SQL-Info.ps1
3. Once the PowerShell has successfully run, you should have 3 CSV files in the GetVMSQLInfo folder: VMInfo.csv, SQLVMInfo.csv and VMSizeInfo.csv.
4. Open the Power BI Desktop File Azure VM SQL Info Report.pbix.
5. Click the Refresh button in Power BI Desktop to load the report data.
