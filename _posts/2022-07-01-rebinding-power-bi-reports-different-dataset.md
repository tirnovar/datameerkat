---
layout: post # type of content
title: Rebinding Power BI Reports to Different Dataset # title of the post
description: Duplicate Power BI Dataset, from which colleagues have already managed to make their reports? Doesn't that sound scary? Personally yes! # will be shown as a description in the post list
date: 2022-07-01 10:00:00 +0100 # date of the post
author: Štěpán # author name
image: '/images/covers/rebinding-power-bi-reports-different-dataset.png' # required to store image in /images/covers
image_caption: '' # optional
tags: [admin, service, rest_api, powershell] # tag names should be lowercase
featured: false # set to true to show on homepage
---
An unpleasant dream that may come true. That is how I would describe a scenario I want to share with you. Imagine that you have prepared a Power BI dataset, have built a report on top of it, and published it all to a shared workspace. This is still common. But imagine a new colleague comes along who is just starting in Power BI and doesn't yet fully understand what datasets, reports, or applications mean. He wants to make his report from your dataset. So instead of using the "Create Report" function from your shared dataset, he downloads it, creates a report according to his needs in Power BI Desktop, and publishes it back to Power BI Service with a different name so that he does not overwrite yours. Then he finally finds out that new reports can be built from existing datasets and builds another one. So now you have two identical datasets and three reports.

![Multiple reports connected to wrong dataset]({{site.baseurl}}/images/posts/Rebinding Power BI Reports to Different Dataset/reportConnectedToWrongDataset.png){:loading="lazy"}
*Multiple reports connected to wrong dataset*

This is a scenario that defies any best practices. But, unfortunately, it can happen... There is no point in talking about how it has happened or why. Instead, let's see what can be done about it. 

An ideal scenario is to have only one dataset and all reports based on it. So there is one source of truth and one data source load. That sounds better right? 

![Moved report to correct dataset]({{site.baseurl}}/images/posts/Rebinding Power BI Reports to Different Dataset/reportMovedToOtherDataset.png){:loading="lazy"}
*Moved report to correct dataset*

However, in the Power BI Service, there is no way to tell the report to change its dataset directly, and if I have more than one report from the dataset, then there is another problem because I do not have the option to download it and edit it in Power BI Desktop to at least change the connection string. 

## So how can I link the report to another dataset?
The short answer is the Power BI REST API. This type of call can be found within the API [Reports - Rebind Report In Group - REST API (Power BI Power BI REST APIs)](https://learn.microsoft.com/en-us/rest/api/power-bi/reports/rebind-report-in-group?id=DP-MVP-5003801)

<div class="codebox">POST https://api.powerbi.com/v1.0/myorg/groups/{groupId}/reports/{reportId}/Rebind</div><br>

However, for the successful execution of the call, it is necessary to obtain **{groupId}**, **{reportId}**, **{datasetId}** and fulfill a few criteria. The **{groupId}** and **{reportId}** are to be found on the report that we need to move and **{datasetId}** on the dataset to which we will move the report.

The easiest way to obtain these IDs is, in principle, via a web browser, where we need to open the report and look at the website's URL address.

![Group and Dataset ID in URL]({{site.baseurl}}/images/posts/Rebinding Power BI Reports to Different Dataset/ids.png){:loading="lazy"}
*Group and Dataset ID in URL*

So for this demo I have:
* groupId = 0b6e10b5-a7ab-4d0a-a4bb-b6088eed815f
* reporId = 4824d3a6-3e02-42ae-960d-bd0d81391186

And for the second report, its ID is "f5b7e9ce-8437-4bd3-a0a6-1e5b94ec3192" and the datasetId is "add28670-b845-482f-b97b-9d0e32395591".  

After obtaining this data, I still need to decide whether I will perform the fixing from the perspective of the Service Principal or the perspective of the user. Each of these variants has a different subsequent approach to the solution, mainly when it comes to acquiring the access token, which is necessary for our scenarios. In both cases, however, I have to meet two requirements: 

* I need **Write** permission within the report selected by me.
* I need **Build** permission on the dataset to which I want to move the report. 

I also need **"Report.ReadWrite.All"** from a permission API perspective. Assuming I meet all these conditions, I can proceed to the API call.

## API calls from the Service Principal perspective

For this call, I will use the Postman service, where I will first make an authentication call to get a token, which I will then use to authenticate directly against the Power BI Service. I make this call using the following curl: 

{% highlight html %}
curl --location --request POST 'https://login.microsoftonline.com/{tenantId}/oauth2/token' 
--header 'Host: login.microsoftonline.com' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id={clientId}' \
--data-urlencode 'client_secret={clientSecret} ' \
--data-urlencode 'resource=https://analysis.windows.net/powerbi/api'\
{% endhighlight %}

Where I just change {clientId}, {clientSecret} and {tenantId} to the respective values. I demonstrated how to get them, for example, in [Querying Power BI Datasets by DAX through Admin API](https://www.linkedin.com/pulse/querying-power-bi-datasets-dax-through-admin-api-%C5%A1t%C4%9Bp%C3%A1n-re%C5%A1l/). And I will take the Access Token from the answer.

![Access Token]({{site.baseurl}}/images/posts/Rebinding Power BI Reports to Different Dataset/accessToken.png){:loading="lazy"}
*Access Token*

The following call is the one we needed to get the **groupId**, **reportId**, and **datasetId**. 

![Dataset ID]({{site.baseurl}}/images/posts/Rebinding Power BI Reports to Different Dataset/datasetId.png){:loading="lazy"}
*Dataset ID*

Curl notation for call:

{% highlight html %}
curl --location --request POST 'https://api.powerbi.com/v1.0/myorg/groups/{groupId}/reports/{reportId}/Rebind' 
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer {Accss Token}' \
--data-raw '{
    "datasetId":"{datasetId}"
}'\
{% endhighlight %}

I got a status **200** after the call which means it was successful. I can confirm this in Power BI Service, where I see the **"HR cockpit v2"** connected to the correct dataset!

![First report moved]({{site.baseurl}}/images/posts/Rebinding Power BI Reports to Different Dataset/firstMovement.png){:loading="lazy"}
*First report moved*

## API calls from the User's point of view
Assuming that I am a user who meets the requirements mentioned above, I can do this myself – for example, using PowerShell. It is necessary to have PowerShell modules installed ([Power BI Cmdlets reference | Microsoft Docs](https://learn.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps&id=DP-MVP-5003801)), which can help you solve many things – for example, the user's Access Token we need. We can get it in the module just by using the following code

{% highlight powershell %}
Login-PowerBI

$token = (Get-PowerBIAccessToken)["Authorization"]

$body = @{ "datasetId" = "TARGET_DATASET_ID" }

Invoke-WebRequest `
 -Method 'Post' `
 -Uri "https://api.powerbi.com/v1.0/myorg/groups/0b6e10b5-a7ab-4d0a-a4bb-b6088eed815f/reports/f5b7e9ce-8437-4bd3-a0a6-1e5b94ec3192/Rebind" `
 -Headers @{ "Authorization"=$token } `
 -Body ($body|ConvertTo-Json) `
 -ContentType "application/json"
{% endhighlight %}

After calling the first line, you will get a classic login window, and after you log in, PowerShell will tell you which Environment you have logged in to. Then you can save the obtained **AccessToken** in the **$token** variable. 

![Power Shell login]({{site.baseurl}}/images/posts/Rebinding Power BI Reports to Different Dataset/shellLogin.png){:loading="lazy"}
*Power Shell login*

JSON with datasetId can then be stored in the $body variable, and the API can be called via the **Invoke-WebRequest** method.

Here, as well as with using the Service Principal approach, a status 200 was returned, indicating that everything was successful. We can also make sure in the Power BI Service, where all reports are correctly transferred to the original dataset. 

![Result of Power Shell command]({{site.baseurl}}/images/posts/Rebinding Power BI Reports to Different Dataset/result.png){:loading="lazy"}
*Result of Power Shell command*

## Summary
As I mentioned, this situation should not occur at all. There must be procedures in place preventing this to happen, the users must be trained. Still, when such a situation occurs, it is necessary to be able to take action. As I have tried to demonstrate, there are solutions. Either through Service Principal access or your personal. If you ever find yourself dealing with a similar situation, I hope this guide will come in handy. Otherwise, I wish you will never have to deal with it. 