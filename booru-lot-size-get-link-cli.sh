#!/bin/bash

# Poly000
# CLI-1.3.2
# able to get booru pics link as a link list text file.
http_proxy=
https_proxy=
path=`pwd`
tempdir=`mktemp -td dir.XXXXXXXX`
cd $tempdir
a()
{
echo Please type the keyword to search tags\(type n to skip\)
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
curl https://konachan.net/tag?name=${tags} 2>/dev/null|grep next_page|sed -s 's/&amp;type=">/\n/g ; s/</\n/g ; s/">/\n/g'|sed -n 29p>tags
max_tags=`cat tags`
if [ x$max_tags != x ]
then	page_tags=0
	rm tags
	until [ $page_tags = $max_tags ]
	do	page_tags=$((page_tags+1))
		echo https://konachan.net/tag.json?name=${tags}\&page\=$page_tags >> tags
	done
	aria2c -i tags # -j num --http-proxy=$http_proxy --https-proxy=$https_proxy # -j：Set maximum number of parallel downloads for  (1～n，default 5)
	cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
else	curl https://konachan.net/tag.json?name=${tags} 2>/dev/null|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
fi
echo
echo Yande.re:
curl https://yande.re/tag?name=${tags} 2>/dev/null|grep next_page|sed -s 's/&amp;type=">/\n/g ; s/</\n/g ; s/">/\n/g'|sed -n 29p>tags
max_tags=`cat tags`
if [ x$max_tags != x ]
	then	page_tags=0
			rm tags
	until [ $page_tags = $max_tags ]
	do	page_tags=$((page_tags+1))
		echo https://yande.re/tag.json?name=${tags}\&page\=$page_tags >> tags
	done
	aria2c -i tags # -j num --http-proxy=$http_proxy --https-proxy=$https_proxy # -j：Set maximum number of parallel downloads for  (1～n，default 5)
	cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
else	curl https://yande.re/tag.json?name=${tags} 2>/dev/null|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
fi
echo
echo Danbooru:
curl 'https://danbooru.donmai.us/tags.json?commit=Search&search\[hide_empty\]=yes&search\[name_matches\]=*'${tags}'*&search\[order\]=date&utf8=%E2%9C%93' 2>/dev/null|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
echo do you wish search next tag? \(y/*\)
read -s -n 1 again
case $again in
[Yy])
a
;;
esac
}
a
echo -e Please select a booru\\nd: Danbooru\\nk: Konachan\\ny: Yande.re
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
echo Please type the tags you need \(use + connect tags\)
read tags
echo what filename you wish to save?
while [ x$outfile = x ]
do read outfile
done
if [ $booru != danbooru.donmai.us/posts ]
then curl https://$booru\?tags\=${tags}\&limit\=1000 2>/dev/null|sed -n 23p|sed 's/page=/\n/g;s/&amp;/\n/g'|sed -n 3p>page
     if ! [ 0 -lt `cat page` ]
     then	 page_max=1
     else	 page_max=`cat page`
     fi
else echo Please type how many pages you wish get \(Max: 1000 or others\)
	 read page_max
fi
page=0
while [ $page -lt $page_max ]
do page=$((page+1))
	echo https://$booru.json?tags=${tags}\&page=$page\&limit\=1000 >> List
done
aria2c -i List #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy # -j：Set maximum number of parallel downloads for  (1～n，default 5)
cat ${booru#*/}*|sed 's/{/\n{/g ; s/}]/}\n]/g'|
# grep -v 'rating":"q' | #exclude Questionable
# grep -v 'rating":"e' | #exclude Explicit
# grep -v 'rating":"s' | #exclude Safe
sed 's/,/\n/g'|grep \"file_url|sed 's/"file_url":"//g;s/"//g'>$path/"$outfile"
rm -rf $tempdir
