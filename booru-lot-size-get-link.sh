#!/bin/bash
# v1.3.2
# Poly000
# 可以爬取booru图链接为链接列表。
http_proxy=
https_proxy=
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
	path="`kdialog --getsavefilename $HOME "*.txt" 2>/dev/null`"
	if [ x"${path}" = x ]
	then save_file
	fi
}
function search_tags(){
	if tags=`kdialog --inputbox 请输入搜索tag的关键词 2>/dev/null`
	then if [ x = x"${tags}" ]
	     then search_tags
	     fi
	fi
	if [ x != x"${tags}" ]
	then
		kdialog --msgbox 开始搜索... 2>/dev/null &
		temp1=`mktemp -t temp.XXXXXXXX`
		exec 3> $temp1
		echo Konachan: >&3
		wget https://konachan.net/tag?name="${tags}" -o /dev/null -O -|grep next_page|sed -s 's/&amp;type=">/\n/g ; s/</\n/g ; s/">/\n/g'|sed -n 29p>tags
		max_tags=`cat tags`
		if [ x$max_tags != x ]
		then	page_tags=0
			rm tags
			until [ $page_tags = $max_tags ]
			do	page_tags=$((page_tags+1))
				echo https://konachan.net/tag.json?name="${tags}"\&page\=$page_tags >> tags
			done
			aria2c -i tags #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy # -j：指定最高同时下载文件数量 （1～n，默认5）
			cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
			rm tag*
		else	wget https://konachan.net/tag.json?name="${tags}" -o /dev/null -O -|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
			rm tag*
		fi
		echo >&3
		echo Yande.re: >&3
		wget https://yande.re/tag?name="${tags}" -o /dev/null -O -|grep next_page|sed -s 's/&amp;type=">/\n/g ; s/</\n/g ; s/">/\n/g'|sed -n 29p>tags
		max_tags=`cat tags`
		if [ x$max_tags != x ]
		then	page_tags=0
			rm tags
			until [ $page_tags = $max_tags ]
			do	page_tags=$((page_tags+1))
				echo https://yande.re/tag.json?name="${tags}"\&page\=$page_tags >> tags
			done
			aria2c -i tags #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy # -j：指定最高同时下载文件数量 （1～n，默认5）
			cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
			rm tag*
		else	wget https://yande.re/tag.json?name="${tags}" -o /dev/null -O -|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
			rm tag*
		fi
		echo >&3
		echo Danbooru: >&3
		wget 'https://danbooru.donmai.us/tags.json?commit=Search&search[hide_empty]=yes&search[name_matches]=*'"${tags}"'*&search[order]=date&utf8=%E2%9C%93' -o /dev/null -O -|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
		rm tag*
		kdialog --textbox $temp1 450 675 2>/dev/null &
		if kdialog --yesno 需要搜索下一个tag吗？ 2>/dev/null
		then	tags=
			search_tags
		fi
	fi
}
search_tags
set_booru
tags=`kdialog --inputbox 请输入需要的tag（多tag请用“+”连接，排除tag请用“+-”连接） 2>/dev/null`
if [ $booru != danbooru.donmai.us/posts ]
then 	wget https://$booru\?tags\="${tags}"\&limit\=1000 -o /dev/null -O - |sed -n 23p|sed 's/page=/\n/g;s/&amp;/\n/g'|sed -n 3p>page
	if ! [ 0 -lt `cat page` ]
	then	 page_max=1
	else	 page_max=`cat page`
	fi
else 	page_max=`kdialog --inputbox 请输入要下载多少页（理论最多1000page） 2>/dev/null`
fi
page=0
while [ $page -lt $page_max ]
do 	page=$((page+1))
	echo https://$booru.json?tags="${tags}"\&page=$page\&limit\=1000 >> List
done
temp2=`mktemp -t temp.XXXXXXXX`
kdialog --msgbox 开始获取... 2>/dev/null &
aria2c -i List #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy # -j：指定最高同时下载文件数量 （1～n，默认5）
cat ${booru#*/}*|sed 's/{/\n{/g ; s/}]/}\n]/g'|
# grep -v 'rating":"q' | #排除露点分级图
# grep -v 'rating":"e' | #排除色情分级图
# grep -v 'rating":"s' | #排除安全分级图
sed 's/,/\n/g'|grep \"file_url|sed 's/"file_url":"//g;s/"//g'>$temp2
save_file
cp $temp2 "${path}"
rm -rf $temp0 $temp1 $temp2
