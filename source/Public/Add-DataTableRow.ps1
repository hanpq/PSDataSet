function Add-DataTableRow
{
    <#
        .DESCRIPTION
            This function adds a row to a table
        .PARAMETER DataTable
            Pass the data table object to add rows to
        .PARAMETER InputObject
            Provides an object array with objects thats
            has properties corresponding to the table columns.
            Note that the object can contain more properties
            than columns, they will simply be ignored during
            matching. On the other side, if the object is missing
            properties for all columns, the addition will fail.
        .EXAMPLE
            Get-Service | Add-DataTableRow -DataTable $DataTable

            This example demonstrates how a preexisting object array
            can be passed to add rows.
        .EXAMPLE
            $Object = [pscustomobject]@{
                Property1 = 'Value'
                Property2 = 'Value'
                Property3 = 'Value'
            }
            Add-DataTableRow -DataTable $DateTable -InputObject $Object

            This example demonstrates how a single object can be passed to add a new row.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'False positive.')]
    [CmdletBinding()] # Enabled advanced function support
    param(
        [System.Data.DataTable]
        $DataTable,

        [Parameter(ValueFromPipeline)]
        [Object[]]
        $InputObject
    )

    PROCESS
    {
        $InputObject | ForEach-Object {
            $CurrentObject = $PSItem
            $NewRow = $DataTable.NewRow()
            $CurrentObject.PSObject.Properties.GetEnumerator().ForEach( { $NewRow.($PSItem.Name) = $PSItem.Value })
            [void]$DataTable.Rows.Add($NewRow)
        }
    }
}
