--- 
layout: post
title: "Sample of QlikView automation by external VBScript scripts
"
time: '23:12'
---

You can do all sorts of administrative tasks with QlikView applications through Automation API.
Export charts to excel or csv files, export variables from application, set sheet level security parameters before deploying application or warm your application on server by automatically opening some sheets and selecting some most popular values in listboxes.

In most cases I would code such a task not as a macro inside QlikView application but as an separate external VBSCript file. Benefits of that approach:

- No need for elevated security settings for QlikView application
- Scripts are immediately ready for scheduling by Windows scheduler or other scheduling application. No need to run macro on onOpen trigger for that (and dispatch on command line parameters as described in comments to [this post](http://qlikviewmaven.blogspot.ru/2008/08/qlikview-command-line-and-automation.html)
- Strangely enough QlikView do not give any sensible information when macro fail. VBscript error messages are not always clear, but even in the worst case script give you line/column position of offending command - that is big help comparing to zero output from QlikView  
- You can use [any good text editor](http://www.sublimetext.com/3) with syntax highlighting to edit the scripts (arguably QlikView macro editor has it too so on that point it is a tie I believe)
- Your scripts are immediately ready for your favorite version control system.

Several tips for using external VBScript scripts:

####Macro to VBScript conversion

Most examples of QlikView automation on the net and all examples in APIGuide are for usage in macros. There is two simple steps for converting such samples into working VBscript:
In QlikView macros global variable `ActiveDocument` is entry point to automation API, QlikView application object accessible as `ActiveDocument.GetApplication`

In VBScript we initialize two automation objects for qlikview app and qlikview document.

~~~Visual Basic

Set MyApp = CreateObject("QlikTech.QlikView")
Set MyDoc = MyApp.OpenDoc ("C:\QlikViewApps\Demo.qvw","","")

~~~

Note that you should use absolute path to QlikView document on `OpenDoc` parameter. That is mandatory.

Then use `MyDoc` instead of global variable `ActiveDocument` and `MyApp` instead of `ActiveDocument.GetApplication`

