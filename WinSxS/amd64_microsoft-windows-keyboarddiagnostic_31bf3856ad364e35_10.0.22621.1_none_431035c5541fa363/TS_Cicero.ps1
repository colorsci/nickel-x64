. .\CL_Cicero.ps1

if ((CheckCicero) -eq $false)
{
    Update-DiagRootCause -id RC_Cicero -Detected $true
}
else
{
    Update-DiagRootCause -id RC_Cicero -Detected $false
}