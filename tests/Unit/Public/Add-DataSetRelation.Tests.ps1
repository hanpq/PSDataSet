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
    Describe -Name 'Add-DataSetRelation.ps1' -Fixture {
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
}
