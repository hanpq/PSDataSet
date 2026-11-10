function Add-DataTableColumn
{
    <#
        .DESCRIPTION
            Add columns to data tables. Columns can be added before or after rows have been added.

            The command operates in two modes, single column or multiple columns mode.

            Multiple mode
            In multiple mode it is possible to provide a string array
            of column names. This is a fast and simple way to quickly
            populate a table with empty columns.

            Single mode
            In single mode each call adds a single column to the table.
            The difference is that when single mode is used it is
            possible to add caption, defaultvalue and expressions.

        .PARAMETER DataTable
            Defined the DataTable that columns should be added to
        .PARAMETER Names
            Defines the names of the columns. This is used to reference the column in the datatable.
        .PARAMETER Caption
            Sets the caption of the column. This is used when creating table views.
        .PARAMETER DefaultValue
            Sets the default value of a column. When set the cell of each row will get initialized with this default value.
        .PARAMETER Expression
            Sets a expression to calculate the cell value.

            For more information about expression variables and syntax see microsoft docs
            https://docs.microsoft.com/en-us/dotnet/api/system.data.datacolumn.expression?view=net-5.0

        .PARAMETER AllowDBNull
            Defaults to true, if set to false column will not allow null values

        .EXAMPLE
            Add-DataTableColumn -DataTable $DataTable -Names 'Firstname','Lastname','Address','Email'

            This example demostrates the use of multiple mode to create four columns in the DataTable object.

        .EXAMPLE
            Add-DataTableColumn -DataTable $DataTable -Names 'PreferredColor' -Caption 'Preferred color' -DefaultValue 'Blue'

            This example demostrates the use of single mode to create one column with a caption and a default value.

        .EXAMPLE
            Add-DataTableColumn -DataTable $DataTable -Names 'Fee' -Expression '[Price] * [Amount]'

            This example demostrates the use of single mode to create one column with an expression
    #>

    [CmdletBinding(DefaultParameterSetName = 'Multiple')] # Enabled advanced function support
    param(
        [Parameter(Mandatory)]
        [System.Data.DataTable]
        $DataTable,

        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [Parameter(Mandatory, ParameterSetName = 'Multiple')]
        [string[]]
        $Names,

        [Parameter(ParameterSetName = 'Single')]
        [string]
        $Caption,

        [Parameter(ParameterSetName = 'Single')]
        [string]
        $DefaultValue = '',

        [Parameter(ParameterSetName = 'Single')]
        [string]
        $Expression,

        [Parameter(ParameterSetName = 'Single')]
        [boolean]
        $AllowDBNull = $true
    )

    PROCESS
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'Single'
            {
                $DataColumn = New-Object System.Data.DataColumn -ArgumentList @($Names)[0]
                $DataColumn.Caption = $Caption
                $DataColumn.DefaultValue = $DefaultValue
                $DataColumn.DataType = [Object]
                if ($Expression)
                {
                    $DataColumn.Expression = $Expression
                }
                $DataColumn.AllowDBNull = $AllowDBNull

                [void]$DataTable.Columns.Add($DataColumn)
            }
            'Multiple'
            {
                foreach ($Name in $Names)
                {
                    $DataColumn = New-Object System.Data.DataColumn -ArgumentList $Name
                    $DataColumn.DataType = [Object]
                    [void]$DataTable.Columns.Add($DataColumn)
                }
            }
        }
    }
}
#endregion
