$newpath = "$env:windir\System32\ServerManagerInternal;"
if (-not $env:PSModulePath.Contains($newpath))
{
    $env:PSModulePath = $newpath + $env:PSModulePath
}
