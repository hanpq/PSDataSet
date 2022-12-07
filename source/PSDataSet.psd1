#
# Module manifest for module 'PSDataSet'
#
# Generated by: Hannes Palmquist
#
# Generated on: 2022-11-13
#

@{
    RootModule           = 'PSDataSet.psm1'
    ModuleVersion        = '0.0.1'
    CompatiblePSEditions = @('Desktop', 'Core')
    PowerShellVersion    = '5.1'
    GUID                 = 'dcef7454-2793-46f7-b843-90f30e476b0b'
    Author               = 'Hannes Palmquist'
    CompanyName          = 'GetPS'
    Copyright            = '(c) Hannes Palmquist. All rights reserved.'
    Description          = 'Tools for managing a .NET system data set'
    RequiredModules      = @()
    FunctionsToExport    = '*'
    CmdletsToExport      = '*'
    VariablesToExport    = '*'
    AliasesToExport      = '*'
    PrivateData          = @{
        PSData = @{
            # Due to a bug in PowershellGet 3.0.17-beta17 licenseuri cannot used when Publishing.
            # Rollback to 3.0.17-beta16 has a bug that does not allow publishing of versioned powershell modules.
            # These three must be commented until 3.0.17-beta18 is released.
            #LicenseUri               = 'https://github.com/hanpq/PSDataSet/blob/main/LICENSE'
            #RequireLicenseAcceptance = $false
            Prerelease   = ''
            Tags         = @('PSEdition_Desktop', 'PSEdition_Core', 'Windows', 'Linux', 'MacOS')
            ProjectUri   = 'https://getps.dev/modules/PSDataSet/getstarted'
            ReleaseNotes = ''
        }
    }
}
