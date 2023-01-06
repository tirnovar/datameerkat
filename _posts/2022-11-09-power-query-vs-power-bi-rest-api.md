---
layout: post # type of content
title: Power Query vs. Power BI Rest API # title of the post
description: The Power BI Service hides data that is not visible at first peek but can help us control the Service and properly check whether there are any irregularities. It may sound a bit recursive, but let's get this data into Power BI using Power Query so we can start creating reports from it. Why to leave your favorite tool when there is no need for that at all. # will be shown as a description in the post list
date: 2022-11-09 10:00:00 +0100 # date of the post
author: Štěpán # author name
image: '/images/covers/power-query-vs-power-bi-rest-api.png' # required to store image in /images/covers
image_caption: '' # optional
tags: [power_query, rest_api, admin, azure] # tag names should be lowercase
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

<script src="https://gist.github.com/tirnovar/05edecf93fb62677040fc3e6a60246e0.js"></script>
<br>

**Datasets from selected Group:**

<script src="https://gist.github.com/tirnovar/0010bb1b1f86cf35f93a97c8d87f9f73.js"></script>
<br>

**Datasets from selected Group - Table generation:**

<script src="https://gist.github.com/tirnovar/d11bc103e5151e5827769e8942e45818.js"></script>