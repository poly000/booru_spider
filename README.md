# booru_spider
需要包 `aria2`  `jq`  `kdialog`

这是一个Booru爬取脚本。<del>这是一个假项目。</del>

支持图站: Konachan, Danbooru, Yande.re,  <del>Gelbooru</del>

<br>

# 更新历史

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
