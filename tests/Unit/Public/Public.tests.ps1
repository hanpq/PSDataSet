BeforeDiscovery {
    $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains 'source')
    {
        $RootItem = $RootItem.Parent
    }
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
    Describe 'Add-DataSetRelation' -Fixture {
        BeforeEach {
            $DataSet = New-Object -TypeName System.Data.DataSet

            $CustomerTable = New-Object System.Data.Datatable
            $CustomerTable.TableName = 'CustomerTable'
            $OrderTable = New-Object System.Data.Datatable
            $OrderTable.TableName = 'OrderTable'

            $DataSet.Tables.Add($CustomerTable)
            $DataSet.Tables.Add($OrderTable)

            $DataColumn = New-Object System.Data.DataColumn -ArgumentList 'ID'
            $DataColumn.DataType = [Object]
            [void]$CustomerTable.Columns.Add($DataColumn)

            $DataColumn = New-Object System.Data.DataColumn -ArgumentList 'Name'
            $DataColumn.DataType = [Object]
            [void]$CustomerTable.Columns.Add($DataColumn)

            $DataColumn = New-Object System.Data.DataColumn -ArgumentList 'ID'
            $DataColumn.DataType = [Object]
            [void]$OrderTable.Columns.Add($DataColumn)

            $DataColumn = New-Object System.Data.DataColumn -ArgumentList 'CustomerID'
            $DataColumn.DataType = [Object]
            [void]$OrderTable.Columns.Add($DataColumn)

            [void]$CustomerTable.Rows.Add(1, 'Cust1')
            [void]$OrderTable.Rows.Add(11111, 1)
            [void]$OrderTable.Rows.Add(22222, 1)


        }
        AfterEach {
            Remove-Variable DataSet, CustomerTable, OrderTable, DataColumn
        }
        Context -Name 'When adding a data set relation' {
            It -Name 'Should not throw' {
                { Add-DataSetRelation `
                        -RelationName 'CustomerOrderRel' `
                        -DataSet $DataSet `
                        -ParentDataTableColumn $CustomerTable.Columns['ID'] `
                        -ChildDataTableColumn $OrderTable.Columns['CustomerID'] } | Should -Not -Throw
            }
            It -Name 'Should not return when passthrough is not used' {
                $Relationship = Add-DataSetRelation `
                    -RelationName 'CustomerOrderRel' `
                    -DataSet $DataSet `
                    -ParentDataTableColumn $CustomerTable.Columns['ID'] `
                    -ChildDataTableColumn $OrderTable.Columns['CustomerID']
                $Relationship | Should -BeNullOrEmpty
            }
            It -Name 'Customer rows should return child rows' {
                $Relationship = Add-DataSetRelation `
                    -RelationName 'CustomerOrderRel' `
                    -DataSet $DataSet `
                    -ParentDataTableColumn $CustomerTable.Columns['ID'] `
                    -ChildDataTableColumn $OrderTable.Columns['CustomerID'] `
                    -Passtrough
                $Result = $CustomerTable.Rows[0].GetChildRows($Relationship)
                $Result | Should -HaveCount 2
            }
            It -Name 'Order rows should return parent rows' {
                $Relationship = Add-DataSetRelation `
                    -RelationName 'CustomerOrderRel' `
                    -DataSet $DataSet `
                    -ParentDataTableColumn $CustomerTable.Columns['ID'] `
                    -ChildDataTableColumn $OrderTable.Columns['CustomerID'] `
                    -Passtrough
                $Result = $OrderTable.Rows[0].GetParentRow($Relationship)
                $Result | Should -HaveCount 1
            }
            It -Name 'Should throw when adding duplicate relations' {
                Mock Write-Error -MockWith { throw }
                Add-DataSetRelation `
                    -RelationName 'CustomerOrderRel' `
                    -DataSet $DataSet `
                    -ParentDataTableColumn $CustomerTable.Columns['ID'] `
                    -ChildDataTableColumn $OrderTable.Columns['CustomerID']
                { Add-DataSetRelation `
                        -RelationName 'CustomerOrderRel' `
                        -DataSet $DataSet `
                        -ParentDataTableColumn $CustomerTable.Columns['ID'] `
                        -ChildDataTableColumn $OrderTable.Columns['CustomerID'] } | Should -Throw
            }
            It -Name 'Should return a relation object when using passthrough' {
                $Result = Add-DataSetRelation `
                    -RelationName 'CustomerOrderRel' `
                    -DataSet $DataSet `
                    -ParentDataTableColumn $CustomerTable.Columns['ID'] `
                    -ChildDataTableColumn $OrderTable.Columns['CustomerID'] `
                    -Passtrough
                $Result | Should -Not -BeNullOrEmpty
            }
        }
    }

    Describe 'Add-DataSetTable' -Fixture {
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

    Describe 'Add-DataTableColumn' -Fixture {
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

    Describe 'Add-DataTableRow' -Fixture {
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

    Describe 'Get-DataTableRow' -Fixture {
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

            [void]$DataTable.Rows.Add(1, 2, 3)
            [void]$DataTable.Rows.Add(4, 5, 3)

        }
        AfterEach {
            Remove-Variable -Name 'DataTable'
        }
        Context -Name 'When calling with a valid query and expect single result' {
            BeforeEach {
                $Result = Get-DataTableRow -DataTable $DataTable -SQLQuery '[one] = 1'
            }
            It -Name 'Should return one row' {
                $Result | Should -HaveCount 1
            }
            It -Name 'Should be of type DataRow' {
                $Result | Should -BeOfType [System.Data.DataRow]
            }
        }
        Context -Name 'When calling with a valid query and expect multi row result' {
            BeforeEach {
                $Result = Get-DataTableRow -DataTable $DataTable -SQLQuery '[Three] = 3'
            }
            It -Name 'Should return two rows' {
                $Result | Should -HaveCount 2
            }
            It -Name 'Each row should be of type DataRow' {
                $Result[0] | Should -BeOfType [System.Data.DataRow]
            }
        }
        Context -Name 'When calling with a valid query and expect zero results' {
            BeforeEach {
                $Result = Get-DataTableRow -DataTable $DataTable -SQLQuery '[Three] = 6'
            }
            It -Name 'Should return zero rows' {
                $Result | Should -BeNullOrEmpty
            }
        }
        Context -Name 'When calling with a invalid query' {
            It -Name 'Should throw' {
                { Get-DataTableRow -DataTable $DataTable -SQLQuery '[Three] = Foo' -ErrorAction Stop } | Should -Throw
            }
        }
    }

    Describe 'New-DataSet' -Fixture {
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

    Describe 'New-DataTable' -Fixture {
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
