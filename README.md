> :warning: **IMPORTANT**
> This module is early in it´s development phase. Many API function and features are not yet available. You are welcome to contribute on GitHub to accelerate progress further.

# PSDataSet

This project has adopted the following policies [![CodeOfConduct](https://img.shields.io/badge/Code%20Of%20Conduct-gray)](https://github.com/hanpq/PSDataSet/blob/main/.github/CODE_OF_CONDUCT.md) [![Contributing](https://img.shields.io/badge/Contributing-gray)](https://github.com/hanpq/PSDataSet/blob/main/.github/CONTRIBUTING.md) [![Security](https://img.shields.io/badge/Security-gray)](https://github.com/hanpq/PSDataSet/blob/main/.github/SECURITY.md)

## Project status
[![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/hanpq/PSDataSet/Build?label=build&logo=github)](https://github.com/hanpq/PSDataSet/actions/workflows/build.yml) [![Codecov](https://img.shields.io/codecov/c/github/hanpq/PSDataSet?logo=codecov&token=qJqWlwMAiD)](https://codecov.io/gh/hanpq/PSDataSet) [![Platform](https://img.shields.io/powershellgallery/p/PSDataSet?logo=ReasonStudios)](https://img.shields.io/powershellgallery/p/PSDataSet) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSDataSet?label=downloads)](https://www.powershellgallery.com/packages/PSDataSet) [![License](https://img.shields.io/github/license/hanpq/PSDataSet)](https://github.com/hanpq/PSDataSet/blob/main/LICENSE) [![docs](https://img.shields.io/badge/docs-getps.dev-blueviolet)](https://getps.dev/modules/PSDataSet/getstarted) [![changelog](https://img.shields.io/badge/changelog-getps.dev-blueviolet)](https://github.com/hanpq/PSDataSet/blob/main/CHANGELOG.md) ![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/hanpq/PSDataSet?label=version&sort=semver) ![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/hanpq/PSDataSet?include_prereleases&label=prerelease&sort=semver)

## About

This modules provides tools for interacting with .NET datasets 
from powershell. .NET 5.0 (and earlier) provides resource to work 
with data sets and tables. To make it easier to interact with the 
constructors, methods, properties, this module was developed to
powershell-ify the syntax of working with these resources.

### Why should I use DataSets and DataTables?

Powershell provides built-in methods of managing data like; Arrays, 
Collections, Lists, HashTables, Dictionaries etc. 
They all have their use cases, strengths and weaknesses. One of the 
weeknesses that all of them suffers from is managing very large data structures 
and the resulting resource utilization and performance limitations.

When working with datatables with let's say 20 000 items and 60 properties each 
the methods above will turn really slow and quite possible make the
powershell host reach the memory limit. (Default 2048 MB for v5).

Obviously a SQL server or similar would be a good candidate to store 
such data sets but it is not always possible and sometimes you are 
forces to manage large data sets in memory.

The best way of handling these large data sets that I found was 
the .NET datasets and datatables. That is the reason why this module
was born. This module is a wrapper for these .NET classes.


## Installation

### PowerShell Gallery

To install from the PowerShell gallery using PowerShellGet run the following command:

```powershell
Install-Module PSDataSet -Scope CurrentUser
```

## Usage

### Create one or more tables

To get started we need to create a table

```powershell
$DataTable = New-DataTable -TableName 'UsersTable'
```

### Add columns to tables

Next we need to add a few columns to the table. First we'll 
add a few plain columns. Secondly we will add a column with 
an expression. This expression concatinates firstname and 
lastname to a displayname. Last we will add a column that has 
a default value in case nothing is set. 

```powershell
Add-DataTableColumn -DataTable $DataTable -Names 'ID','FirstName','LastName'
Add-DataTableColumn -DataTable $DataTable -Names 'DisplayName' -Expression "[FirstName] + ' ' + [LastName]"
Add-DataTableColumn -DataTable $DataTable -Names 'DefaultTheme' -DefaultValue 'Blue'
```

### Add rows to tables

Now that we have a basic strucutre in our users table we can start 
to add rows. The <code>Add-DataTableRow</code> cmdlet accepts 
psobjects as input. The object should contains properties 
corresponding to columns in the DataTable.

```powershell
$NewRow = [pscustomobject]@{
    ID = 1
    FirstName = 'Will'
    LastName = 'Smith'
}
$NewRow | Add-DataTableRow -DataTable $DataTable
```

The content of the data table is now

```powershell
$DataTable | Format-Table

ID FirstName LastName DisplayName DefaultTheme
-- --------- -------- ----------- ------------
 1 Will      Smith    Will Smith  Dark
```

### Create a dataset

In case several data tables are needed a data set can be 
created. A data set can be viewed as a container of data 
tables and provides a few extra capabilities like data 
table relations. To create a data set and add tables run 
the following commands.

```powershell
$DataSet = New-DataSet
Add-DataSetTable -Dataset $Dataset -DataTable $DataTable
```
