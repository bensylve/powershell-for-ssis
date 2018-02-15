function createEnvironmentVariable($variableName, $variableValue, $environmentName, $sensitive, $catalogName, $folderName, $serverConnectionString)
{
    # Load assemblies
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.Smo") | Out-Null;

    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $serverConnectionString
 
    $integrationServices = New-Object "Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices" $sqlConnection
 
    $catalog = $integrationServices.Catalogs[$catalogName]

    $folder = $catalog.Folders[$folderName]

    $environment = $folder.Environments[$environmentName]

    $environmentVariable = $environment.Variables[$variableName];

    if (!$environmentVariable)
    {
        $environment.Variables.Add(
            $variableName, 
            [System.TypeCode]::String, $variableValue, [System.Convert]::ToBoolean($sensitive), "")
        $environment.Alter()
        $environmentVariable = $environment.Variables[$variableName];
    }
    else
    {
        $environmentVariable.Value = $variableValue
        $environmentVariable.Sensitive = [System.Convert]::ToBoolean($sensitive)
        $environment.Alter()
    }
}

function setProjectParameterToEnvironmentVariable($parameterName, $environmentVariableName, $catalogName, $folderName, $projectName, $environmentName, $serverConnectionString)
{
    # Load assemblies
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.Smo") | Out-Null;
 
    # Create a connection and get the project
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $serverConnectionString
    $integrationServices = New-Object "Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices" $sqlConnection
    $catalog = $integrationServices.Catalogs[$catalogName]
    $folder = $catalog.Folders[$folderName]    
    $project = $folder.Projects[$projectName]
    $environment = $folder.Environments[$environmentName]
    $environmentVariable = $environment.Variables[$environmentVariableName];
    
    # Set the project parameter value
    $project.Parameters[$parameterName].Set(
        [Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Referenced,
        $environmentVariable.Name)        
        
    $project.Alter()    
}

function createSSISFolder($folderName, $catalogName, $ssisServerConnectionString)
{
    # Load assemblies
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.Smo") | Out-Null;

    $ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"

    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ssisServerConnectionString
 
    $integrationServices = New-Object "Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices" $sqlConnection
 
    $catalog = $integrationServices.Catalogs[$catalogName]

    $folder = $catalog.Folders[$folderName]

    if (!$folder)
    {
        $folder = New-Object "$ISNamespace.CatalogFolder" ($catalog, $folderName, $folderName)            
        $folder.Create()
    }
}

function createSSISEnvironment($environmentName, $folderName, $catalogName, $ssisServerConnectionString)
{
    # Load assemblies
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.Smo") | Out-Null;

    $ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"

    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ssisServerConnectionString
 
    $integrationServices = New-Object "Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices" $sqlConnection
 
    $catalog = $integrationServices.Catalogs[$catalogName]

    $folder = $catalog.Folders[$folderName]

    $environment = $folder.Environments[$environmentName]

    if (!$environment)
    { 
        $environment = New-Object "$ISNamespace.EnvironmentInfo" ($folder, $environmentName, $environmentName)
        $environment.Create()            
    }
}

function deploySSISProject($projectName, $projectFilePath, $folderName, $catalogName, $ssisServerConnectionString)
{
    # Load assemblies
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.Smo") | Out-Null;

    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ssisServerConnectionString
 
    $integrationServices = New-Object "Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices" $sqlConnection
 
    $catalog = $integrationServices.Catalogs[$catalogName]

    $folder = $catalog.Folders[$folderName]

    [byte[]] $projectFile = [System.IO.File]::ReadAllBytes($projectFilePath)
    $folder.DeployProject($projectName, $projectFile) | Out-Null
}

function addEnvironmentReferenceToSSISProject($projectName, $environmentName, $folderName, $catalogName, $ssisServerConnectionString)
{
    # Load assemblies
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.Smo") | Out-Null;

    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ssisServerConnectionString
 
    $integrationServices = New-Object "Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices" $sqlConnection
 
    $catalog = $integrationServices.Catalogs[$catalogName]

    $folder = $catalog.Folders[$folderName]

    $environment = $folder.Environments[$environmentName]

    $project = $folder.Projects[$projectName]

    $ref = $project.References[$environmentName, $folder.Name]

    if (!$ref)
    {
        $project.References.Add($environmentName, $folder.Name)
        $project.Alter() 
    }
}