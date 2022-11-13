function Add-DataSetTable
{
    <#
        .DESCRIPTION
            Add DataTable to a DataSet
        .PARAMETER DataSet
            Define the dataset object that the table should be added to
        .PARAMETER DataTable
            Supply the datatable that should be added to the dataset
        .EXAMPLE
            Add-DataSetTable -DataSet $DataSet -DataTable $DataTable

            This example shows how to add a datatable object to a dataset
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [Parameter(Mandatory)]
        [system.data.Dataset]
        $DataSet,

        [Parameter(Mandatory)]
        [System.Data.DataTable]
        $DataTable
    )

    PROCESS
    {
        $DataSet.Tables.Add($DataTable)
    }
}
