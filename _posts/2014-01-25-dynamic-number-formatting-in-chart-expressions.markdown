--- 
layout: post
title: "Dynamic number formatting in chart expressions. Pros and cons"
time: '23:12'
---

First of all - a definition. QlikView charts properties dialog has a `Number` tab where we are setting formats for each expression manually. That I will name static number formatting in this post.

Whole bunch of various controls together are helping user to set proper value to property `Format Pattern`. Importantly - `Format Pattern` can not be set by variable expression. So you can set `Background Color` or `Text Format` of chart expression by variable expression but not `Format Pattern`.

It's rather not obvious why that should be so, and apparently not only for me - because I found such [Idea][idea] 

> ####Allow "Format Pattern" to use an expression
>In many places you can use expressions to dynamically control QlikView. This should also be one of them.Especially when it comes to enterprise deployments with employees in multiple countries/cultures collaborating in one QV application a dynamic display is needed.Please email me for a detailed problem description / documentation if needed.

Which got answer from QlikTech engineer: 

> > Works as designed. The idea is good. The reality is from we do not want to permit expressions to be evaluated at such a low level.

Well, it still looks as a rather cryptic answer for me, but this issue is four year old and nothing tells something would move on it in foreseeable future.

So another approach would be to format expressions in-place. For example you have expression for Sales

    Sum(Sales)

On `Number` tab your `Number Format Settings` set to default value - `Expression default`. You pre-formate your expression with (for example) 

    Money(Sum(Sales),'$# ##0,00;-$# ##0,00')

That is what I will call dynamic formatting in chart expression. At first glance such technic is even better than using separate expression variable with `Format Pattern`. After all we do not have to manage additional variable. That approach can easily handle even more dynamic scenarios. For example, if we have to change format accordingly to selection made in field `Country`, we could add variable `vMoneyFormat` which dependent from that selection and change our expression for `Sales` to

    Money(Sum(Sales),$(vMoneyFormat))

We started to use dynamic formatting recently and for us it is real improvement.
But there is time for cons in that story.

Our new Num() formatted expressions looked and acted in application as equals to old statically formatted ones. But in one respect they were unequal. `Send to Excel` function respected static formatting but totally disregarded dynamic formatting.

Cell value 12.34% became 0.123398723123. Not good.

We did our Google search on that problem and results where not so optimistic. Apparently behavior of dynamically formatted expressions on `Send to Excel` changes constantly. In the midst of year 2012 in QV11 expressions formatted by Num() function were [converted to Text][num_text] by the way to Excel, There was [some way][salesforce] to keep it in numbers, but otherwise unformatted. Now in QV11 SR4/5 that is default behavior out of the box - in Excel values arrive as unformatted numbers. 

Almost by accident we've found that formatting by Money() function is respected by `Send to Excel` as opposed to Num(). We did not use Money() much before as our usual set of number formats are Integer, Fixed to two decimals and Percent. Percent format pattern particularly did not look as good candidate to use in Money function but unexpectedly it worked. So strange expression formatter like

    Money($(vCurrentMonthSales)/$(vPreviousMonthSales),'# ##0,00%')

works good both in application and after `Send to Excel`. Checked on QV11 SR4 and SR5.

Look at example chart with some expression

![Dynamic formatting in QlikView][example_qv]

and how it looks in Excel

![Sent to Excel][example_excel]

So for now we search/replaced all Num() to Money() in our variables files. Kind of happy end.
But is it right to do such tricks?

So, our pros:

- It's very effective on design time. You will never ever switch to that `Number` tab on expression properties dialog.
- Your expression formats reside where they belongs. Alongside with your expressions, out of your user application, under your CVS umbrella in whatever format you keep your variables.
- You are not hampered in all sort of dynamic scenarios. Consider you have a dynamic chart expression, which shows either `Sales` or `Margin percent` or `Margin value` based on user selection. It's easier to have one chart expression with changing `Definition`, `Label` and `Comment` then three chart expressions that conditionally hide or show. But it works only if all relevant properties of chart expression set by variables.
- That's just feel as move in right direction, architecturally

And cons:

- We are relaying on undocumented feature, which looks almost like bug. Why on earth Num() formatting should be skipped, while Money() formatting should be respected in same procedure? What if QlikTech engineers will somehow fix Money() behavior so it would work only with format pattern that contain some currency symbol, or outright ban percent symbol in Money format pattern?
- As yet we've found just one case of different behavior of static and dynamic formatting. No one can give a guarantee that there are no more such cases.

Anyway, for now we decided to stick to dynamic formatting. If bug-like feature helps us deliver better applications, so be it.

Download [application used as example][app]

[idea]: http://community.qlikview.com/ideas/1364
[num_text]: http://community.qlikview.com/thread/53189
[salesforce]: https://eu1.salesforce.com/articles/Basic/How-to-export-data-to-excel-as-number-in-version-11
[example_qv]: /images/dynamic_formatting_qv.png
[example_excel]: /images/dynamic_formatting_excel.png
[app]: /downloads/send_to_excel_sample.qvw