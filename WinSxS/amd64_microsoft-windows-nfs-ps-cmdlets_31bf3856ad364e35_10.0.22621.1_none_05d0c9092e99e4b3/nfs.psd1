
        @{
            GUID = '108AE179-3094-4223-91E4-B9099069017A'
            Author="Microsoft Corporation"
            CompanyName="Microsoft Corporation"
            Copyright="© Microsoft Corporation. All rights reserved."
            PowerShellVersion = '5.1'
            CLRVersion="4.0"
            HelpInfoUri="https://aka.ms/winsvr-2022-pshelp"
            ModuleVersion = '1.0'

            FormatsToProcess = 'nfs.format.ps1xml'
            TypesToProcess = 'nfs.types.ps1xml'
            NestedModules = @("MSFT_NfsServerTasks.cmdletDefinition.cdxml", "MSFT_NfsShare.cmdletDefinition.cdxml", "MSFT_NfsClientConfig.cmdletDefinition.cdxml", "MSFT_NfsServerConfig.cmdletDefinition.cdxml", "MSFT_NfsStatistics.cmdletDefinition.cdxml", "MSFT_NfsClientLock.cmdletDefinition.cdxml", "MSFT_NfsMappingStore.cmdletDefinition.cdxml", "MSFT_NfsNetgroupStore.cmdletDefinition.cdxml", "MSFT_NfsClientGroup.cmdletDefinition.cdxml", ".\MSFT_NfsMappedIdentity\MSFT_NfsMappedIdentity.psd1", "MSFT_NfsMountedClient.cmdletDefinition.cdxml", "MSFT_NfsOpenFile.cmdletDefinition.cdxml", "MSFT_NfsSession.cmdletDefinition.cdxml")
            CmdletsToExport = @('Get-NfsMappedIdentity',
                                'Get-NfsNetgroup',
                                'Install-NfsMappingStore',
                                'New-NfsMappedIdentity',
                                'New-NfsNetgroup',
                                'Remove-NfsMappedIdentity',
                                'Remove-NfsNetgroup',
                                'Set-NfsMappedIdentity',
                                'Set-NfsNetgroup',
                                'Test-NfsMappedIdentity')
            FunctionsToExport = @('Disconnect-NfsSession',
                                  'Get-NfsClientConfiguration',
                                  'Get-NfsClientgroup',
                                  'Get-NfsClientLock',
                                  'Get-NfsMappingStore',
                                  'Get-NfsMountedClient',
                                  'Get-NfsNetgroupStore',
                                  'Get-NfsOpenFile',
                                  'Get-NfsServerConfiguration',
                                  'Get-NfsSession',
                                  'Get-NfsShare',
                                  'Get-NfsSharePermission',
                                  'Get-NfsStatistics',
                                  'Grant-NfsSharePermission',
                                  'New-NfsClientgroup',
                                  'New-NfsShare',
                                  'Remove-NfsClientgroup',
                                  'Remove-NfsShare',
                                  'Rename-NfsClientgroup',
                                  'Reset-NfsStatistics',
                                  'Resolve-NfsMappedIdentity',
                                  'Revoke-NfsClientLock',
                                  'Revoke-NfsOpenFile',
                                  'Revoke-NfsSharePermission',
                                  'Set-NfsClientConfiguration',
                                  'Set-NfsClientgroup',
                                  'Set-NfsMappingStore',
                                  'Set-NfsNetgroupStore',
                                  'Set-NfsServerConfiguration',
                                  'Set-NfsShare',
                                  'Test-NfsMappingStore',
                                  'Revoke-NfsMountedClient')
            CompatiblePSEditions = @('Desktop','Core')
}
