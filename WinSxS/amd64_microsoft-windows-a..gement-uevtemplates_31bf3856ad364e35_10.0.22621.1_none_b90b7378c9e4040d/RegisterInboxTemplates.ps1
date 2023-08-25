# Enumerate the Inbox UE-V Templates and register those templates
$inboxTemplates= Get-ChildItem -Path $env:PROGRAMDATA\Microsoft\UEV\InboxTemplates -Filter *.xml
for ($count = 0; $count -lt $inboxTemplates.Count; $count++) {
    Register-UevTemplate -Path $inboxTemplates[$count].FullName -ErrorAction SilentlyContinue
}

# Disable the scheduled task - it needs to run only once on a machine
$registerTemplatesTask = Get-ScheduledTask -TaskName "UE-V Register Inbox Templates" -ErrorAction SilentlyContinue
if ($registerTemplatesTask -ne $null)
{
    Disable-ScheduledTask $registerTemplatesTask
}
