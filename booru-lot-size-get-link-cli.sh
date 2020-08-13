#!/bin/bash

# Poly000
# CLI-1.3.5
# 可以爬取booru图链接为链接列表。
http_proxy=
https_proxy=
# 注： 主机:端口 或 http://用户:口令@主机:端口
# 请把 curl 替换为 curl -x $http_proxy
path=`pwd`
tempdir=`mktemp -td dir.XXXXXXXX`
cd $tempdir
a()
{
echo 请输入搜索tag的关键词\(输入n跳过搜索\)
read tags
if [ ! x"${tags}" = xn ]
then if [ x"${tags}" = x ]
     then a
	 else a=1
     fi
fi
if [ $a = 1 ] 2> /dev/null
then
echo Konachan:
curl https://konachan.net/tag?name="${tags}" 2>/dev/null|grep next_page|sed -s 's/&amp;type=">/\n/g ; s/</\n/g ; s/">/\n/g'|sed -n 29p>tags
max_tags=`cat tags`
if [ x$max_tags != x ]
then	page_tags=0
	rm tags
	until [ $page_tags = $max_tags ]
	do	page_tags=$((page_tags+1))
		echo https://konachan.net/tag.json?name="${tags}"\&page\=$page_tags >> tags
	done
	aria2c -i tags #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy # -j：指定最高同时下载文件数量 （1～n，默认5）
	cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
else	curl https://konachan.net/tag.json?name="${tags}" 2>/dev/null|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
fi
echo
echo Yande.re:
curl https://yande.re/tag?name="${tags}" 2>/dev/null|grep next_page|sed -s 's/&amp;type=">/\n/g ; s/</\n/g ; s/">/\n/g'|sed -n 29p>tags
max_tags=`cat tags`
if [ x$max_tags != x ]
	then	page_tags=0
			rm tags
	until [ $page_tags = $max_tags ]
	do	page_tags=$((page_tags+1))
		echo https://yande.re/tag.json?name="${tags}"\&page\=$page_tags >> tags
	done
	aria2c -i tags #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy # -j：指定最高同时下载文件数量 （1～n，默认5）
	cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
else	curl https://yande.re/tag.json?name="${tags}" 2>/dev/null|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
fi
echo
echo Danbooru:
curl 'https://danbooru.donmai.us/tags.json?commit=Search&search\[hide_empty\]=yes&search\[name_matches\]=*'"${tags}"'*&search\[order\]=date&utf8=%E2%9C%93' 2>/dev/null|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
echo 需要搜索下一个tag吗？（多tag请用“+”连接）（y/*）
read -s -n 1 again
case $again in
[Yy])
a
;;
*)
:
;;
esac
fi
}
a
echo 请选择图站（D/K/Y）
read -s -n 1 booru
case $booru in
[Dd])
booru=danbooru.donmai.us/posts
;;
[Kk])
booru=konachan.net/post
;;
[Yy])
booru=yande.re/post
;;
esac
echo 请输入需要的tag（多tag请用“+”连接，排除tag请用“+-”连接）
read tags
echo 请输入欲保存的文件名
while [ x$outfile = x ]
do read outfile
done
if [ $booru != danbooru.donmai.us/posts ]
then curl https://$booru\?tags\="${tags}"\&limit\=1000 2>/dev/null|grep pagination|sed 's/<a class="next_page"/\n/g ; s\</a>\\g ; s/">/\n/g'|tail -n 3|sed -n 1p>page
     if ! [ 0 -lt `cat page` ]
     then	 page_max=1
     else	 page_max=`cat page`
     fi
else echo 请输入要下载多少页（理论最多1000page）
	read page_max
fi
page=0
while [ $page -lt $page_max ]
do page=$((page+1))
	echo https://$booru.json?tags="${tags}"\&page=$page\&limit\=1000 >> List
done
aria2c -i List #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy # -j：指定最高同时下载文件数量 （1～n，默认5）
sed 's/{/\n{/g ; s/}]/}\n]/g' ${booru#*/}*|
# grep -v 'rating":"q' | #排除露点分级图
# grep -v 'rating":"e' | #排除色情分级图
# grep -v 'rating":"s' | #排除安全分级图
sed 's/,/\n/g'|grep \"file_url|sed 's/"file_url":"//g;s/"//g'>"$path"/"$outfile"
rm -rf $tempdir
