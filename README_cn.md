# booru_spider
需要包 `aria2` `kdialog`

CLI需要包 `aria2` `curl`

<br>

这是一个Booru爬取脚本。

支持图站: Konachan, Danbooru, Yande.re

可以过滤分级（排除过滤）

[CLI版本更新历史](#cli版本更新历史)

# 更新历史

* v1.3.1

 微调输出
 
 修复Danbooru tag搜索
 
* v1.3.0
 
 不再需要jq
 
* v1.2.2

 添加danbooru搜索标签

* v1.2.1

 添加内容分级功能
 
* v1.2.0

 修复booru无结果或者结果单页导致错误

* v1.1.1

 修复booru无选择导致错误
 
 修复tag无结果或单页后until死循环

* v1.1.0

 修复获取的tags_page，修复保存问题

* v1.1.0b

 添加后台运行、stderr重定向，

 修复一处函数引用，修复tags仅搜索第一page，

 支持从非终端启动（选择输出目录）

* v1.0.6

 修复kdialog错误

* v1.0.5b

使用kdialog

* v1.0.4

 初步支持Danbooru

* v1.0.3

 优化代码 & 变量名小写化

* v1.0.2

 优化代码

* v1.0.1

 修复page_max问题

* v1.0.0

 实现搜索标签

# CLI版本更新历史

* CLI-1.3.1

 微调输出
 
 修复Danbooru tag搜索
 
* CLI-1.3
 
 不再需要jq 
 
 <b>（使用 [Git for Windows](https://git-scm.com/download/win) 以及配置好 [aria2](https://github.com/aria2/aria2/releases) 就可以在windows使用脚本了）</b>
 
* CLI-1.2

 去掉一些换行
 
 添加分级过滤功能
 
 修复Danbooru tag搜索
 
 Konachan,Yande.re tag搜索支持多分页
 
 输出文件可以设定文件名

* v1.0.5b > CLI-1.1

 去掉一些换行

 合并部分sed语句

