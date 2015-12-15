--- 
layout: post
title: "InQlik QVD Explorer"
time: '23:12'
redirect_to:
  - http://blog.infovizion.ru/2015/07/infovizion-qvd-explorer/
---

*TL;DR:* Check out our [QvdExplorer](https://github.com/inqlik/QvdExplorer) - simple but powerful tool to explore data in your QVD files

----

In that post I want to introduce simple tool that our team internally use quite some time. 
We use it to analyze data in intermediary and Ready-For-Mart QVD files in our projects.

Basically QVD explorer consist of two parts:

- QlikView application template with dynamic data exploration functionality. Application provides dynamic selection of dimensions, measures, filters based on data loaded in concrete application. 
- Scripts that provide `Send to \ QvdExplorer` menu item in windows explorer context menu. When user select one or several QVD files and choose `Send to \ QvdExplorer` command script create new application based on template, generate load script that load all selected QVD files into the application and reload data.

We found that application very useful in our daily work so I would like to share it with community.

###Some features:

- You can freely modify application template to adapt for your taste and needs.
- You can modify concrete application (application with data loaded from QVDS) to add specific behavior to adapt application for concrete analytic scenario. If you select same set of QVD files in windows explorer and perform `Send to \ QvdExplorer` again same QlikViedw application would be used to reload new data. You would not lose your modification so you can repeatedly analyze updated dataset.

###Caveats

- While resulting QlikView applications are well suited for some analytic tasks, they can easily guzzle all memory out of your system if you accidentally choose to show couple of million rows in straight chart. You should select right filters and/or right set of dimensions when you are dealing with very big datasets.   


###Installation

- Clone project or just download [repository archive](https://github.com/inqlik/QvdExplorer/archive/master.zip) and copy extract directory `QvdExplorer-master` from that archive anywhere in your system (you may rename that directory to `QvdExplorer` for example). Probably path to `QvdExplorer` directory should not contain non-ascii symbols and spaces. 
- Run `setup.bat` (you can do it just double clicking that batch file in the file explorer). That operation will install new target `QvdExplorer` to `Send to` context menu in file explorer.

###Usage

Select one or several QVD files in Windows Explorer then select `Send to \ QvdExplorer` item in Windows context menu. 

<img src="http://inqlik.github.io/images/send-to-qvdexplorer.png" alt="Image 1" width="700">


`Send to \ QvdExplorer` operation will trigger several events

- New qvw application with long unique name that included path to selected QVD files will be created in `Data` subdirectory under your QvdExplorer directory
- New QlikView load script for loading all selected QVD files into that application will be created alongside with that qvw application
- Qvw application will reload data
- Qvw application will be opened in QlikView Desktop

Newly opened qvd application may look like this:


<img src="http://inqlik.github.io/images/qvdexplorer-newly-opened.png" alt="Image 2" width="700">



In Dynamic filter area, you can choose a field from the list of fields available in the application and then select values to filter in the adjacent list.


Straight table with data to explore originally is hidden. To show it you should select one or more dimensions in Dimension selection area. Optionally you can add up to 5 measures to table by choosing a field from the list of available fields and aggregation function from the correspondig list.

Example of QvdExplorer application for sample dataset with some `EmployeeId`'s filtered, with selected dimensions `SupplierId` and `ProductName` and measures added to show sum of `Quantity` and number of transactions by selected dimensions

<img src="http://inqlik.github.io/images/qvdexplorer.png" alt="Image 3" width="700">


