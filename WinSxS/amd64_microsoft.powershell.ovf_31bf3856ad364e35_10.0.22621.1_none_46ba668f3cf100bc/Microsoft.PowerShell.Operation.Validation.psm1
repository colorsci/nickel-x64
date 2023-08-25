#Strings
Data LocalizedData
{
    ConvertFrom-StringData @'
    CannotDetermineTestName=Cannot determine test name
    InvalidTestInfo=TestInfo must contain the path and the list of tests
    InspectingModules=Inspecting Modules
    DiagnosticSearch=Searching for Diagnostics in {0}
    InvokingTest=Invoking tests in {0}
'@
}
#Region ObjectHelpers
function New-OperationValidationFailure
{
    param (
        [Parameter(Mandatory=$true)][string]$StackTrace,
        [Parameter(Mandatory=$true)][string]$FailureMessage
    )
    $o = [pscustomobject]@{
        StackTrace = $StackTrace
        FailureMessage = $FailureMessage
        }
    $o.psobject.Typenames.Insert(0,"Operation.Validation.Failure")
    $ToString = { return $this.StackTrace }
    Add-Member -inputobject $o -membertype ScriptMethod -Name ToString -Value $toString -Force
    $o
}
function New-OperationValidationResult
{
    param (
        [Parameter(Mandatory=$true)][string]$Module,
        [Parameter(Mandatory=$true)][string]$FileName,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Result,
        [Parameter()][object]$RawResult,
        [Parameter()][object]$Error
    )
    $o = [pscustomobject]@{ 
        Module    = $Module
        FileName  = $FileName
        ShortName = ([io.path]::GetFileName($FileName))
        Name      = $Name
        Result    = $Result
        Error     = $Error
        RawResult = $RawResult
        }
    $o.psobject.Typenames.Insert(0,"Operation.Validation.Result")
    $ToString = { return ("{0} ({1}): {2}" -f $this.Module, $this.FileName, $this.Name) }
    Add-Member -inputobject $o -membertype ScriptMethod -Name ToString -Value $toString -Force
    $o
}
function new-OperationValidationInfo
{
    param ( 
        [Parameter(Mandatory=$true)][string]$File,
        [Parameter(Mandatory=$true)][string]$FilePath,
        [Parameter(Mandatory=$true)][string[]]$Name,
        [Parameter()][string[]]$TestCases,
        [Parameter(Mandatory=$true)][ValidateSet("None","Simple","Comprehensive")][string]$Type,
        [Parameter()][string]$modulename
        )
    $o = [pscustomobject]@{
        File       = $File
        FilePath   = $FilePath
        Name       = $Name
        TestCases  = $testCases
        Type       = $type
        ModuleName = $modulename
        }
    $o.psobject.Typenames.Insert(0,"Operation.Validation.Info")
    $ToString = { return ("{0} ({1}): {2}" -f $this.testFile, $this.Type, ($this.TestCases -join ",")) }
    Add-Member -inputobject $o -membertype ScriptMethod -Name ToString -Value $toString -Force
    $o
}
# endregion

function Get-TestFromScript
{
    param ( [string]$scriptPath )
    $errs = $null
    $tok =[System.Management.Automation.PSParser]::Tokenize((get-content -read 0 -Path $scriptPath), [ref]$Errs)

    for($i = 0; $i -lt $tok.count; $i++) {
        if ( $tok[$i].type -eq "Command" -and $tok[$i].content -eq "Describe" ) 
        {
            $i++
            if ( $tok[$i].Type -eq "String" ) { $tok[$i].Content }
            else
            {
                # ok - we didn't get the describe text first, 
                # we likely saw a "-Tags" statement, so that means that
                # the describe text will immediately preceed the scriptblock
                while($tok[$i].Type -ne "GroupStart")
                {
                    $i++
                }
                $i--
                $tok[$i].Content
            }
        }
    }

}

function Get-OperationValidation
{
[CmdletBinding()]
param (
    [Parameter(Position=0)][string[]]$ModuleName = "*",
    [Parameter()][ValidateSet("Simple","Comprehensive")][string[]]$TestType =  @("Simple","Comprehensive")
    )

    BEGIN
    {
        function Get-TestName ( $ast )
        {
            for($i = 1; $i -lt $ast.Parent.CommandElements.Count; $i++)
            {
                if ( $ast.Parent.CommandElements[$i] -is "System.Management.Automation.Language.CommandParameterAst") { $i++; continue }
                if ( $ast.Parent.CommandElements[$i] -is "System.Management.Automation.Language.ScriptBlockExpressionAst" ) { continue }
                if ( $ast.Parent.CommandElements[$i] -is "System.Management.Automation.Language.StringConstantExpressionAst" ) { return $ast.Parent.CommandElements[$i].Value }
            }
            throw $LocalizedData.CannotDetermineTestName
        }
        function Get-TestFromAst ( $ast )
        {
            $eb = $ast.EndBlock
            foreach($statement in $eb.Statements)
            {
                if ( $statement -isnot "System.Management.Automation.Language.PipelineAst" )
                {
                    continue
                }
                $CommandAst = $statement.PipelineElements[0].CommandElements[0]

                if (  $CommandAst.Value -eq "Describe" )
                {
                    Get-TestName $CommandAst
                }
            }
        }
        function Get-TestCaseNamesFromAst ( $ast )
        {
            $eb = $ast.EndBlock
            foreach($statement in $eb.Statements)
            {
                if ( $statement -isnot "System.Management.Automation.Language.PipelineAst" )
                {
                    continue
                }
                $CommandAst = $statement.PipelineElements[0].CommandElements[0]

                if (  $CommandAst.Value -eq "It" )
                {
                    Get-TestName $CommandAst
                }
            }
        }
        # we can't use Get-Module -List here because diagnostics do not need to be 
        # part of a "valid" module. Diagnostics need to be found even if not associated
        # with a module which has a .psd1 or .psm1 file
        function Get-ModuleList 
        {
            param ( [string[]]$Name )
            foreach($p in $env:psmodulepath.split(";"))
            {
                if ( test-path -path $p )
                {
                    foreach($modDir in get-childitem -path $p -directory)
                    {
                        foreach ($n in $name )
                        {
                            if ( $modDir.Name -like $n )
                            {
                                # now determine if there's a diagnostics directory, or a version
                                if ( test-path -path ($modDir.FullName + "\Diagnostics"))
                                {
                                    $modDir.FullName
                                    break
                                }
                                $versionDirectories = Get-Childitem -path $modDir.FullName -dir | 
                                    where-object { $_.name -as [version] }
                                $potentialDiagnostics = $versionDirectories | where-object {
                                    test-path ($_.fullname + "\Diagnostics")
                                    }
                                # now select the most recent module path which has diagnostics
                                $DiagnosticDir = $potentialDiagnostics | 
                                    sort-object {$_.name -as [version]} | 
                                    Select-Object -Last 1
                                if ( $DiagnosticDir )
                                {
                                    $DiagnosticDir.FullName
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    PROCESS
    {
        Write-Progress -Activity $LocalizedData.InspectingModules -Status " "
        $moduleCollection = Get-ModuleList -Name $ModuleName   
        $count = 1; 
        $moduleCount = @($moduleCollection).Count
        foreach($module in $moduleCollection)
        {
            Write-Progress -Activity ($LocalizedData.DiagnosticSearch -f $module) -PercentComplete ($count++/$moduleCount*100) -status " "
            $diagnosticsDir=$module + "\Diagnostics" 
            if ( test-path -path $diagnosticsDir )
            {
                foreach($dir in $testType)
                {
                    $testDir = "$diagnosticsDir\$dir"
                    if ( ! (test-path -path $testDir) ) 
                    {
                        continue
                    }
                    foreach($file in get-childitem -path $testDir -filter *.tests.ps1)
                    {
                        $testName = Get-TestFromScript -scriptPath $file.FullName
                        new-OperationValidationInfo -FilePath $file.Fullname -File $file.Name -Type $dir -Name $testName -ModuleName $Module
                    }
                }
            }
        }
    }
}

function Invoke-OperationValidation
{
    [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="FileAndTest")]
    param (
        [Parameter(ParameterSetName="Path",ValueFromPipelineByPropertyName=$true)][string[]]$testFilePath,
        [Parameter(ParameterSetName="FileAndTest",ValueFromPipeline=$true)][pscustomobject[]]$TestInfo,
        [Parameter(ParameterSetName="UseGetOperationTest")][string[]]$ModuleName = "*",
        [Parameter(ParameterSetName="UseGetOperationTest")]
        [ValidateSet("Simple","Comprehensive")][string[]]$TestType = @("Simple","Comprehensive"),
        [Parameter()][switch]$IncludePesterOutput
        )
    BEGIN
    {
        $quiet = ! $IncludePesterOutput
        import-module -Name Pester
    }
    PROCESS
    {
        if ( $PSCmdlet.ParameterSetName -eq "UseGetOperationTest" )
        {
            $tests = Get-OperationValidation -ModuleName $ModuleName -TestType $TestType 
            $tests | Invoke-OperationValidation -IncludePesterOutput:$IncludePesterOutput
            return
        }
        
        if ( ($testFilePath -eq $null) -and ($TestInfo -eq $null) )
        {
            Get-OperationValidation | Invoke-OperationValidation -IncludePesterOutput:$IncludePesterOutput
            return
        }

        
        if ( $testInfo -ne $null )
        {
            # first check to be sure all of the TestInfos are sane
            # we need both to be present
            foreach($ti in $testinfo)
            {
                if ( ($ti.FilePath -eq $null) -or ($ti.Name -eq $null))
                {
                    throw $LocalizedData.InvalidTestInfo
                }
            }
            
            foreach($tname in $ti.Name)
            {
                $testResult = Invoke-pester -Path $ti.FilePath -TestName $tName -quiet:$quiet -PassThru
                Add-member -InputObject $testResult -MemberType NoteProperty -Name Path -Value $ti.FilePath
                Convert-TestResult $testResult 
            }
            return
        }

        foreach($test in $testFilePath)
        {
            write-progress -Activity ($LocalizedData.InvokingTest -f $test)
            if ( $PSCmdlet.ShouldProcess($test))
            {
                $testResult = Invoke-Pester $test -passthru -quiet:$quiet
                Add-Member -InputObject $testResult -MemberType NoteProperty -Name Path -Value $test
                Convert-TestResult $testResult
            }
        }
    }

}

# emit an object which can be used in reporting
Function Convert-TestResult
{
    param ( $result )
    foreach ( $testResult in $result.TestResult )
    {
        $testError = $null
        if ( $testResult.Result -eq "Failed" )
        {
            $testError = new-OperationValidationFailure -Stacktrace $testResult.StackTrace -FailureMessage $testResult.FailureMessage
        }
        $Module = $result.Path.split([io.path]::DirectorySeparatorChar)[-4]
        $TestName = "{0}:{1}:{2}" -f $testResult.Describe,$testResult.Context,$testResult.Name
        New-OperationValidationResult -Module $Module -Name $TestName -FileName $result.path -Result $testresult.result -RawResult $testResult -Error $TestError
    }

}
