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
    Describe -Name 'Add-DataSetTable.ps1' -Fixture {
        BeforeAll {
            $DataTable = New-Object System.Data.Datatable
            $DataTable.TableName = 'TableName'

            $DataSet = New-Object -TypeName System.Data.DataSet
        }
        Context -Name 'When calling with valid DataSet and DataTable' {
            It -Name 'Should not throw' -Test {
                { Add-DataSetTable -DataSet $DataSet -DataTable $DataTable } | Should -Not -Throw
            }
            It -Name 'Dataset should contain datatable' -Test {
                $DataSet.Tables.Contains('TableName') | Should -BeTrue
            }
        }
        Context -Name 'When calling with an invalid data table' {
            It -Name 'Should throw' {
                { Add-DataSetTable -DataSet $DataSet -DataTable $null } | Should -Throw
            }
        }
        Context -Name 'When calling with an invalid data set' {
            It -Name 'Should throw' {
                { Add-DataSetTable -DataSet $null -DataTable $DataTable } | Should -Throw
            }
        }
    }
}
