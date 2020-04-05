#!/bin/bash
# CLI-1.3.5
# Poly000
# The script could use for get anime pictures' URLs for konachan, yande.re, danbooru
##########
# aria2 -> -j：set out how many pictures will concurrent downloading
http_proxy=
https_proxy=
# note: host:port or http://user:pwd@host:port
# Please replace curl as "curl -x $http_proxy"
path=`pwd`
tempdir=`mktemp -td dir.XXXXXXXX`
cd $tempdir
a()
{
echo "Please type keywords of one tag"
read tags
if [ ! x"${tags}" = xn ]
then if [ x"${tags}" = x ]
     then a
	 else a=1
     fi
fi
if [ $a = 1 ]
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
	aria2c -i tags #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy
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
	aria2c -i tags #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy
	cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
else	curl https://yande.re/tag.json?name="${tags}" 2>/dev/null|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
	rm tag*
fi
echo
echo Danbooru:
curl 'https://danbooru.donmai.us/tags.json?commit=Search&search\[hide_empty\]=yes&search\[name_matches\]=*'"${tags}"'*&search\[order\]=date&utf8=%E2%9C%93' 2>/dev/null|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g'
echo "Would you like to search the next tag? (Y/n)"
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
echo "Please select a site for 'danbooru'(d), 'konachan'(k), 'yande.re'(y)"
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
echo "Please type tag(s), 'and' use '+', 'except' use '+-'"
read tags
echo "Please type a path to save URLs as a text file"
while [ x$outfile = x ]
do read outfile
done
if [ $booru != danbooru.donmai.us/posts ]
then curl https://$booru\?tags\="${tags}"\&limit\=1000 2>/dev/null |grep pagination|sed 's/<a class="next_page"/\n/g ; s\</a>\\g ; s/">/\n/g'|tail -n 3|sed -n 1p > page
     if ! [ 0 -lt `cat page` ]
     then	 page_max=1
     else	 page_max=`cat page`
     fi
else echo "Please type how many page do you wish to get URLs(limited in 200pictures/page)"
	read page_max
fi
page=0
while [ $page -lt $page_max ]
do page=$((page+1))
	echo https://$booru.json?tags="${tags}"\&page=$page\&limit\=1000 >> List
done
aria2c -i List #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy
sed 's/{/\n{/g ; s/}]/}\n]/g' ${booru#*/}*|
# grep -v 'rating":"q' | #exclude the 'Questionable' level
# grep -v 'rating":"e' | #exclude the 'Explicit' level
# grep -v 'rating":"s' | #exclude the 'Safe' level
sed 's/,/\n/g'|grep \"file_url|sed 's/"file_url":"//g;s/"//g'>"$path"/"$outfile"
rm -rf $tempdir
