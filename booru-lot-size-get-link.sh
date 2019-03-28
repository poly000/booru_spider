#!/bin/bash

# v1.2.0

# Poly000
# 可以爬取booru图链接为链接列表。

temp0=`mktemp -td dir.XXXXXXXX`
cd $temp0

function set_booru(){
	booru=`kdialog --menu 请选择图站 1 Danbooru 2 Konachan 3 Yande.re 2>/dev/null`
	if [ x$booru != x ]
	then	case $booru in
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
	else set_booru
	fi
}

function save_file(){
	path=`kdialog --getsavefilename $HOME "*.txt" 2>/dev/null`
	if [ x$path = x ]
	then save_file
	fi
}

function search_tags(){
	if tags=`kdialog --inputbox 请输入搜索tag的关键词 2>/dev/null`
	then if [ x = x$tags ]
	     then search_tags
	     fi
	fi
	if [ x != x$tags ]
	then
		kdialog --msgbox 开始搜索... 2>/dev/null &
		temp1=`mktemp -t temp.XXXXXXXX`
		echo Konachan: > $temp1
		wget https://konachan.net/tag?name=${tags} -o /dev/null -O -|
		grep next_page|
		sed -s 's/&amp;type=">/\n/g'|
		sed -s 's/</\n/g'|
		sed -s 's/">/\n/g'|    
		sed -n 29p>tags
		max_tags=`cat tags`
		if [ x$max_tags != x ]
		then	page_tags=0
			rm tags
			until [ $page_tags = $max_tags ]
			do	page_tags=$((page_tags+1))
				echo https://konachan.net/tag.json?name=${tags}\&page\=$page_tags >> tags
			done
			aria2c -i tags # -j num --http-proxy= --https-proxy= # -j：指定最高同时下载文件数量 （1～n，默认5）
			cat tag.*|
			jq .|
			grep name|
			grep -i ${tags}|
			sed -s 's\",\\g'|
			sed -s 's\"\\g'|
			sed -s s/name://g>> $temp1
			rm tag*
		else	wget https://konachan.net/tag.json?name=${tags} -o /dev/null -O -|
			jq .|
			grep name|
			sed -s 's\",\\g'|
			sed -s 's\"\\g'|
			sed -s s/name://g>> $temp1
			rm tag*
		fi
		echo Yande.re:>> $temp1
		wget https://yande.re/tag?name=${tags} -o /dev/null -O -|
		grep next_page|
		sed -s 's/&amp;type=">/\n/g'|
		sed -s 's/</\n/g'|
		sed -s 's/">/\n/g'|    
		sed -n 29p>tags
		max_tags=`cat tags`
		if [ x$max_tags != x ]
		then	page_tags=0
			rm tags
			until [ $page_tags = $max_tags ]
			do	page_tags=$((page_tags+1))
				echo https://yande.re/tag.json?name=${tags}\&page\=$page_tags >> tags
			done
			aria2c -i tags # -j num --http-proxy= --https-proxy= # -j：指定最高同时下载文件数量 （1～n，默认5）
			cat tag.*|
			jq .|
			grep name|
			sed -s 's\",\\g'|
			sed -s 's\"\\g'|
			sed -s s/name://g>> $temp1
			rm tag*
		else	wget https://yande.re/tag.json?name=${tags} -o /dev/null -O -|
			jq .|
			grep name|
			grep -i ${tags}|
			sed -s 's\",\\g'|
			sed -s 's\"\\g'|
			sed -s s/name://g>> $temp1
			rm tag*
		fi
		echo Danbooru:>> $temp1
		echo -e \\t暂不支持搜索>> $temp1
		kdialog --textbox $temp1 450 675 2>/dev/null &
		if kdialog --yesno 需要搜索下一个tag吗？ 2>/dev/null
		then	tags=
			search_tags
		fi
	fi
}

search_tags
set_booru
tags=`kdialog --inputbox 请输入需要的tag（多tag请用“+”连接） 2>/dev/null`
if [ $booru != danbooru.donmai.us/posts ]
then 	wget https://$booru\?tags\=${tags} -o /dev/null -O - |
	sed -s 's/ /\n/g'|
	grep href|
	tail -n 12|
	sed -s 's/&amp;/\n/g'|
	head -n 1|
	sed -s 's\href="/post?page=\\g'>page
	page_max=`kdialog --inputbox 请输入要下载多少页（默认为最大值） 2>/dev/null`
	if ! [ 0 -lt `cat page` ]
	then	 page_max=1
	elif [ 0$page_max = 0 ]
	then	 page_max=`cat page`
	fi
else 	echo page_max=`kdialog --inputbox 请输入要下载多少页（至多未知，也许120） 2>/dev/null`
fi
page=0
while [ $page -lt $page_max ]
do 	page=$((page+1))
	echo https://$booru.json?tags=${tags}\&page=$page >> List
done
temp2=`mktemp -t temp.XXXXXXXX`
kdialog --msgbox 开始获取... 2>/dev/null &
aria2c -i List #-j num #--http-proxy= --https-proxy= # -j：指定最高同时下载文件数量 （1～n，默认5）
cat ${booru#*/}*|
jq .|
grep \"file_url|
sed -s 's/    "file_url": "//g'|
sed -s 's/",//g'>$temp2
save_file
cp $temp2 $path
rm -rf $temp0 $temp1 $temp2
