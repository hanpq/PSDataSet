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
    Describe -Name 'Add-DataTableRow.ps1' -Fixture {
        BeforeEach {
            $DataTable = New-Object System.Data.Datatable
            $DataTable.TableName = 'TableName'

            $DataColumn = New-Object System.Data.DataColumn -ArgumentList 'One'
            $DataColumn.DataType = [Object]
            [void]$DataTable.Columns.Add($DataColumn)

            $DataColumn = New-Object System.Data.DataColumn -ArgumentList 'Two'
            $DataColumn.DataType = [Object]
            [void]$DataTable.Columns.Add($DataColumn)

            $DataColumn = New-Object System.Data.DataColumn -ArgumentList 'Three'
            $DataColumn.DataType = [Object]
            [void]$DataTable.Columns.Add($DataColumn)
        }
        AfterEach {
            Remove-Variable -Name 'DataTable'
        }
        Context -Name 'When calling with a valid object' {
            It -Name 'Should not throw' -Test {
                $object = [pscustomobject]@{'One' = 1; 'Two' = 2; 'Three' = 3 }
                { Add-DataTableRow -DataTable $DataTable -InputObject $Object } | Should -Not -Throw
            }
            It -Name 'Row should have correct values' -Test {
                $object = [pscustomobject]@{'One' = 1; 'Two' = 2; 'Three' = 3 }
                Add-DataTableRow -DataTable $DataTable -InputObject $Object
                $DataTable.Rows[0].One | Should -Be 1
                $DataTable.Rows[0].Two | Should -Be 2
                $DataTable.Rows[0].Three | Should -Be 3
            }
        }
    }
}
