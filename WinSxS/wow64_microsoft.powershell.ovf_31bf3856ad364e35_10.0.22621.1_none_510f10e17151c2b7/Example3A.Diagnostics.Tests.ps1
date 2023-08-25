Describe "Example diagnostic finds the proper application" {
    It "Finds built in command get-Command" {
        $CommandName = "Get-Command"
        $cmd = Get-Command Get-Command
        $Cmd.Name | Should Be $CommandName
    }
}
