param (
    [parameter(Mandatory = $false)] [System.String] $removeLock = "False",
    [parameter(Mandatory = $false)] [System.String] $newLock = "False",
    [parameter(Mandatory = $false)] [System.String] $ResourceGroupName = "rg-name-here",
    [parameter(Mandatory = $false)] [System.String] $LockLevel = "CanNotDelete",#CanNotDelete / ReadOnly
    [parameter(Mandatory = $false)] [System.String] $LockNotes = "Azure-DevOps-Pipeline",
    [parameter(Mandatory = $false)] [System.String] $LockName = "lock-name-here"
    )

function RemoveAzResourceLock {
    param(
        [System.String] $ResourceGroupName
    )
    $AzResourceLock = Get-AzResourceLock -ResourceGroupName $ResourceGroupName -AtScope
    # verify if exists an resource lock
    if (!$AzResourceLock) {
        Write-Host "There is no Resource Lock for Resource Group: " $ResourceGroupName
        $return = $false
        $return = $return | Select-Object @{Name = 'Removed';Expression = {$_}}

        $NewAzResourceLock = "False"

        Write-Host "##vso[task.setvariable variable=NewAzResourceLock;]$NewAzResourceLock"

        return $return
    } else {
        $RemoveAzResourceLock = Remove-AzResourceLock -ResourceGroupName $AzResourceLock.ResourceGroupName -LockName $AzResourceLock.Name -Force
        Write-Host "Resource Lock Removed? " $RemoveAzResourceLock
        $return = $AzResourceLock | Select-Object Name, @{Name = 'Level';Expression = {"$($_.Properties.level)"}}, @{Name = 'Notes';Expression = {"$($_.Properties.notes)"}}, @{Name = 'Removed';Expression = {"True"}}

        $ResourceGroupName = $AzResourceLock.ResourceGroupName
        $NewAzResourceLock = "True"
        $LockLevel = $AzResourceLock.Properties.level
        $LockNotes = $AzResourceLock.Properties.notes ? $AzResourceLock.Properties.notes : "Azure-DevOps-Pipeline"
        $LockName  = $AzResourceLock.Name

        Write-Host "##vso[task.setvariable variable=NewAzResourceLock;]$NewAzResourceLock"
        Write-Host "##vso[task.setvariable variable=ResourceGroupName;]$ResourceGroupName"
        Write-Host "##vso[task.setvariable variable=LockLevel;]$LockLevel"
        Write-Host "##vso[task.setvariable variable=LockNotes;]$LockNotes"
        Write-Host "##vso[task.setvariable variable=LockName;]$LockName"

        return $return
    }
}

function NewAzResourceLock {
    param(
        [System.String] $NewAzResourceLock,
        [System.String] $ResourceGroupName,
        [System.String] $LockLevel,
        [System.String] $LockNotes,
        [System.String] $LockName
    )
    if ($NewAzResourceLock -eq 'True'){
        $ResourceLock = New-AzResourceLock -ResourceGroupName $ResourceGroupName -LockLevel $LockLevel -LockNotes $LockNotes -LockName $LockName -Force
        Write-Host "Resource Lock Created: " $ResourceLock.ResourceId
    } else {
        Write-Host "There is no Resource Lock for Resource Group: " $ResourceGroupName
    }
}

if ($removeLock -eq 'True') {
    Write-Host "Remove lock"
    RemoveAzResourceLock -ResourceGroupName $ResourceGroupName
} 

if ($newLock -eq 'True') {
    Write-Host "Create lock"
    NewAzResourceLock -NewAzResourceLock $newLock -ResourceGroupName $ResourceGroupName -LockLevel $LockLevel -LockNotes $LockNotes -LockName $LockName
}