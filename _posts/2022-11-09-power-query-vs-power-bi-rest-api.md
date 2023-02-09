---
layout: post # type of content
title: Power Query vs. Power BI Rest API # title of the post
description: The Power BI Service hides data that is not visible at first peek but can help us control the Service and properly check whether there are any irregularities. It may sound a bit recursive, but let's get this data into Power BI using Power Query so we can start creating reports from it. Why to leave your favorite tool when there is no need for that at all. # will be shown as a description in the post list
date: 2022-11-09 10:00:00 +0100 # date of the post
author: Štěpán # author name
image: '/images/covers/power-query-vs-power-bi-rest-api.png' # required to store image in /images/covers
image_caption: '' # optional
tags: [m, power_query, rest_api, admin, azure] # tag names should be lowercase
featured: false # set to true to show on homepage
---
I presented this topic to the [Iowa Power BI User Group](https://www.pbiusergroup.com/communities/community-home?CommunityKey=e6e66122-e621-4bba-8adb-17fb68b9c419) (Their [Meetup](https://www.meetup.com/IowaPowerBI/)), and the entire recording can be viewed here:

<p><iframe src="https://www.youtube.com/embed/RfsVPeot-r8" loading="lazy" frameborder="0" allowfullscreen></iframe></p>

## Links that are mentioned in video

* [Datasets - Get Dataset](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-dataset?id=DP-MVP-5003801)
* [Power BI Admin REST API Connector](https://github.com/tirnovar/Power-BI-Admin-REST-API-Connector)
* [get-BearerToken - Custom Power Query function](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/Power%20BI%20Service%20Token/get-BearerToken.pq)
* [Chris Webb - Power BI Data Privacy Levels And Cloud /Web-Based Data Sources Or Dataflows](https://blog.crossjoin.co.uk/2019/01/13/power-bi-data-privacy-cloud-web-data-sources/)

## Power Query codes from video

**Get Token:**

{% highlight pq %}
let
    output =
        (AzureADTenantID as text, AzureApplicationClientSecret as text, AzureApplicationClientID as text) as text =>
            let
                resource = "https://analysis.windows.net/powerbi/api",
                tokenResponse =
                    Json.Document(
                        Web.Contents(
                            "https://login.windows.net",
                            [
                                RelativePath = AzureADTenantID & "/oauth2/token",
                                Content =
                                    Text.ToBinary(
                                        Uri.BuildQueryString(
                                            [
                                                client_id = AzureApplicationClientID,
                                                resource = resource,
                                                grant_type = "client_credentials",
                                                client_secret = AzureApplicationClientSecret
                                            ]
                                        )
                                    ),
                                Headers = [
                                    Accept = "application/json"
                                ],
                                ManualStatusHandling = {
                                    400
                                }
                            ]
                        )
                    ),
                token_output =
                    tokenResponse[token_type]
                    & " "
                    & tokenResponse[access_token]
            in
                token_output,
    documentation = [
        Documentation.Name = " get-BearerToken.pq ",
        Documentation.Description = " Get Bearer Token needed for Power BI REST API calls ",
        Documentation.Source = "https://www.datameerkat.com",
        Documentation.Version = " 1.0 ",
        Documentation.Author = " Štěpán Rešl "
    ]
in
    Value.ReplaceType(
        output,
        Value.ReplaceMetadata(
            Value.Type(output),
            documentation
        )
    )
{% endhighlight %}

**Datasets from selected Group:**

{% highlight pq %}
let
    apiCall =
        Json.Document(
            Web.Contents(
                "https://api.powerbi.com/v1.0/myorg",
                [
                    RelativePath = "admin/groups/"& groupsId &"/datasets",
                    Headers = [
                        #"Content-Type" = "application/json",
                        Authorization = generatedToken
                    ]
                ]
            )
        )
in
    apiCall[value]
{% endhighlight %}

**Datasets from selected Group - Table generation:**

{% highlight pq %}
let
    apiCall =
        Json.Document(
            Web.Contents(
                "https://api.powerbi.com/v1.0/myorg",
                [
                    RelativePath = "admin/groups/"& groupsId &"/datasets",
                    Headers = [
                        #"Content-Type" = "application/json",
                        Authorization = generatedToken
                    ]
                ]
            )
        )
in
    #table(
        type table [
            id = text,
            name = text,
            addRowsAPIEnabled = logical,
            configuredBy = text,
            isRefreshable = logical,
            isEffectiveIdentityRequired = logical,
            isEffectiveIdentityRolesRequired = logical,
            isOnPremGatewayRequired = logical,
            webUrl = text,
            targetStorageMode = text,
            createdDate = datetime,
            createReportEmbedURL = text,
            qnaEmbedURL = text,
            upstreamDatasets = list
        ],
        List.Transform(
            apiCall[value],
            each
                {
                    _[id]?,
                    _[name]?,
                    _[addRowsAPIEnabled]?,
                    _[configuredBy]?,
                    _[isRefreshable]?,
                    _[isEffectiveIdentityRequired]?,
                    _[isEffectiveIdentityRolesRequired]?,
                    _[isOnPremGatewayRequired]?,
                    _[webUrl]?,
                    _[targetStorageMode]?,
                    DateTime.From(_[createdDate]?),
                    _[createReportEmbedURL]?,
                    _[qnaEmbedURL]?,
                    _[upstreamDatasets]?
                }
        )
    )
{% endhighlight %}