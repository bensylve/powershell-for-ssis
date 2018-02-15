# powershell-for-ssis
This code has a few functions that help automate some common SSIS tasks including:

* Deploying an ispac file from an SSIS project "build" (deploySSISProject)
* Creating folders in SSIS running on a SQL Server (createSSISFolder)
* Creating an SSIS Environment (createSSISEnvironment)
* Creating SSIS Environment variables (createEnvironmentVariable)
* Adding a reference from an SSIS project to an SSIS Environment (addEnvironmentReferenceToSSISProject)
* Mapping an SSIS Project Parameter to an SSIS Environement Variable (setProjectParameterToEnvironmentVariable)

This would be used in a workflow such as:

1. Create a folder in SSIS to hold my project.
2. Create one or more environments that will hold the configuration options for my project.
3. Setup the environment variables to store the configured values for my project.
4. Deploy the project to the folder that was created.
5. Set the project to reference the environment.
6. Map the project parameters to the environment variables.

These steps when done manually can be a pain. These scripts help to ease that pain by making the process repeatable.
