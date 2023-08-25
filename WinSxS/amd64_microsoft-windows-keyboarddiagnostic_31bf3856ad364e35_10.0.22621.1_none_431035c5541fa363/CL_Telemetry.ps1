Add-Type -Path "KeyboardDiagnostic.dll"

function ReportDiagnosis
{
    try
    {
        [Microsoft.Windows.Desktop.TextInput.KeyboardDiagnostic.Logging]::ReportDiagnosis()
    }
    catch
    {
    }
}

