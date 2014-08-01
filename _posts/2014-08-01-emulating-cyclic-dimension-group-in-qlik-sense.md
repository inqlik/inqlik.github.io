--- 
layout: post
title: "Emulating cyclic dimension group in Qlik Sense"
time: '23:12'
---

Current version of Qlik Sense Desktop do not support cyclic dimension groups (drilldown groups are supported).  
In this post I illustrate how to emulate this functionality. This method does not employ extensions objects and so on. Basically it uses additionally loaded field in island table and macro expansion in chart dimension. Sample applicaiton is available.

 Result looks like that:

![Sales by cities](/images/qlik_sense_cyclic_group_1.png)

and like that (another dimension selected):

![Sales by branches](/images/qlik_sense_cyclic_group_2.png)

 
That solution has some glitches in current version but I think it can be useful if you wish to reduce amount of almost identical sheets in your Qlik Sense application.

Couple of sore points:

- Lack of `Always Only One Selected Value` setting in current version of Qlik Sense make selection of `Current active dimension` not immediately obvious to user. In QlikView I would set `Always Only One Selected Value` and use function `Only()` in relevant expressions. In Qlik Sense I had to use `MinString()` for that.  
- Currently Qlik Sense do not permit using of expression in dimension's or measure's label.
In QlikView if I use dynamically changed dimension I would use dynamic label for it. This problem is somewhat alleviated by fact that title of any object can use expression. So in my example I made dynamic caption for table. But:
- Title of table did not made its way to Excel when I tried `Export to Excel`. Actually in QlikView `Send to Excel` do not export chart's caption either. I'm usually do not use caption in QlikView charts but there we always can add dynamic context information into dimension/measure label


[Download sample application](/downloads/CyclicGroupsEmulation.qvf) - you should place it at the directory `c:\Users\[User name]\Documents\Qlik\Sense\Apps` to check it up.