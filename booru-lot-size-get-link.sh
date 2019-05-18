#!/bin/bash
# v1.3.1
# Poly000
# able to get booru pics link as a link list text file.
http_proxy=
https_proxy=
temp0=`mktemp -td dir.XXXXXXXX`
cd $temp0
function set_booru(){
	booru=`kdialog --menu Please\ select\ a\ booru 1 Danbooru 2 Konachan 3 Yande.re 2>/dev/null`
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
	if [ x${path} = x ]
	then save_file
	fi
}
function search_tags(){
	if tags=`kdialog --inputbox Please\ type\ the\ keyword\ to\ search\ tags 2>/dev/null`
	then if [ x = x${tags} ]
	     then search_tags
	     fi
	fi
	if [ x != x${tags} ]
	then
		kdialog --msgbox started\ to\ search... 2>/dev/null &
		temp1=`mktemp -t temp.XXXXXXXX`
		exec 3> $temp1
		echo Konachan: >&3
		wget https://konachan.net/tag?name=${tags} -o /dev/null -O -|grep next_page|sed -s 's/&amp;type=">/\n/g ; s/</\n/g ; s/">/\n/g'|sed -n 29p>tags
		max_tags=`cat tags`
		if [ x$max_tags != x ]
		then	page_tags=0
			rm tags
			until [ $page_tags = $max_tags ]
			do	page_tags=$((page_tags+1))
				echo https://konachan.net/tag.json?name=${tags}\&page\=$page_tags >> tags
			done
			aria2c -i tags # -j num --http-proxy=$http_proxy --https-proxy=$https_proxy # -j：Set maximum number of parallel downloads for  (1～n，default 5)
			cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
			rm tag*
		else	wget https://konachan.net/tag.json?name=${tags} -o /dev/null -O -|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
			rm tag*
		fi
		echo >&3
		echo Yande.re: >&3
		wget https://yande.re/tag?name=${tags} -o /dev/null -O -|grep next_page|sed -s 's/&amp;type=">/\n/g ; s/</\n/g ; s/">/\n/g'|sed -n 29p>tags
		max_tags=`cat tags`
		if [ x$max_tags != x ]
		then	page_tags=0
			rm tags
			until [ $page_tags = $max_tags ]
			do	page_tags=$((page_tags+1))
				echo https://yande.re/tag.json?name=${tags}\&page\=$page_tags >> tags
			done
			aria2c -i tags # -j num --http-proxy=$http_proxy --https-proxy=$https_proxy # -j：Set maximum number of parallel downloads for  (1～n，default 5)
			cat tag.*|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
			rm tag*
		else	wget https://yande.re/tag.json?name=${tags} -o /dev/null -O -|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
			rm tag*
		fi
		echo >&3
		echo Danbooru: >&3
		wget 'https://danbooru.donmai.us/tags.json?commit=Search&search[hide_empty]=yes&search[name_matches]=*'${tags}'*&search[order]=date&utf8=%E2%9C%93' -o /dev/null -O -|sed 's/,/\n/g'|grep \"name|sed 's/"name":"//g;s/"//g' >&3
		rm tag*
		kdialog --textbox $temp1 450 675 2>/dev/null &
		if kdialog --yesno Do\ you\ wish\ search\ next\ tag? 2>/dev/null
		then	tags=
			search_tags
		fi
	fi
}
search_tags
set_booru
tags=`kdialog --inputbox Please\ type\ the\ tags\ you\ wish\ \(use\ +\ connect\ tags\) 2>/dev/null`
if [ $booru != danbooru.donmai.us/posts ]
then 	wget https://$booru\?tags\=${tags} -o /dev/null -O - |sed -s 's/ /\n/g'|grep href|tail -n 12|sed -s 's/&amp;/\n/g'|head -n 1|sed -s 's\href="/post?page=\\g'>page
	page_max=`kdialog --inputbox 'Please type how many pages you wish get (Default: max)' 2>/dev/null`
	if ! [ 0 -lt `cat page` ]
	then	 page_max=1
	elif [ 0$page_max = 0 ]
	then	 page_max=`cat page`
	fi
else 	page_max=`kdialog --inputbox 'Please type how many pages you wish get (Max: 1000 or others)' 2>/dev/null`
fi
page=0
while [ $page -lt $page_max ]
do 	page=$((page+1))
	echo https://$booru.json?tags=${tags}\&page=$page >> List
done
temp2=`mktemp -t temp.XXXXXXXX`
kdialog --msgbox started to get... 2>/dev/null &
aria2c -i List #-j num #--http-proxy=$http_proxy --https-proxy=$https_proxy # -j：Set maximum number of parallel downloads for  (1～n，default 5)
cat ${booru#*/}*|sed 's/{/\n{/g ; s/}]/}\n]/g'|
# grep -v 'rating":"q' | #exclude Questionable
# grep -v 'rating":"e' | #exclude Explicit
# grep -v 'rating":"s' | #exclude Safe
sed 's/,/\n/g'|grep \"file_url|sed 's/"file_url":"//g;s/"//g'>$temp2
save_file
cp $temp2 "${path}"
rm -rf $temp0 $temp1 $temp2
