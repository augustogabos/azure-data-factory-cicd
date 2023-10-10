param(
    [parameter(Mandatory = $true)] [String]$ResourceGroupName,
    [parameter(Mandatory = $true)] [String]$DataFactoryName,
    [parameter(Mandatory = $true)] [String]$LastCommitId
)

$var = Get-AzDataFactoryV2 -ResourceGroupName $ResourceGroupName -Name $DataFactoryName

Get-AzDataFactoryV2 -ResourceGroupName $ResourceGroupName -Name $DataFactoryName | Set-AzDataFactoryV2 -AccountName $var.RepoConfiguration.AccountName -RepositoryName $var.RepoConfiguration.RepositoryName -CollaborationBranch $var.RepoConfiguration.CollaborationBranch -RootFolder / -ProjectName $var.RepoConfiguration.ProjectName -LastCommitId $LastCommitId -Force