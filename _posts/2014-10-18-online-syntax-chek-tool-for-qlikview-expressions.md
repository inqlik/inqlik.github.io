--- 
layout: post
title: "Online tool to check syntax of QlikView expressions"
time: '23:12'
---

TL;DR: Check our [on-line parser for QlikView expressions](/live/build/web/parser.html)

----

Currently in spare time I'm trying to add command line syntax check tool for qlikview chart expressions to ours team tool-box. We already use internally similar command line parser for qlikview load scripts. It definitely should be improved in future but already now (integrated in Sublime Text as Build system for qvs script) it provide some help in developing process. It is developed in dart programming language with sources available at [github repository](https://github.com/inqlik/qvs) for all interested in that kind of stuff. For the moment it completely lacks of documentation apart from set of unit-test and generally I think is ready only for our own internal usage.

So I thought - why not make comparable tool for checking our qlikview expression files? (in our projects all qlikview expressions are stored in text files, same as load scripts).
Admittedly such a tool would require addition of sub-parser for Set analysis expressions but that should not be overwhelming task giving now I have some experience with other parsers (Actually that step is done now) 

Well, it proved to be difficult to get from working parser for individual qlikview expression to useful tool for analyzing real code-base of expressions. You should decide what to do with all sorts of dollar sign expansions within expressions for example. Or how to deal with variables that are not valid expressions and rather some arbitrary chunks of code only used through variable expansion in other expressions. And some automatic procedure for getting metadata from end-user application would be nice too. Tool may then check each terminal identifier in expression against list of loaded fields in application. And so on. 

So for now that tool is not ready even for internal usage, but I believe it eventually would develop into something useful.

Meantime I've decided to take advantage of dual nature of dart language which works both in command line scripts and (compiled to javascript) at web pages. I can take a expression parser from the package and use it in simple web application. 

Go [here](/live/build/web/parser.html) to see how it works.

Some additional considerations:

- That page works totally on the client side, parser and so on compiled to javascript.
- Page uses the excellent [QlikView Web Syntax Highlighter](http://www.qlikviewaddict.com/p/qlikview-web-highlight.html) to highlight expression syntax. (Actually it similar to how actual tool would be used at development. Sublime Text will provide syntax highlighting and qlikview expression parser would be used for syntax checking)
- Expressions can contain set analysis expression.
- Dollar sign expansions are not supported.
- Apart from dollar sign expansion on-line syntax checker should not give false negative results for expressions of any complexity. If you entered valid expression and checker report error in it, please [add an issue](https://github.com/inqlik/qv_exp/issues) at repository or leave a comment here.
- QlikView expression parser itself is at [its own repository](https://github.com/inqlik/qv_exp)
- Source code for web application is at [inqlik blog repository](https://github.com/inqlik/inqlik.github.io/tree/master/live/web) 
- Application itself is basically minimally adapted dart web hello world sample