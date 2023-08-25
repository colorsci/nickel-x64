Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

function CheckCicero
{
    Write-DiagProgress -activity $localizationString.Check_Cicero
    return $true
}