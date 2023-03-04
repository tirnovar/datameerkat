---
layout: post # type of content
title: Documentation options in Power Query # title of the post
description: Document your code! One day you will thank yourself, or someone else will thank you, who will take over. # will be shown as a description in the post list
date: 2023-03-04 10:00:00 +0100 # date of the post
author: Štěpán # author name
image: '/images/covers/documentation-options-in-power-query.png' # required to store image in /images/covers
image_caption: '' # optional
tags: [m, power_query, documentation, comments, development] # tag names should be lowercase
featured: true # set to true to show on homepage
---
I'm sure you've heard this somewhere before. It is a reasonably clear truth that does not need more or less to be presented. But it's more complicated. Why? Because he wants to learn. There's no need to write a long-winded essay on exactly how the code works. You need to get just the necessary details. At the same time, you must get used to the fact that it needs to be done. I don't want to discuss how to describe the entire Power BI Dataset and all its parts. This could be worth a book because there are many approaches to documentation, and Power BI supports documentation of everything possible and at different levels.

What I want to discuss here is the documentation in Power Query. Again, I will not solve the exact procedures of what to describe, but instead, I want to show you what and how it can be specifically described and where it will then be promoted.

## M code comments
With its M language, Power Query is no exception to other languages, so M also supports using annotations in code. We have two basic types for this:
- Single-line comments - "// My single-line comment."
- Multi-line comments - "/* My multi-line comment */"

Power Query colors comment in the code green to make them stand out from the rest of the code.
![Comment Showcase]({{site.baseurl}}/images/posts/Documentation options in Power Query/comments.png){:loading="lazy"}
*Comment Showcase*


To be able to create these comments faster, there are even keyboard shortcuts to help us with this:
- <kbd>Ctrl</kbd> + <kbd>'</kbd>

## Documentation of steps
Ok, so we all know the comments. So let's get to the documentation and start with the most obvious by describing the steps that the Power Query editor created for you or that you wrote yourself. However, Power Query is a reasonably understandable language that uses English as its basis. If one understands the skeleton of its functions, types, and operands, this code should be read like a book. But you've probably already heard that in other languages ​​as well. It is true, but a "machine" understanding of what is happening with the data is often insufficient in itself. That's why there is an option to add your label to any step so that you can add, for example, WHY we are doing the given step or what the expected result is.

![Step Description]({{site.baseurl}}/images/posts/Documentation options in Power Query/stepDescription.png){:loading="lazy"}
*Step Description*

We can create such an icon with a description/documentation of the step using Power Query UI or code.

### UI Variant
Right-click on the step you want to describe and select "Properties...".
![Step Properties]({{site.baseurl}}/images/posts/Documentation options in Power Query/properties.png){:loading="lazy"}
*Step Properties*

The following POP-UP window will appear where you can complete the Description.
![Step Properties POP-UP]({{site.baseurl}}/images/posts/Documentation options in Power Query/propertiesPopup.png){:loading="lazy"}
*Step Properties POP-UP*

This Description is then reflected in the information icon. If we open the Advanced Editor, we can notice how this Description is reflected in the code. But let's create it ourselves.

### Code way
It may seem like a particular advantage to create this **"i"** icon, and we can reach for both single-line and multi-line comments. Unfortunately, this is not a 100% advantage because the multi-line text will be folded back to a single line during the presentation, so formatting is quite complicated.

{% include codeHeader.html %}
{% highlight pq highlight_lines="4" %}
let
    import = Excel.Workbook(URL)[Data]{0},
    promote = Table.PromoteHeaders(#"Imported Excel Workbook", [PromoteAllScalars=true]),
    // This step filters out all blank values in column Name
    filter = Table.SelectRows(promote, each ([Name] <> null))
in
    filter
{% endhighlight %}

Anyway, for the comment to become a description of the step, quite paradoxically, it must be **BEFORE** the step that we want to describe in this way. It's a rather strange concept because comments are usually placed AFTER the code is described.

## Feature documentation
Not every user ever needed to create their functions in Power Query, but if you ever had this need, you will find it helpful to know that functions can be described many times more than ordinary steps. At the same time, I highly recommend describing the functions because that way, you can avoid a lot of HOW I DID IT moments, which can bring even just a few hours, during which you no longer look at this code. Of course, the key to the initial understanding of what the given function does is already its name, but that is not everything.

By itself, the already empty preview window of its function claims that it can be expanded.

[IMAGE]

And overall, the fact that if you call any function but only as a reference to it (that is, without "()"), the following view will be returned to you.

[IMAGE]

We could review the functions and decompose the individual "Documentation" options. Or we use the more straightforward options and look in the documentation: [LINK TO DOCUMENTATION]()

It is pretty clear from it that we can document the following:
- Name
- Description
- Version
- Author
- Source
- Examples
- AllowedValues
- FieldDescription

That's quite a few documentation options. I do not prefer using all options for various reasons. For example, I don't use Allowed Values ​​because it's just a documentation option that modifies the UI of the created function and does not limit the potentially entered values ​​when calling the function in a usual code way.

[IMAGE]

At the same time, for some of these functions, a simple extension of the metadata of the last "step" of the function is sufficient:
[IMAGE]

If you would like to use some of these documentation elements yourself, we are here to prepare a simple template for creating your functions with explanations:

{% include codeHeader.html %}
{% highlight pq %}
// --------------------------- Function ------------------------------
let
    // --------------------------- Fucntion segment -----------------------------------
    output =
        (/* parameter as text, optional opt_parameter as text */) /* as text */ =>      // Input definition + Function output type definition
            let                                                                         // Inner function steps declaration
                initStep = "",
                lastStep = ""
            in
                lastStep,                                                               // Output from inner steps     
    // --------------------------- Documentation segment ------------------------------
    documentation = [
        Documentation.Name = " NAME OF FUNCTION ",                                      // Name of the function
        Documentation.Description = " DESCRIPTION ",                                    // Decription of the function
        Documentation.Source = " URL / SOURCE DESCRIPTION ",                            // Source of the function
        Documentation.Version = " VERSION ",                                            // Version of the function
        Documentation.Author = " AUTHOR ",                                              // Author of the function
        Documentation.Examples =                                                        // Examples of the functions
        {
            [
                Description = " EXAMPLE DESCRIPTION ",                                  // Description of the example
                Code = " EXAMPLE CODE ",                                                // Code of the example
                Result = " EXAMPLE RESULT "                                             // Result of the example
            ]
        }
    ]
    // --------------------------- Output --------------------------------------------
in
    Value.ReplaceType(                                                                  // Replace type of the value           
        output,                                                                         // Function caller
        Value.ReplaceMetadata(                                                          // Replace metadata of the function
            Value.Type(output),                                                         // Return output type of function               
            documentation                                                               // Documentation assigment
        )
    )
// ------------------------------------------------------------------------------------
{% endhighlight %}

Příklad toho, jak to pak může vypadat:
[IMAGE]

Kdykoliv tedy dojde k zavolání odkazu funkce, tak se navrátí včetně této dokumentace.

## Dokumentace dotazů
?? LZE

## Dokumentace parameterů
?? STEJNĚ JAKO FUNKCE?
?? ZAPROPAGUJE SE TO?