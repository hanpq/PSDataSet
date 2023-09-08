BeforeDiscovery {
        $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains "source") {$RootItem = $RootItem.Parent}
    $ProjectPath = $RootItem.FullName
    $ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
            ($_.Directory.Name -eq 'source') -and
            $(try
                {
                    Test-ModuleManifest $_.FullName -ErrorAction Stop
                }
                catch
                {
                    $false
                })
        }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe -Name 'New-DataTable.ps1' -Fixture {
        BeforeAll {
        }
        Context -Name 'When a valid name is supplied' {
            It -Name 'Should return a object of type DataTable' -Test {
                New-DataTable -TableName 'Table1' | Should -BeOfType [System.Data.Datatable]
            }
            It -Name 'Should not throw' -Test {
                { New-DataTable -TableName 'Table1' } | Should -Not -Throw
            }
        }
        Context -Name 'When a empty string is supplied as name' {
            It -Name 'Should throw' -Test {
                { New-DataTable -TableName '' } | Should -Throw
            }
        }
    }
}
