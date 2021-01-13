    Write-Host "Please login to the account which has access to the Azure subscriptions `n";
    $Output = Connect-AzAccount -ErrorAction Stop;

    Write-Host "Getting available subscriptions `n"
    $Subscriptions = Get-AzSubscription

    $VMsInfo=@()
    $SQLVMInfo=@()
    $locations=@()
    $VMSizeInfo=@()
    $VMSizes=@()


    foreach ($Subscription in $Subscriptions) {


       
       Set-AzContext $Subscription | Out-Null
       $SubscriptionName = $Subscription.Name
       $SubscriptionId = $Subscription.Id

       
        Write-Host "Retrieving existing VMs in subscription $SubscriptionName `n"
        $VMNames = $(Get-AzVM).Name

        Write-Host $VMNames.Count"VMs found in subscription $SubscriptionName `n"
        

        try
        {
            Write-Host "Reviewing info for each VM`n"

            foreach ($VMName in $VMNames) {

                $VM = Get-AzVM -Name $VMName                
                $Nic = $VM.NetworkProfile.NetworkInterfaces.Id.Split("/") | Select -Last 1
                $vip = $(Get-AzNetworkInterface -Name $Nic).IpConfigurations.PrivateIpAddress

                If ($locations -notcontains $VM.Location)
                {
                     $locations += $VM.Location
                 }

                  If ($VMSizes -notcontains $VM.HardwareProfile.VmSize)
                  {
                  $VMSizes += $VM.HardwareProfile.VmSize;
                  }

                $VMsInfo += @{VirtualMachineId=$VM.Id;LicenseType=$VM.LicenseType;Location=$VM.Location;SubscriptionName=$SubscriptionName;SubscriptionId=$SubscriptionID;Name=$VMName;ResourceGroupName=$VM.ResourceGroupName;Size=$VM.HardwareProfile.VmSize;
                            PrivateIpAddress=$vip;ResourceType=$VM.Type;OsType=$VM.StorageProfile.OsDisk.OsType;OsName=$VM.StorageProfile.ImageReference.Offer;
                            OsEdition=$VM.StorageProfile.ImageReference.sku;OsVersion=$VM.StorageProfile.ImageReference.Version} | foreach-object { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }

            }

                    }
        catch
        {
            Write-Output $_.Exception
            throw "Exception retrieving VM license type information `n"
        }

           
        Write-Host "Retrieving existing SQL VMs in subscription $SubscriptionName `n"
        $SQLVMs = Get-AzSqlVM

        Write-Host $SQLVMs.Count"SQL VMs found in subscription $SubscriptionName `n"
        

        try
        {
            Write-Host "Reviewing info for each SQL VM`n"

            foreach ($SQLVM in $SQLVMs) {

                
                $SQLVMInfo += @{LicenseType=$SQLVM.LicenseType;SubscriptionName=$SubscriptionName;SubscriptionId=$SubscriptionId;Name=$SQLVM.Name;ResourceGroupName=$SQLVM.ResourceGroupName;Offer=$SQLVM.Offer;
                            Sku=$SQLVM.Sku;SqlManagementType=$SQLVM.SqlManagementType;Location=$SQLVM.Location;SQLVirtualMachineGroup=$SQLVM.SqlVirtualMachineGroup;VirtualMachineId=$SQLVM.VirtualMachineId} | foreach-object { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }

            }

                    }
        catch
        {
            Write-Output $_.Exception
            throw "Exception retrieving SQL license type information `n"
        }
           
       

    }


    foreach ($location in $locations) {
    $VMSizeList=Get-AzVMSize -Location $location
    foreach ($VMSize in $VMSizeList)
    {

    If ($VMSizes -contains $VMSize.Name)
                {
                
                     $VMSizeInfo += @{Name=$VMSize.Name;NumberOfCores=$VMSize.NumberOfCores} | foreach-object { New-Object object | Add-Member -NotePropertyMembers $_ -PassThru }

                 }
                 }
    
    }

     Write-Host "VMs Info: `n"
           
           
           $VMsInfo.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize -Wrap
            Write-Host "Exporting copy of the output data to a CSV file in the current directory `n"
            $VMsInfo | Export-Csv -Path ".\VMInfo.csv"

            $SQLVMInfo.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize -Wrap
            Write-Host "Exporting copy of the output data to a CSV file in the current directory `n"
            $SQLVMInfo | Export-Csv -Path ".\SQLVMInfo.csv"

$VMSizeInfo.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize -Wrap
            Write-Host "Exporting copy of the output data to a CSV file in the current directory `n"
            $VMSizeInfo | Export-Csv -Path ".\VMSizeInfo.csv"

