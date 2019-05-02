#!/bin/bash

# Poly000
# CLI-1.1

a()
{
echo 请输入搜索tag的关键词\(输入n跳过搜索\)
read tags
if [ ! x${tags} = xn ]
then if [ x${tags} = x ]
     then a
     else b
     fi
fi
}
b()
{
echo Konachan:
wget https://konachan.net/tag.json?name=${tags} -o /dev/null -O -|jq .|grep -i ${tags}|sed -s 's\",\\g;s\"\\g;s/name://g'|more
echo
echo Yande.re:
wget https://yande.re/tag.json?name=${tags} -o /dev/null -O -|jq .|grep -i ${tags}|sed -s 's\",\\g;s\"\\g;s/name://g'|more
echo
echo Danbooru:
wget https://danbooru.donmai.us/tags.json?name=${tags} -o /dev/null -O -|jq .|grep -i ${tags}|sed -s 's\",\\g;s\"\\g;s/name://g'|more
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
echo 请输入需要的tag（多tag请用“+”连接）
read tags
echo 需要下载？
echo o 仅第一页，即最新
echo a 所有页数
read -s -n 1 page
case $page in
[Oo])
wget https://$booru.json?tags=${tags}\&page=1 -o /dev/null -O -|
jq .|
grep \"file_url|
sed -s 's/    "file_url": "//g;s/",//g'>link-list
;;
[Aa])
path=`pwd`
tempdir=`mktemp -td dir.XXXXXXXX`
cd $tempdir
if [ $booru != danbooru.donmai.us/posts ]
then wget https://$booru\?tags\=${tags} -o /dev/null -O - |
sed -s 's/ /\n/g'|
grep href|
tail -n 12|
sed -s 's/&amp;/\n/g'|
head -n 1|
sed -s 's\href="/post?page=\\g'>page
echo 请输入要下载多少页（默认`cat page`）
read page_max
  if [ 0$page_max = 0 ]
  then page_max=`cat page`
  fi
else echo 请输入要下载多少页（最多1000）
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
sed -s 's/    "file_url": "//g;s/",//g'>$path/link-list
;;
esac
rm -rf $tempdir
