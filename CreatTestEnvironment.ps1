#Connect to Azure AD
Connect-AzureAD

#Get TenantID and define App Names
$tenantID=(Get-AzureADTenantDetail).objectid
$ClientAppName = "Resource Client - OAuthTest"
$ServerAppName = "Resource Server - OAuthTest"

#Create blank Applications and Service Principals
$ClientAppObject = New-AzureADApplication -DisplayName $ClientAppName
$ServerAppObject = New-AzureADApplication -DisplayName $ServerAppName
Start-Sleep -Seconds 5 
$ClientAppSP=New-AzureADServicePrincipal -AppID "$($ClientAppObject.AppID)"
$ServerAppSP=New-AzureADServicePrincipal -AppID "$($ServerAppObject.AppID)"

#Generate the Api URL which will be used as Scope and set it
$ApiURL="api://$($ServerAppObject.appid)"
Set-AzureADApplication -ObjectID $($ServerAppObject.objectid) -IdentifierUris @("$($ApiURL)")

#First Approle 
$AppRole1Name="File.Read"
$AppRole1=New-Object Microsoft.Open.AzureAD.Model.AppRole
$AppRole1.AllowedMemberTypes="Application"
$AppRole1.Description="Role for reading files"
$AppRole1.DIsplayname="$($AppRole1Name)"
$Approle1.isEnabled=$TRUE
$Approle1.Value="$($AppRole1Name)"
$Approle1.ID="$(([guid]::NewGuid()).guid)"

#Second Approle
$AppRole2Name="File.Write"
$AppRole2=New-Object Microsoft.Open.AzureAD.Model.AppRole
$AppRole2.AllowedMemberTypes="Application"
$AppRole2.Description="Role for Writing files"
$AppRole2.DIsplayname="$($AppRole2Name)"
$Approle2.isEnabled=$TRUE
$Approle2.Value="$($AppRole2Name)"
$Approle2.ID="$(([guid]::NewGuid()).guid)"

#Third Approle
$AppRole3Name="User.Read"
$AppRole3=New-Object Microsoft.Open.AzureAD.Model.AppRole
$AppRole3.AllowedMemberTypes="Application"
$AppRole3.Description="Role for reading User properties"
$AppRole3.DIsplayname="$($AppRole3Name)"
$Approle3.isEnabled=$TRUE
$Approle3.Value="$($AppRole3Name)"
$Approle3.ID="$(([guid]::NewGuid()).guid)"

#Add the Approles to the Resource Server Application
Set-AzureADApplication -ObjectID $($ServerAppObject.objectid) -AppRoles @($Approle1,$AppRole2,$AppRole3)

#Create a Application Secret for Resource Client Application
$startDate = Get-Date
$endDate = $startDate.AddYears(1)
$ClientAppSecret = New-AzureADApplicationPasswordCredential -ObjectId $($ClientAppObject.Objectid) -CustomKeyIdentifier "mySecret" -StartDate $startDate -EndDate $endDate

#Define Required Approles for Client App
$req = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$acc1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "$($AppRole2.id)","Role"
$acc2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "$($AppRole3.id)","Role"
$req.ResourceAccess = $acc1,$acc2
$req.ResourceAppId = "$($ServerAppObject.Appid)"

#Add Required AppRoles to Client App
Set-AzureADApplication -ObjectId $($ClientAppObject.objectid) -RequiredResourceAccess $req

#Make the Approle Assignment
New-AzureADServiceAppRoleAssignment -Id $AppRole2.ID -ResourceId $($ServerAppSP.Objectid) -ObjectId $($ClientAppSP.Objectid) -PrincipalId $($ClientAppSP.Objectid)
New-AzureADServiceAppRoleAssignment -Id $AppRole3.ID -ResourceId $($ServerAppSP.Objectid) -ObjectId $($ClientAppSP.Objectid) -PrincipalId $($ClientAppSP.Objectid)


#Output Everything we need for the Postman Request(s)
Write-Output ""
Write-Output ""
Write-Output "These are your settings:"
Write-Output ""
Write-Output "client_id: $($ClientAppObject.Appid)"
Write-Output "client_secret: $($ClientAppSecret.Value)"
Write-Output "Uri: https://login.microsoftonline.com/$($tenantID)/oauth2/v2.0/token"
Write-Output "scope: $($ApiURL)/.default"
