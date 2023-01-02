---
layout: post # type of content
title: Conditional Formatting based on Field Parameters # title of the post
description: INDEX + Calculation Groups + Custom Format String Expression = Quick dynamic answers # will be shown as a description in the post list
date: 2020-09-27 10:00:00 +0100 # date of the post
author: Štěpán # author name
image: '/images/covers/conditional-formatting-based-field-parameters.png' # required to store image in /images/covers
image_caption: '' # optional
tags: [dax, field parameters, format string, conditional formatting] # tag names should be lowercase
featured: false # set to true to show on homepage
---
Conditional formatting is one of the basic building blocks in preparing Power BI Reports. Especially if we want to reduce the time for users to get the answers they came to the report for. But how about conditional formatting when we use field parameters in our model?

*This article follows from the previous article: [Field parameters in cooperation with Calculation groups](https://www.linkedin.com/pulse/field-parameters-cooperation-calculation-groups-%C5%A1t%C4%9Bp%C3%A1n-re%C5%A1l/?lipi=urn%3Ali%3Apage%3Ad_flagship3_pulse_read%3BjYDeGWG1Rj%2Bt4DQw6sVpLA%3D%3D) – I use the same dataset in this article.*

## Conditional Formatting with Field Parameters
Field parameters are tricky in how they are executed. I can either deal with their output or input from a formatting perspective. It sounds rather abstract, but practically it means that I can either look directly into the "return" table of the field parameter or up to the table that is the resulting composition.

I have this table, which is composed of a field of dimensions (field parameter *{Product name, Employee, Location}*) and one Measure:

![Field parameter in Matrix]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/basicSetup.png){:loading="lazy"}
*Field parameter in Matrix*

The Measure used in the table looks like this:

<div class="codebox">selector&nbsp;=<br><span class="Keyword" style="color:#035aca">SWITCH</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">TRUE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;FieldParameterWithDynamicGrouping[FieldParameterWithDynamicGrouping&nbsp;Fields]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"Field"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Products[Product&nbsp;name]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"Product"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Employees[Location]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"Location"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Employees[Employee]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"Employee"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="StringLiteral" style="color:#D93124">"NOPE"</span><br><span class="Parenthesis" style="color:#808080">)</span></div><br>

From its output directly in the table, it can be seen that the output of the table is directly subject to the resulting composition because the **ISINSCOPE()** function does not identify the Field Parameter, which is also part of the return options, but only the result. Therefore, the performance Analyzer can answer if this assumption is correct.

## Performance Analyzer DAX Queries of this table: 
* Direct return of Field parameter:

![DAX Query in DAX Studio]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/returnedQueryInDaxStudio.png){:loading="lazy"}
*DAX Query in DAX Studio*

* Resulted composition:

![Resulted Composition]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/resultedComposition.png){:loading="lazy"}
*Resulted Composition in DAX Studio*

The results are precise. I could still use both variants for conditional formatting. In the case of conditional formatting, I can use any of these outputs. So it is just on me If I will use direct results of Field Parameters or results of a final query. According to my choice, there would be different options for accessing conditional formatting. But which one to choose is a question of purpose and what we are trying to achieve.

So it will be good to set a goal that I am trying to achieve with conditional formatting.

## Single-Selection Scenario
Based on the field parameter, I want to color the background of the cells.

Where:
* Product name = Yellow,
* Employee = Green,
* Location = Blue.

This scenario can then be reused so that the entire report page is always colored according to the selected parameter. So if we are talking about the fact that the Field Parameter is within the Single Selection, then there is no problem for this scenario, and the result can look, for example, as follows:

![Single Color]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/singleColor.png){:loading="lazy"}
*Single Color*

I could still achieve this result using both of the mentioned options. But for this time, I will go the route of using only the resulting query. In that case measure for conditional formatting can look like this:

<div class = "codebox">FieldParameterWithDynamicGroupingSingleSelectColor&nbsp;=<br><span class="Keyword" style="color:#035aca">SWITCH</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">TRUE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Products[Product&nbsp;name]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#F6C300"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Employees[Location]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#0C4B5D"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Employees[Employee]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#5BAC58"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="StringLiteral" style="color:#D93124">"#F6F6F6"</span><br><span class="Parenthesis" style="color:#808080">)</span></div><br>

So the conditional formatting requirement will need to be extended to make the output less trivial. So let's say that if the Product ends with the letter A, it will be a dark yellow color; if it ends with B, it will be light yellow and otherwise white.

A minor metric adjustment and everything still runs as it should:

<div class = "codebox">FieldParameterWithDynamicGroupingSingleSelectColor&nbsp;=<br><span class="Keyword" style="color:#035aca">SWITCH</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">TRUE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Products[Product&nbsp;name]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">VAR</span>&nbsp;<span class="Variable" style="color:#49b0af">_lastLetter</span>&nbsp;=<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">RIGHT</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;<span class="Keyword" style="color:#035aca">SELECTEDVALUE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Products[Product&nbsp;name]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="Number" style="color:#EE7F18">1</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">RETURN</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">SWITCH</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">TRUE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Variable" style="color:#49b0af">_lastLetter</span>&nbsp;=&nbsp;<span class="StringLiteral" style="color:#D93124">"A"</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#F6C300"</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Variable" style="color:#49b0af">_lastLetter</span>&nbsp;=&nbsp;<span class="StringLiteral" style="color:#D93124">"B"</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#F8EAB9"</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="StringLiteral" style="color:#D93124">"#FFFFFF"</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Employees[Location]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#0C4B5D"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Employees[Employee]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#5BAC58"</span>,<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="StringLiteral" style="color:#D93124">"#F6F6F6"</span><br><span class="Parenthesis" style="color:#808080">)</span></div><br>

![Single color gradient]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/littleGradient.png){:loading="lazy"}
*Single color gradient*

**SELECTEDVALUE()** seems to be nicely able to return the value from the returned column from the field parameter, so there is no snag.

## Will this work with Multi-Selection?
Here comes the turning point where the fun stops. **Why?** Because we are in a hierarchy. In addition, a dynamic hierarchy is so dynamic that the same object can sometimes be in the first place, sometimes in the last place—depending on how the user makes up his mind. So how does the current measure fare against such a challenge... **poorly**.

![Expanded Matrix]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/expandedMatrix.png){:loading="lazy"}
*Expanded Matrix*

All categories are yellow. But the question remains "Why?". Simply. The **ISINSCOPE()** function returns **TRUE()** for the *"Product name"* column, even if it just evaluates a value that at first glance looks like a value from the *"Employee"* or *"Location"* column. This is because the array stacks value next to each other within the query and do so in a cascading manner. See the following image:

![Node system of Matrix]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/nodeSystem.png){:loading="lazy"}
*Node system of Matrix*

So it is true that even if I evaluate the second node, the top node's second column contains a value. Therefore, **TRUE()** is also returned. Therefore finding the column's name, the current node, is quite challenging. At first glance, it might help if we looked at the **Field Parameter** in the *"Order"* column.

![Order column in Field Parameter]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/orderInFieldParameters.png){:loading="lazy"}
*Order column in Field Parameter*

**But be careful!** This column is **STATIC**! So it is not calculated according to the returned values, which can be confusing. Mainly when the order within this hierarchy depends on the user's choice.

Fortunately, there are few scenarios for a multi-dimensional field parameter where the user should be able to choose the order of the dimensions and still have conditional formatting tied to a specific field. However, there are more scenarios when we need to solve the degree of immersion of nodes.

## Multi-Selection Scenario
One such scenario might be that I want to adjust the color of the matrix based on the sink of the node.

The total will be the darkest color. All other nodes will be colored using a shader. The lowest node will then be pure white. This color scheme can help users quickly understand that this is a parent level and that it is, for example, summing aggregates.

To calculate the current order of the current node, we can again use the **ISINSCOPE()** function. Specifically by counting the number of positive responses for individual possible nodes. For example, this can be achieved with this option:

<div class="codebox">Node_Level&nbsp;=<br><span class="Keyword" style="color:#035aca">VAR</span>&nbsp;<span class="Variable" style="color:#49b0af">_fields</span>&nbsp;=<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">FILTER</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>{<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Products[Product&nbsp;name]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Employees[Employee]&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">ISINSCOPE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;Employees[Location]&nbsp;<span class="Parenthesis" style="color:#808080">)</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>},<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>[value]<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">)</span><br><span class="Keyword" style="color:#035aca">RETURN</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">COALESCE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;<span class="Keyword" style="color:#035aca">COUNTROWS</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;<span class="Variable" style="color:#49b0af">_fields</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="Number" style="color:#EE7F18">0</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span></div><br>

It may be obvious to some, but I'd point out that Power BI uses the *\[Value]* column name as the default column name. Therefore, we do not define any column name. However, in the field, we defined it with the **ISINSCOPE()** function, so *"Value"* will be used natively for its name.

Thus, the function from the matrix view will return the exact number, as can be seen in the following image:

![Node level in Matrix]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/nodeLevelInMatrix.png){:loading="lazy"}
*Node level in Matrix*

Now it would like to prepare conditional formatting in a similar pattern that will fulfill the original scenario. Since I am talking about dark colors in the script, it must be taken into account that the font should also be able to change the color of the text to white from a particular shade to maintain visibility.

<div class="codebox">conditionalFormattingBasedOnNodeLevelForBackground&nbsp;=<br><span class="Keyword" style="color:#035aca">VAR</span>&nbsp;<span class="Variable" style="color:#49b0af">_node</span>&nbsp;=&nbsp;[Node_Level]<br><span class="Keyword" style="color:#035aca">RETURN</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">SWITCH</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">TRUE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Variable" style="color:#49b0af">_node</span>&nbsp;=&nbsp;<span class="Number" style="color:#EE7F18">3</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#FFFFFF"</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Variable" style="color:#49b0af">_node</span>&nbsp;=&nbsp;<span class="Number" style="color:#EE7F18">2</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#C1C2C7"</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Variable" style="color:#49b0af">_node</span>&nbsp;=&nbsp;<span class="Number" style="color:#EE7F18">1</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#55565E"</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="StringLiteral" style="color:#D93124">"#242424"</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">)</span></div><br>

<div class="codebox">conditionalFormattingBasedOnNodeLevelForFont&nbsp;=<br><span class="Keyword" style="color:#035aca">VAR</span>&nbsp;<span class="Variable" style="color:#49b0af">_node</span>&nbsp;=&nbsp;[Node_Level]<br><span class="Keyword" style="color:#035aca">RETURN</span><br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">SWITCH</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span>&nbsp;<span class="Keyword" style="color:#035aca">TRUE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><span class="Parenthesis" style="color:#808080">)</span>,&nbsp;<span class="Variable" style="color:#49b0af">_node</span>&nbsp;&lt;&nbsp;<span class="Number" style="color:#EE7F18">2</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#FFFFFF"</span>,&nbsp;<span class="StringLiteral" style="color:#D93124">"#000000"</span>&nbsp;<span class="Parenthesis" style="color:#808080">)</span></div><br>

Thanks to them, the output will then look like this:

![Highlighted nodes in Matrix]({{site.baseurl}}/images/posts/Conditional formatting based on field parameters/highlightedNodes.png){:loading="lazy"}
*Highlighted nodes in Matrix*

Similarly, preparing a slicer with a separate table would be possible, allowing the user to highlight the set that interests him.

Another variant for multi-selection scenarios can be specific conditional formatting, which can only be displayed if it is a combination of specific fields. For such a scenario, you can then reach for the return value from the field parameters:

<div class="codebox">activeDimensionsOfFieldParameterWithDynamicGrouping&nbsp;=<br><span class="Keyword" style="color:#035aca">VAR</span>&nbsp;<span class="Variable" style="color:#49b0af">_selection</span>&nbsp;=<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">SELECTCOLUMNS</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Keyword" style="color:#035aca">SUMMARIZE</span><span class="Parenthesis" style="color:#808080">&nbsp;(</span><br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span>FieldParameterWithDynamicGroupingOfDimensions,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span>FieldParameterWithDynamicGroupingOfDimensions[ParamterOfDimensions],<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span>FieldParameterWithDynamicGroupingOfDimensions[Parameter2&nbsp;Fields]<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">)</span>,<br><span class="indent8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>FieldParameterWithDynamicGroupingOfDimensions[ParamterOfDimensions]<br><span class="indent4">&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="Parenthesis" style="color:#808080">)</span><br><span class="Keyword" style="color:#035aca">...</div><br>

(Referencing [Using SELECTEDVALUE with Fields Parameters in Power BI - SQLBI](https://www.sqlbi.com/blog/marco/2022/06/11/using-selectedvalue-with-fields-parameters-in-power-bi/))

## Summary
In summary, I would like to say that Field Parameters are a great thing that makes much work more accessible. That is, if it is not about more dynamic formatting, that should depend on the selected fields from the parameter. Then they add much work. If we were to talk about conditional formatting based on the resulting value, it is the same as with almost any conditional formatting, so it's pretty cool. The tool from which the images are taken is DAX Studio [(DAX Studio | DAX Studio)](https://daxstudio.org/).

The following Article is [Conditional on Formatting with Calculation Groups]({{site.baseurl}}/conditional-formatting-calculation-groups).