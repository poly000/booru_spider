#!/bin/bash
a()
{
echo 请输入搜索tag的关键词\(输入n跳过搜索\)
read TAGS
if [ ! x$TAGS = xn ]
then if [ x$TAGS = x ]
     then a
     else b
     fi
fi
}
b()
{
echo Konachan:
wget https://konachan.net/tag.json?name=$TAGS -o /dev/null -O -|jq .|grep -i $TAGS|sed -s 's\",\\g'|sed -s 's\"\\g'|sed -s s/name://g
echo
echo Yande.re:
wget https://yande.re/tag.json?name=$TAGS -o /dev/null -O -|jq .|grep -i $TAGS|sed -s 's\",\\g'|sed -s 's\"\\g'|sed -s s/name://g
echo
echo 需要搜索下一个tag吗？（多tag请用“+”连接）（y/*）
read -s -n 1 AGAIN
case $AGAIN in
[Yy])
a
;;
*)
:
;;
esac
}
a
echo 请选择图站（K/Y）
read -s -n 1 BOORU
case $BOORU in
[Kk])
BOORU=konachan.net
;;
[Yy])
BOORU=yande.re
;;
esac
echo 请输入需要的tag（多tag请用“+”连接）
read TAGS
echo 需要下载？
echo o 仅第一页，即最新
echo a 所有页数
read -s -n 1 PAGE
case $PAGE in
[Oo])
wget https://$BOORU/post.json?tags=$TAGS\&page=1 -o /dev/null -O -|jq .|grep file_url|sed -s 's/"file_url": "//g'|sed -s 's/",//g'|sed -s 's/    //g'|dd of=link-list
;;
[Aa])
echo 请到 https://$BOORU/post?tags=$TAGS 手动查看最大page（纯数字）
read PAGE_MAX
mkdir ___tmp___
cd ___tmp___
echo -e for PAGE in {1..$PAGE_MAX}\\ndo echo https://$BOORU/post.json?tags=$TAGS\\\&page=\$PAGE \>\> List\\ndone|bash
aria2c -j $PAGE_MAX -i List #--http-proxy= --https-proxy=
cat *json|jq .|grep file_url|sed -s 's/"file_url": "//g'|sed -s 's/",//g'|sed -s 's/    //g'>../link-list
cd ..
rm -rf ___tmp___
;;
esac
