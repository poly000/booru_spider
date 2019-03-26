#!/bin/bash
a(){
if tags=`kdialog --inputbox 请输入搜索tag的关键词 2>/dev/null`
then if [ x = x$tags ]
     then a
     fi
fi
}
a
if [ x != x$tags ]
then
	kdialog --msgbox 开始搜索... 2>/dev/null
	temp=`mktemp -t temp.XXXXXXXX`
	echo Konachan: > $temp
	wget https://konachan.net/tag.json?name=${tags} -o /dev/null -O -|
	jq .|
	grep -i ${tags}|
	sed -s 's\",\\g'|
	sed -s 's\"\\g'|
	sed -s s/name://g>> $temp
	echo Yande.re:>> $temp
	wget https://yande.re/tag.json?name=${tags} -o /dev/null -O -|
	jq .|grep -i ${tags}|
	sed -s 's\",\\g'|
	sed -s 's\"\\g'|
	sed -s s/name://g>> $temp
	echo Danbooru:>> $temp
	echo -e \\t暂不支持搜索>> $temp
	kdialog --textbox $temp 450 675 2>/dev/null
	if kdialog --yesno 需要搜索下一个tag吗？ 2>/dev/null
	then	a
	fi
fi
booru=`kdialog --menu 请选择图站 1 Danbooru 2 Konachan 3 Yande.re 2>/dev/null`
case $booru in
1)
booru=danbooru.donmai.us/posts
;;
2)
booru=konachan.net/post
;;
3)
booru=yande.re/post
;;
esac
tags=`kdialog --inputbox 请输入需要的tag（多tag请用“+”连接） 2>/dev/null`
path=`pwd`
cd `mktemp -td dir.XXXXXXXX`
if [ $booru != danbooru.donmai.us/posts ]
then wget https://$booru\?tags\=${tags} -o /dev/null -O - |
sed -s 's/ /\n/g'|
grep href|
tail -n 12|
sed -s 's/&amp;/\n/g'|
head -n 1|
sed -s 's\href="/post?page=\\g'>page
page_max=`kdialog --inputbox 请输入要下载多少页（默认为最大值）`
if [ 0$page_max = 0 ]
then page_max=`cat page`
fi
else echo page_max=`kdialog --inputbox 请输入要下载多少页（至多未知，也许120）`
fi
page=0
while [ $page -lt $page_max ]
do page=$((page+1))
	echo https://$booru.json?tags=${tags}\&page=$page >> List
done
aria2c -i List #-j num #--http-proxy= --https-proxy= # -j：指定最高同时下载文件数量 （1～n，默认5）
cat ${booru#*/}*|
jq .|
grep \"file_url|
sed -s 's/    "file_url": "//g'|
sed -s 's/",//g'>$path/link-list
