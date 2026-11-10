function Get-DataTableRow
{
    <#
        .DESCRIPTION
            Retreive rows from DataTable
        .PARAMETER DataTable
            Pass the data table object to get rows from
        .PARAMETER Query
            Define a query.

            -like : like
            -gt   : >
            -lt   : <
            -eq   : =

            Values should be enclosed with single qoutation marks
            Columns should not be enclosed with quotation marks
        .EXAMPLE
            Get-DataTableRow -DataTable $DataTable -Query '[OrderID] = 123456789'

            This example demonstrates how to retreive rows from data table.
    #>

    [CmdletBinding()]
    param(
        [System.Data.DataTable]
        $DataTable,

        [string]
        [Alias('SQLQuery')]
        $Query
    )
    PROCESS
    {
        try
        {
            $DataTable.Select($Query)
        }
        catch
        {
            Throw $_
        }
    }
}
