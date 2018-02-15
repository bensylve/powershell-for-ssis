Write-Host ""
Write-Host "*************** Beginning SSIS Deployment Process ***************"
Write-Host ""

# Assumes the powershell scripts are in a sub-folder called POWERSHELL_FUNCTIONS and the xml config is in a subfolder called CONFIG_FILES.
# Also assumes the script being run is in the current powershell directory.

# Import functions used by the procedure
. '.\POWERSHELL_FUNCTIONS\SSIS_Functions.ps1'


# Get xml config file
[xml] $ssisDeploymentsXmlDoc = Get-Content .\CONFIG_FILES\SSIS_Deployments.xml
$ssisDeployments = $ssisDeploymentsXmlDoc.SelectNodes("//SSISDeployment")


# Loop through each deployment and setup environments and projects
foreach($ssisDeployment in $ssisDeployments)
{

    # Set connection string to server using windows credentials of the logged on user / process executing the script
    $ssisServerConnectionString = "Data Source=" + $ssisDeployment.server + ";Initial Catalog=master;Integrated Security=SSPI;"


    foreach($ssisFolder in $ssisDeployment.SSISFolder)
    {
        # Create the folder. It will only get created if it does not exist.
        Write-Host "Creating the folder" $ssisFolder.name "..."
        createSSISFolder $ssisFolder.name $ssisDeployment.catalog $ssisServerConnectionString

        # Setup the environments. They will only get created if they don't exist.
        foreach($ssisEnvironment in $ssisFolder.SSISEnvironment)
        {
            Write-Host "Updating the environment" $ssisEnvironment.name "..."
            createSSISEnvironment $ssisEnvironment.name $ssisFolder.name $ssisDeployment.catalog $ssisServerConnectionString 

            # Setup environment variables
            Write-Host "Setting up environment variables for" $ssisEnvironment.name "..."
            foreach($ssisEnvironmentVariable in $ssisEnvironment.SSISEnvironmentVariable)
            {
                $sensitive = [System.Convert]::ToBoolean($ssisEnvironmentVariable.sensitive)                                
                createEnvironmentVariable $ssisEnvironmentVariable.name $ssisEnvironmentVariable.value $ssisEnvironment.name $sensitive $ssisDeployment.catalog $ssisFolder.name $ssisServerConnectionString                
            }

            foreach($ssisSharedEnvironmentVariable in $ssisFolder.SSISEnvironmentSharedVariables.SSISSharedEnvironmentVariable)
            {
                $sensitive = [System.Convert]::ToBoolean($ssisSharedEnvironmentVariable.sensitive)    
                createEnvironmentVariable $ssisSharedEnvironmentVariable.name $ssisSharedEnvironmentVariable.value $ssisEnvironment.name $sensitive $ssisDeployment.catalog $ssisFolder.name $ssisServerConnectionString 
            }
        }

        # Setup the projects
        foreach($ssisProject in $ssisFolder.SSISProject)
        {
            Write-Host "Updating the project" $ssisProject.name "..."
            $resolvedPath = Resolve-Path $ssisProject.deploymentFile
            deploySSISProject $ssisProject.name $resolvedPath $ssisFolder.name $ssisDeployment.catalog $ssisServerConnectionString   

            Write-Host "Setting project parameter / environment variable references for" $ssisProject.name "..."
            foreach($ssisProjectEnvironmentReference in $ssisProject.SSISProjectEnvironmentReference)
            {
                addEnvironmentReferenceToSSISProject $ssisProject.name $ssisProjectEnvironmentReference.environment $ssisFolder.name $ssisDeployment.catalog $ssisServerConnectionString         
                foreach($ssisProjectParameterEnvironmentVariableReference in $ssisProjectEnvironmentReference.SSISProjectParameterEnvironmentVariableReference)
                {
                    setProjectParameterToEnvironmentVariable $ssisProjectParameterEnvironmentVariableReference.projectParameter $ssisProjectParameterEnvironmentVariableReference.environmentVariable $ssisDeployment.catalog $ssisFolder.name $ssisProject.name $ssisProjectEnvironmentReference.environment $ssisServerConnectionString
                }                
            }
        }
    }

}


Write-Host ""
Write-Host "*************** Deployment Complete ***************"
Write-Host ""