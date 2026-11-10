function New-DataTable
{
    <#
        .DESCRIPTION
            Creating a DataTable object
        .PARAMETER TableName
            Defines the data table name. This property is used when referencing the table in a dataset for instance.
        .EXAMPLE
            $OrderTable = New-DataTable -TableName 'Orders'

            This example will create a datatable and return the datatable object.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'No need to confirm creation of creation of in-memory empty data structure')]
    [CmdletBinding()] # Enabled advanced function support
    [OutputType([system.object[]])]
    param(
        [Parameter(Mandatory)]
        [string]
        $TableName
    )

    PROCESS
    {
        $DataTable = New-Object System.Data.Datatable
        $DataTable.TableName = $TableName

        # As the type DataTable is not enumerable, use the unary operator to return the DataTable as an one element array which is enumerable.
        return , $DataTable
    }
}
