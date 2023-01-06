---
layout: post # type of content
title: Dynamic windows in calculation groups # title of the post
description: The WINDOWS function is becoming very popular because it can save a lot of time both for the execution of the calculation and for the development itself. At the same time, this is the last of the new functions I need to test against Calculation Groups. # will be shown as a description in the post list
date: 2023-01-06 10:00:00 +0100 # date of the post
author: Štěpán # author name
image: '/images/covers/dynamic-windows-in-calculation-groups.png' # required to store image in /images/covers
image_caption: '' # optional
tags: [dax, calculation_groups, field_parameters, window] # tag names should be lowercase
featured: true # set to true to show on homepage
---
It is a function that can create a moving "window" above the input table and apply it to the computing context. That **"window"** is defined quite similarly, as it was in the case of the **INDEX** function. Or that the numerical representation of the position **(0)1...X or X...-1(0)** is used. But there is one fundamental difference. **INDEX** requires only one such representative, **but the WINDOW function requires two.**

Overall, the syntax can be confusing at first glance, so I'd rather spend some time on it:


<div class="codebox">WINDOW ( from[, from_type], to[, to_type][, <\relation>][, <\orderBy>][, <\blanks>][, <\partitionBy>] )</div><br>

[Official documentation for WINDOWS function](https://learn.microsoft.com/en-us/dax/window-function-dax?id=DP-MVP-5003801)

Fascinating are the parameters **"FROM"** and **"TO"** and the mentioned **"from_type"** and **"to_type."** This may be completely obvious to someone, but I have already had the honor of encountering the question. "From To? How is that direction meant?"

It all depends on the mentioned *"type" parameters*. There are precisely two values ​​that these parameters take:
- *ABS*
- *REL*

When you use the REL value, **"FROM"** or **"TO"** moves along the time axis with a positive number to the right and a negative one to the left. It is always a movement from the currently evaluated row of the input table. At the same time, the value 0 can be used for **"FROM"** or **"TO"** so that the just mentioned line is used as a **"start"** or **"end"** within the **Window**.

The ABS value is reminiscent of the **INDEX** function since **1** means the beginning of the input table/partition, and **-1** the last line. The difference with **INDEX** (to remind you) is that **WINDOW** returns a range of rows, not just one row.

Of course, these *"type" parameters* can be combined so that you can have *"ABS"* for **"FROM"** and *"REL"* for *"TO."* This is great for calculations of the **YTD (Year-To-Date)** type.

## Let's try it
For the DEMO, I will use the model I already used in the previous article regarding the **INDEX** function.

![Data model]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/datamodel.png){:loading="lazy"}
*Data model*

And initial chart:

![Revenue]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/revenue.png){:loading="lazy"}
*Revenue*

Here we have prepared a graph that contains the monthly results of Revenue. Of course, before the advent of the **WINDOW** function, we would do **YTD** equivalents using the **TOTATYTD**, **DATESYTD**, **DATESBETWEEN**, or **FILTER** functions, for example. But WINDOW should put these methods in its pocket.

Using WINDOW, it might look like this:

<div class="codebox">#&nbsp;Sum&nbsp;Revenue&nbsp;YTD&nbsp;Window&nbsp;=<br><span class="Keyword" style="color:#035aca">CALCULATE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span>[#&nbsp;Sum&nbsp;of&nbsp;Revenue&nbsp;from&nbsp;Pipepine],<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">WINDOW</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;<span class="Number" style="color:#EE7F18">1</span>,&nbsp;ABS,&nbsp;<span class="Number" style="color:#EE7F18">0</span>,&nbsp;REL,&nbsp;<span class="Keyword" style="color:#035aca">ALLSELECTED</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;DateKey[Year],&nbsp;DateKey[Month]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ORDERBY</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;DateKey[Year]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span>KEEP,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">PARTITIONBY</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;DateKey[Year]&nbsp;<span class="Parenthesis" style="color:#808080">)</span><br><span class="Parenthesis" style="color:#808080">)</span></div><br>

Within the function, I use the parameter *FROM = 1* with *TYPE = ABS*, so I declare the Window from the beginning of the input table, and the parameter *TO = 0* with *TYPE = REL*, so the Window ends with the current line. Without the **PARTITIONBY** function aimed at **\[Year]**, we would have a selected-period-to-date calculation. Because the **PARTITIONBY** function is present, it creates individual partitions in the specified table based on the specified input. In our case, based on individual years. So *FROM = 1*, *TYPE = ABS* will always be the first day of the currently executed Year. Not in the very first Year of the entire entry.

Which can be seen in the graph:

![Revenue YTD]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/revenueYtd.png){:loading="lazy"}
*Revenue YTD*

At the same time, if we wanted to calculate the **Year-End (YE)** value in combination with **PARTITIONBY**, *TYPE = ABS* would help us in both cases. Both *FROM = 1* and *TO = -1*. In short, it would set us back the whole Year.

We can also slightly modify the metric used, for example, to get a different but equally important calculation! Specifically, the **Trailing Twelve-Month (T12M)**:

<div class = "codebox">#&nbsp;Sum&nbsp;Revenue&nbsp;T12M&nbsp;Window&nbsp;=<br><span class="Keyword" style="color:#035aca">CALCULATE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span>[#&nbsp;Sum&nbsp;of&nbsp;Revenue&nbsp;from&nbsp;Pipepine],<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">WINDOW</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;<span class="Number" style="color:#EE7F18">-12</span>,&nbsp;REL,&nbsp;<span class="Number" style="color:#EE7F18">0</span>,&nbsp;REL,&nbsp;<span class="Keyword" style="color:#035aca">ALLSELECTED</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;DateKey[Year],&nbsp;DateKey[Month]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span><br><span class="Parenthesis" style="color:#808080">)</span></div><br>

And the graph also beautifully reflected our change:

![Revenue T12M]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/revenueT12M.png){:loading="lazy"}
*Revenue T12M*

Although it was only a tiny change in the metric, the result is entirely different and correct. In this, the WINDOW function is great, clear, and, above all, fast.

I often encounter the requirement that the user be able to switch between these types of calculations himself. As for switching to a single metric, we can solve it in different ways... quickly via a disconnected table. But what about dynamically? So that the user can, for example, select the metrics he wants to see via "Personalize your Visuals" or promote them inside the graph using Field of Measures. So we have to reach for Calculation Groups.

## Cooperation with the Calculation Group
Let's prepare three essential items on which we can test this behavior. We already have two in a way (they are mentioned above). First, we just replaced the measure with **SELECTEDMEASURE()**.

![Calculation Group]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/calculationGroup.png){:loading="lazy"}
*Prepared Calculation Group*

That last item will be selected-period-to-date (let's give it an abbreviation like **PTD**):

<div class="codebox"><span class="Keyword" style="color:#035aca">CALCULATE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">SELECTEDMEASURE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">WINDOW</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Number" style="color:#EE7F18">1</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>ABS,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Number" style="color:#EE7F18">0</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>REL,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ALLSELECTED</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;DateKey[Year],&nbsp;DateKey[Month]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ORDERBY</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;DateKey[Year]&nbsp;<span class="Parenthesis" style="color:#808080">)</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">)</span><br><span class="Parenthesis" style="color:#808080">)</span></div><br>

![Created PTD Calculation Item]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/ptd.png){:loading="lazy"}
*Created PTD Calculation Item*

Let's load this calculation group of ours into the model and for now, let's try to apply the last mentioned item using Slicer, for example, to check that everything works.

![PTD Item activated via Slicer]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/activatedPTD.png){:loading="lazy"}
*PTD Item activated via Slicer*

Everything works as expected, which is good news! I'm glad we didn't run into any surprises. But let's load it with **Field of Measures**.

I will create a **fieldOfMeasures** from three other measures, but they will have approximately similar Y-axis values. I really don't want to mix apples and pears. So I selected **Revenue**, **Pipeline Potential**, and **Costs**:

<div class="codebox">fieldOfMeasure&nbsp;=<br>{<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">(</span>&nbsp;<span class="StringLiteral" style="color:#D93124">"Revenue"</span>,&nbsp;<span class="Keyword" style="color:#035aca">NAMEOF</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;'Measure'[#&nbsp;Sum&nbsp;of&nbsp;Revenue&nbsp;from&nbsp;Pipepine]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="Number" style="color:#EE7F18">0</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">(</span>&nbsp;<span class="StringLiteral" style="color:#D93124">"Potential"</span>,&nbsp;<span class="Keyword" style="color:#035aca">NAMEOF</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;'Measure'[#&nbsp;Sum&nbsp;of&nbsp;Pipeline&nbsp;Potential]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="Number" style="color:#EE7F18">1</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">(</span>&nbsp;<span class="StringLiteral" style="color:#D93124">"Costs"</span>,&nbsp;<span class="Keyword" style="color:#035aca">NAMEOF</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;'Measure'[#&nbsp;Costs&nbsp;of&nbsp;Products]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="Number" style="color:#EE7F18">2</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span><br>}</div><br>

Will the prepared expression in the calculation group be okay with it? To make the results more visible, I'll switch from a bar chart to a line chart. After all, only three types of columns would probably not read very well with so many "categories" within the X-axis.

![Measures provided via Field Parameter modified by Calculation item with WINDOW function]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/fieldParameterInAction.png){:loading="lazy"}
*Measures provided via Field Parameter modified by Calculation item with WINDOW function*

No problem with that at all! *I almost don't want to believe it.* I can also select only some parameters, and everything will recalculate correctly.

![Selected Revenue and Potential only]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/selectionOfItems-PTD.png){:loading="lazy"}
*Selected Revenue and Potential only*

![YTD Calculation]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/ytdCalculation.png){:loading="lazy"}
*YTD Calculation*

![T12M Calculation]({{site.baseurl}}/images/posts/Dynamic windows in calculation groups/t12mCalculation.png){:loading="lazy"}
*T12M Calculation*

## Summary

During the tests, I did not encounter any major obstacle or specialty, such as the multiple movements of the **OFFSET** function. The **WINDOW** function is probably the most transparent and readable of all the newly added functions: (**OFFSET**, **INDEX**, **WINDOW**).

**You will love the WINDOW function as much as I do, and it will become part of your regularly used functions.**

If you are interested in any more information about **WINDOW**, I recommend the following links:
* [Introducing DAX Window Functions (Part 1) – pbidax (wordpress.com)](https://pbidax.wordpress.com/2022/12/15/introducing-dax-window-functions-part-1/)
* [INTRODUCING DAX WINDOW FUNCTIONS (PART 2) – pbidax (wordpress.com)](https://pbidax.wordpress.com/2022/12/23/introducing-dax-window-functions-part-2/)
* [Unlock an ample new world by seeing through a window - Mincing Data - Gain Insight from Data (minceddata.info)](https://www.minceddata.info/2022/12/14/unlock-an-ample-new-world-by-seeing-through-a-window/)
* [Looking through the WINDOW - Calculating customer lifetime value with new DAX functions! - Data Mozart (data-mozart.com)](https://data-mozart.com/looking-through-the-window-calculating-customer-lifetime-value-with-new-dax-functions/)