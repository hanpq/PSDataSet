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
    Describe -Name 'New-DataSet.ps1' -Fixture {
        BeforeAll {
        }
        Context -Name 'When calling New-DataSet' {
            It -Name 'Should not throw' -Test {
                { New-DataSet } | Should -Not -Throw
            }
            It -Name 'Should return a object of type DataSet' -Test {
                New-DataSet | Should -BeOfType [System.Data.DataSet]
            }
            It -Name 'New-Object fails it should throw' {
                Mock -CommandName 'New-Object' -MockWith { throw }
                { New-DataSet } | Should -Throw
            }
        }
    }
}
