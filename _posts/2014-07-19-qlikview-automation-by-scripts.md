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

<pre><code class="vbscript">
Set MyApp = CreateObject("QlikTech.QlikView")
Set MyDoc = MyApp.OpenDoc ("C:\QlikViewApps\Demo.qvw")
</code></pre>

Note that you should use absolute path to QlikView document on `OpenDoc` parameter. That is mandatory.

Then use `MyDoc` instead of global variable `ActiveDocument` and `MyApp` instead of `ActiveDocument.GetApplication`

####Automating application on QlikView server

For example that could be usefull to schedule warming up of your application after nightly reload.
To automate application residing on the QlikView server you shoud use full path to your application on OpenDoc parameter. It could be something like:

<pre><code class="vbscript">
Set MyDoc = MyApp.OpenDoc ("qvp://localhost/AppFolder/My application.qvw")
</code></pre>

For me it works only with ActiveDirectory authentication. Basically if you can open application in QlikView Desktop with `Use NT Identity` radiobutton selected and user/login dialog do not appear on opening - automation from VBScript should work too.

####Code reuse

It could be useful to collect common utility functions and classes (yes, VBScript have a classes too!!!) in a some library and use it throughout many scripts. Unfortunately VBScrip lacks standard `import` directive.

[WSF file format](http://msdn.microsoft.com/library/15x4407c(v=VS.84).aspx) add it and much more. I've tried it but it feels like an unnecessary complicated stuff.

So if import-like functionality is truly necessary I would use simple one-line function `includeFile` like in this example where on top of our script we import code from `QvUtils.vbs`


<pre><code class="vbscript">
Sub includeFile(ByVal fSpec)
    executeGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub

includeFile "QvUtils.vbs"
...
</code></pre>

Below some simple samples for illustration:

Given simple test application:
![Sample test application](/images/automation_sample.png)


Script to export straight chart to excel file with different values selected in field `Year` 



<pre><code class="vbscript">

set fso = CreateObject("Scripting.FileSystemObject")
dim CurrentDirectory
CurrentDirectory = fso.GetParentFolderName(Wscript.ScriptFullName)
set qv = CreateObject("QlikTech.QlikView")
dim qvDocName
qvDocName = fso.BuildPath(CurrentDirectory, "..\App\AutomationTest.qvw")
set doc = qv.OpenDoc(qvDocName)
set chart = doc.GetSheetObject("CH01")
doc.Fields("Year").Clear
set yearValues=doc.Fields("Year").GetPossibleValues
dim curVal
for i=0 to yearValues.Count-1
  curVal = yearValues.Item(i).Text
  doc.Fields("Year").Select curVal
  chart.ExportBiff(fso.BuildPath(CurrentDirectory,"..\Output\Report_" & curVal & ".xls"))
next
doc.CloseDoc
qv.Quit
</code></pre>

Same script separated to utils mini-library and script proper:

QvUtils.vbs:

<pre><code class="vbscript">

function GetAbsolutePath(ByVal filePath)
  if Mid(filePath,2,1) = ":" OR Left(filePath,2) = "\\" then 'Absolute path in input parameter'
    GetAbsolutePath = filePath
  else
    dim fso: set fso = CreateObject("Scripting.FileSystemObject")
    GetAbsolutePath = fso.BuildPath(fso.GetParentFolderName(Wscript.ScriptFullName), filePath)
  end if
end function

Class QlikView
  Private m_App
  Private m_Doc
  Private m_docName
  Private Sub Class_Initialize
    m_docName = ""
  End Sub

  Public Property Get app
    set app = m_App
  End Property

  Public Property Get doc
    set doc = m_Doc
  End Property

  Public Property Get docName
    docName = m_docName
  End Property

  public function setDocument(ByVal docName)
    m_docName = GetAbsolutePath(docName)
  end function

  Public Function open(ByVal docName)
    setDocument(docName)
    set m_App  = CreateObject("QlikTech.QlikView")
    set m_Doc = app.OpenDoc(m_docName)
  End Function

  Public function Quit
    m_App.Quit
    Release
  End function

  Public function Release
    set m_shell = Nothing
    set m_Doc = Nothing
    set mApp = Nothing
  end function
End Class
</code></pre>

GenerateReports.vbs:

<pre><code class="vbscript">

Sub includeFile(ByVal fSpec)
    executeGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub

includeFile "QvUtils.vbs"

with New QlikView
  .open("..\App\AutomationTest.qvw")
  set chart = .doc.GetSheetObject("CH01")
  .doc.Fields("Year").Clear
  set yearValues = .doc.Fields("Year").GetPossibleValues()
  dim curVal
  for i=0 to yearValues.Count - 1
    curVal = yearValues.Item(i).Text
    .doc.Fields("Year").Select curVal
    chart.ExportBiff(GetAbsolutePath("..\Output\Report_" & curVal & ".xls"))
  next
  .doc.CloseDoc
  .Quit
end with
</code></pre>

Script to disable most settings in Sheet Security dialog (can be run upon qvw before deployment)
Target configuration is like this:

![Sample test application](/images/sheet_properties.png)

Script uses QvUtils.vbs
Use as in `cscript set_sheet_properties.vbs ..\App\AutomationTest.qvw`

set_sheet_permissions.vbs

~~~vbscript

Sub includeFile(ByVal fSpec)
    executeGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub

includeFile "QvUtils.vbs"

if WScript.Arguments.Count <> 1 then
    WScript.Echo "Syntax is: cscript SetSheetPermissions.vbs <QlikViewFileName>"
    WScript.Quit 1
end if

with New QlikView
  .open(WScript.Arguments(0))
  for i = 0 to .doc.NoOfSheets - 1
    set sheet = .doc.GetSheet(i)
    set sp=sheet.GetProperties
    sp.UserPermissions.CopyCloneSheetObject = false
    sp.UserPermissions.AccessSheetProperties = false
    sp.UserPermissions.AddSheetObject = false
    sp.UserPermissions.MoveSizeSheetObject = false
    sp.UserPermissions.RemoveSheet = false
    sp.UserPermissions.RemoveSheetObject = false
    sheet.SetProperties sp
  next
  .doc.Save
  .Quit
end with
~~~

[Download sample project](/downloads/QlikViewAutomationSample.zip)