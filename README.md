{:toc}

# AzureOAuthTestApps
Building Apps in Azure to Test OAuth Authentication Flows

This repository contains a Powershell Script which creates a Test Environment with multiple Azure Apps.  
These Apps are used to test OAuth Authentication flows. 

The Postman Collections to Test OAuth are available by Micrsoft directly.  
See Top of the Page.  


## Client Credential Flow
The first and currently only implementation is the client credential flow.  
This Example Uses a Resource Server App that hosts three AppRoles.  
The Client receives Permission to two AppRoles from this Server.  
