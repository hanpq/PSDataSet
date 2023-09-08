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
    Describe -Name 'Add-DataTableColumn.ps1' -Fixture {
        BeforeEach {
            $DataTable = New-Object System.Data.Datatable
            $DataTable.TableName = 'TableName'
        }
        AfterEach {
            Remove-Variable -Name 'DataTable'
        }
        Context -Name 'When calling with multiple names' {
            It -Name 'It should not throw' -Test {
                { Add-DataTableColumn -DataTable $DataTable -Names 'One', 'Two' } | Should -Not -Throw
            }
            It -Name 'Table should contain new columns' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'One', 'Two'
                $DataTable.Columns.Contains('One') | Should -BeTrue
                $DataTable.Columns.Contains('Two') | Should -BeTrue
            }
        }
        Context -Name 'When calling with single name and caption' {
            It -Name 'It should not throw' {
                { Add-DataTableColumn -DataTable $DataTable -Names 'Three' -Caption 'ThreeCaption' } | Should -Not -Throw
            }
            It -Name 'Table should contain new column' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'Three' -Caption 'ThreeCaption'
                $DataTable.Columns.Contains('Three') | Should -BeTrue
            }
            It -Name 'Column should have caption' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'Three' -Caption 'ThreeCaption'
                $DataTable.Columns['Three'].Caption | Should -Be 'ThreeCaption'
            }
        }
        Context -Name 'When calling with a single name and default value' {
            It -Name 'It should not throw' {
                { Add-DataTableColumn -DataTable $DataTable -Names 'Four' -DefaultValue 'Default' } | Should -Not -Throw
            }
            It -Name 'Table should contain new column' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'Four' -DefaultValue 'Default'
                $DataTable.Columns.Contains('Four') | Should -BeTrue
            }
            It -Name 'Column should have value default for row' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'One', 'Two', 'Three'
                Add-DataTableColumn -DataTable $DataTable -Names 'Four' -DefaultValue 'Default'
                [void]$DataTable.Rows.Add(1, 2, 3)
                $DataTable.Rows[0].Four | Should -Be 'Default'
            }
        }
        Context -Name 'When calling with a single name and expression' {
            It -Name 'It should not throw' {
                Add-DataTableColumn -DataTable $DataTable -Names 'One', 'Two', 'Three'
                { Add-DataTableColumn -DataTable $DataTable -Names 'Five' -Expression '([one] + [two]) * 5' } | Should -Not -Throw
            }
            It -Name 'Table should contain new column' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'One', 'Two', 'Three'
                Add-DataTableColumn -DataTable $DataTable -Names 'Five' -Expression '([one] + [two]) * 5'
                $DataTable.Columns.Contains('Five') | Should -BeTrue
            }
            It -Name 'Column should have calculated value for row' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'One', 'Two', 'Three'
                Add-DataTableColumn -DataTable $DataTable -Names 'Five' -Expression '([one] + [two]) * 5'
                $object = [pscustomobject]@{
                    'One'   = 1
                    'Two'   = 2
                    'Three' = 3
                }
                [void]$DataTable.Rows.Add(1, 2, 3)
                $DataTable.Rows[0].Five | Should -Be 15
            }
        }
        Context -Name 'When calling with a single name and allowdbnull' {
            It -Name 'It should not throw' {
                Add-DataTableColumn -DataTable $DataTable -Names 'One', 'Two', 'Three'
                { Add-DataTableColumn -DataTable $DataTable -Names 'Five' -AllowDBNull:$false } | Should -Not -Throw
            }
            It -Name 'Table should contain new column' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'One', 'Two', 'Three'
                Add-DataTableColumn -DataTable $DataTable -Names 'Five' -AllowDBNull:$false
                $DataTable.Columns.Contains('Five') | Should -BeTrue
            }
            It -Name 'Column should throw when adding null value to row' -Test {
                Add-DataTableColumn -DataTable $DataTable -Names 'Four' -AllowDBNull:$true
                Add-DataTableColumn -DataTable $DataTable -Names 'Five' -AllowDBNull:$false
                [void]$DataTable.Rows.Add($null, $null)
                { $DataTable.Rows[0].Four = $null } | Should -Not -Throw
                { $DataTable.Rows[0].Five = $null } | Should -Throw
            }
        }
    }
}
