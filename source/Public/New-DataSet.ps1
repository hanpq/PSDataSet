function New-DataSet
{
    <#
        .DESCRIPTION
            This function creates a new dataset
        .EXAMPLE
            $DataSet = New-DataSet

            This example demonstrates how to initialize a new data set object.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'No need to confirm creation of creation of in-memory empty data structure')]
    [CmdletBinding()] # Enabled advanced function support
    param(
    )

    PROCESS
    {
        try
        {
            New-Object -TypeName System.Data.DataSet -ErrorAction Stop
            Write-Verbose -Message 'Created DataSet'
        }
        catch
        {
            throw $_
        }
    }
}
