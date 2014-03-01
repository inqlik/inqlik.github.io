--- 
layout: post
title: "Expression Editor in QlikView Deployment Framework environment"
time: '23:12'
---

We've switched to QlikView Deployment Framework recently so adjusting our current toolset to new environment was a great opportunity to rethink some approaches and implement some properties in alternative way. In this post I'd like to present some background design considerations and current state of one of these tools - Expression Editor. 

Expression Editor is a module in [QlikView Tools](https://github.com/vadimtsushko/sublime-qlikview), which is an open-source package for Sublime Text editor. Basically at the moment QlikView Tools consist of

- Language syntax plugin for qvs script files
- Integrated QVD metadata viewer
- Expression Editor

Other parts of QlikView tools may be subject of another post. Lets look and Expression Editor.

We started to use external storage for variables of our QlikView applications almost from start of our involvement with QlikView. I sincerely believe that any form of external maintenance is superior to direct editing of chart diagram expressions. So we started with external Excel files with variable expressions. It has feelings of *right thing to do in the long run* but sort of a impediment in the direct design process. And obviously while Excel files excel in some aspects - as a target format for version control systems they are not very helpful.

So we sought and tried other tools: better editors for tabular data and so on. Wishes for the future instrument were:

- Ideally it should have a text format for best interoperability with VCS
- Readability: First of all variables and expressions are program code. They contain huge part of overall logic of end-user application. By old rule any line of program code is read ten times more frequently then written or changed. 
- Decent experience while writing code: Ideally you should have same sort of help as in Expression Editor within QlikView application
- Metadata support. Any variable has a name. But variables in end-user QlikView application are mostly not simple variables. Frequently they represent an instance of a chart expression. Each of such an expression necessarily has to have at least `Label` and `Comment` for its visual representation in a chart. Some have `Background color` and so on. It would be nice to have all these related properties stored together.
- Should load to QlikView effectively


Some our previous attempts were:

- Tabular text format with support from ST plugin. Fail on readability and comfort of editing with large expressions.
- YAML format with QlikView `Load from YAML` function. That was a more less promising direction, but a writing decent text parser in QlikView script is not such an attractive task.

Our current solution to this:

- YAML like format. 
  - Good for reading. 
  - Compatibility with YAML is broken to allow less ceremony while writing the code. For example: In YAML there is special symbol for beginning of multiline string. Expression editor knows that expression definition can be multiline, so there is no need to designate multiline string explicitly
  - Very good with regard to CVS 
- On the fly generation of csv file in format of variable csv file of QlikView Deployment Framework
- Syntax highlighting for proprietary tags and for QlikView expressions in definitions parts

To get some view of this instrument, lets look how we can use Expression Editor to modify sample app from QlikView Deployment Framework. (All app used are available at download link below)

Original sample application do not use external storage of variables. All expression defined (sometimes repeatedly) inside charts.

So our **first step** would be extracting expressions from original application:
![Original sample][ns1]

Next: write down expressions in Expression Editor. I transfer Name, Definition, Label and Comment for each chart expression used in sample application. [^1] 

![Expression Editor 1][ee1]

**Next step**: Lets replace hard written values with values from external repository

![Sample with expressions][ns2]

On that step you can see some characteristics of that technique. 
- Inline expression for average order now replaced by $(AvgOrder). It seems to be an unquestionable improvement.  
- Plain text label `Avg order value` replaced by formula `=AvgOrder.Label`. Admittedly it looks not so pretty as original text. And given full row of such labels at **Expressions**, **Number** or **Axes** tabs or Properties dialog their repeated `.Label` parts somewhat irritate eyes.

  - =Sales.Label
  - =AvgOrder.Label
  - =Sales1998.Label
  - =Sales1997.Label
  
  But I would argue that it is an improvement anyway: I believe that in such overview panels with many expressions in row - most important feature is a unambiguity. Looking at row above I immediately and confidently may expect that second expression in that chart correspond to expression AvgOrder in external storage. On the other hand `Avg order value` label and all the more `1998` label in big application can correspond to several terminal expressions. [^2]

Just for sake of demonstration purpose I add `Sales.BackgroundColor` to `Sales` expression so on the whole it looks like

```

---
SET: Sales
Definition: Sum(Quantity*UnitPrice)
Label: Sales
Comment: Sales amount for selected period
BackgroundColor: =LightGreen(96)

```

Next I use this variable for Sales chart expression both on Dashboard and Sales sheets of application. Now we've got nice uniformly greenish color for Sales across two charts.

![Sample with expressions 2][ns3]

On the next step I implement somewhat contrived task for that demo: localization of UI. 
Do not blame me, it is definitely not the working solution and most part of applications will stay in English no matter what. I'll just try to demonstrate some points.

Lets save our CustomVariables file as CustomVariables_i18n and modify it:

```

---
SET: AvgOrder
Definition: Sum(Quantity*UnitPrice)/Count(DISTINCT OrderID)
Label: Avg order value
Comment: Avg order value
```
changed to 
```

---
SET: AvgOrder
Definition: Sum(Quantity*UnitPrice)/Count(DISTINCT OrderID)
Label: =If($(russianNotSelected),'Avg order value','Средний чек')
Comment: =If($(russianNotSelected),'Avg order value','Средний чек')
```

![Expression Editor 2][ee2]

Next: Lets change our LoadApp script so it would load new version of expressions and additionally load isolate table with languages: En and Ru

Now reload sample application and it will respond on language selection - labels and help string of our charts will be localized. And what is most nice - we do not change anything in the end-user application for that. 

![Sample with expressions 4][ns4]

In common programming parlance: Presentation layer was separated from domain model layer and that did provide opportunity to make changes in that layers somewhat independently. [^3] Labels and Comments work nicely when they are just string values, and continue to work without any change in when they become dynamic expressions themselves. 



[^1]:
I define Comment arbitrary when it is absent in original application. It's just a habit to have both Label and Comment for chart expression. Actually in that application Comments mostly not used in charts, but if I simply switch any box diagram into straight table for example - it would be nice to have them from the start. On the other hand simple variables not used as chart expression usually have only name (defined in LET or SET part of expression block) and definition.

[^2]:
In previous version of Expression Editor we used disconnected table for expressions metadata. So expressions labels used to look like $(GetLabel(AvgOrder)).
Current solution (with clustered group of variables for each expression: `Sales`, `Sales.Label`, `Sales.Comment`, `Sales.TextColor` for example) was inspired by QlikView Deployment Framework. QlikView Deployment Framework has option to store Comments for variable in linked variable.
That solution has already proved itself as a big improvement. First of all `=Sales.Label` looks slightly better then `$(GetLabel(Sales))`. But arguably more important part is: QlikView itself provide much more support in design time with this approach. In edit box for Label value for example, when you  start typing =Sale - you get possible completions, and immediately know if corresponding variable exists. If not - expression would be red underscored. Inside the $() you can write devil and all. No completions, and QlikView will indifferently color right thing and nonsense alike in dim gray. Such a difference matter a lot on the visualization phase. 
[^3]:
There was some cheating - I created and hid listbox for language selection beforehand.   





[Download sample used below][sd]

[ns1]: /images/north-1.png
[ee1]: /images/expression-editor-1.png
[ns2]: /images/north-2.png
[ns3]: /images/north-3.png
[ee2]: /images/expression-editor-2.png
[ns4]: /images/north-4.png

[sd]: ///