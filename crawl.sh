#!/bin/bash

#後にjsonの鍵を格納してopenrecなどに対応する予定でした。
declare -A CIDs;

CIDs=(

["にじさんじ公式"]="UCX7YkU9nEeaoZbkVLVajcMg"
#一期生
["月ノ美兎"]="UCD-miitqNY3nyukJ4Fnf4_A"
["勇気ちひろ"]="UCLO9QDxVL4bnvRRsz6K4bsQ"
["エルフのえる"]="UCYKP16oMX9KKPbrNgo_Kgag"
["樋口楓"]="UCsg-YqdqQ-KFF0LNk23BY4A"
["静凛"]="UC6oDys1BGgBsIC3WhG1BovQ"
["渋谷ハジメ"]="UCeK9HFcRZoTrvqcUCtccMoQ"
["鈴谷アキ"]="UCt9qik4Z-_J-rj3bKKQCeHg"
["モイラ"]="UCvmppcdYf4HOv-tFQhHHJMA"

#二期生
["鈴鹿詩子"]="UCwokZsOK_uEre70XayaFnzA"
["宇志海いちご"]="UCmUjjW5zF1MMOhYUwwwQv9Q"
["家長むぎ"]="UC_GCs6GARLxEHxy1w40d6VQ"
["夕陽リリ"]="UC48jH1ul-6HOrcSSfoR02fQ"
["物述有栖"]="UCt0clH12Xk1-Ej5PXKGfdPA"
["文野環"]="UCBiqkFJljoxAj10SoP2w2Cg"
["伏見ガク"]="UCXU7YYxy_iQd3ulXyO-zC2w"
["ギルザレンⅢ世"]="UCUzJ90o1EjqUbk2pBAy0_aw"
["剣持刀也"]="UCv1fFr156jc65EMiLbaLImw"
["森中花咲"]="UCtpB6Bvhs1Um93ziEDACQ8g"
)

return_apikey () {
now_hour=$(date +%k)

if [ $now_hour -ge 0 -a $now_hour -le 7 ] ;then
  echo "AIzaSyAlFqdEc4x0AUBjdC6tBMcF3yq3t5hLBdc"
elif [ $now_hour -ge 8 -a $now_hour -le 15 ] ;then
  echo "AIzaSyBxoo5CS7tkCZPOKNK5o2dC7g1FnWznHZ0"
  else
    echo "AIzaSyBzs7sNWJuHjVVN_jqS4ikPzraPt5kCKqw"
fi
}

#ワーキングフォルダ
template_folder=""

#お借りしたtwitterクライアントを配置した場所
tweet_client_path=""

#ここの文字連結のための値はもう少しスマートな書き方があると思います
APIKEY=$(return_apikey)
APIURL1="https://www.googleapis.com/youtube/v3/search?part=snippet&channelId="
APIURL2="&type=video&eventType=live&key="
APIURL3="&type=video&eventType=upcoming&key="
VIDURL="https://www.youtube.com/watch?v="

SECONDS=0

#API周りの動作を確認するためのもの
if [ "$1" = "apikey" ];then
echo "$APIKEY"
elif [ "$1" = "apiurl" ];then
echo "${APIURL1}${2}${APIURL2}${APIKEY}"
elif [ "$1" = "log" ];then

#動作の簡易チェック用(開発時のみ使用)
if [ "$2" = "delete" ];then
cat /dev/null > $template_folder/log.txt
elif [ -n "$2" ];then
cat $template_folder/log.txt | grep "$3"
else
cat $template_folder/log.txt
fi


#デバッグをする時間がちょうど配信の時間とかぶる事が多かったので使わせていただきました
elif [ "$1" = "testapi" ];then
curl -H "application/json" ${APIURL1}${CIDs["勇気ちひろ"]}${APIURL2}${APIKEY}

#動作の確認用
elif [ "$1" = "debug" ];then
if [ "$2" = "delete" ];then
cat /dev/null >  $template_folder/debug.txt
elif [ -n "$2" ];then
cat $template_folder/debug.txt | grep "$2"
else
cat $template_folder/debug.txt
fi

#動作の確認用、現在配信しているライバーを格納するファイルを表示
elif [ "$1" = "keylist" ];then
cat $template_folder/hoge.txt

#自分で書いておいて引数を忘れる事が多々あったので特に忘れるものの備忘録
elif [ "$1" = "help" -o "$1" = "-h" ];then
echo ""
echo "apikey:現在使用されているAPIキーを表示"
echo "testapi:現在使用しているapiキーが使用可能かcurlを動作させて確認"
echo "keylist:現在ライブ配信を行っているライバーとVIDの一覧"
echo 'log [サブコマンド]:ログファイルを表示'
echo "debug [サブコマンド]:デバッグログを表示"
echo ""

#ちーちゃんが配信していない時に動作を見るためのもの、スマートではないです
elif [ "$1" = "getjson" ];then
if [ -z "$2" ];then
echo "Invalid UID!"
else
curl -H "application/json" -s ${APIURL1}${2}${APIURL2}${APIKEY}
fi

else


for key in ${!CIDs[@]};do

curl -H "application/json" -s ${APIURL1}${CIDs[$key]}${APIURL2}${APIKEY} > $template_folder/tmp.txt

VID=$( jq -r '.items[0].id.videoId' $template_folder/tmp.txt )
pre_VID=$(grep "$key" $template_folder/hoge.txt | tr -d "${key}:")
Vtitle=$(jq -r '.items[0].snippet.title' $template_folder/tmp.txt)
date=$(date +%H:%M)

#VIDがnullでなければ
if [ -n "$VID" -a "$VID" != "null" ] ;then 
 #VIDを比較
 if  [ "$pre_VID" = "$VID" ] ;then
    echo "$(date) Broadcasting:$keyは$pre_VID(もしくは$VID)で配信中" >> $template_folder/debug.txt
  else
    #VIDとpre_VIDが異なるならばつぶやく
    echo "$keyが配信を開始しました" > $template_folder/memo.txt
    echo "$Vtitle" >> $template_folder/memo.txt
    echo "$VIDURL$VID" >> $template_folder/memo.txt

    cat $template_folder/memo.txt | $tweet_client_path/tweet.sh post
    echo "$date $keyが配信を開始しました $VIDURL$VID" >> $template_folder/log.txt
    echo "$(date) live_notify:$keyが配信" >> $template_folder/debug.txt

    #pre_VIDがnullの場合sedできないので対策
     if [ -z "$pre_VID" -a "$VID"!="null" ] ;then
     echo "${key}:${VID}" >> $template_folder/hoge.txt
     echo "$(date) DB_Access:${key}${VID}を追記" >> $template_folder/debug.txt 
     else
     sed -i "s/$key:$pre_VID/$key:$VID/g" "$template_folder/hoge.txt"
     echo "$(date) DB_Access:${key}の${pre_VID}を${VID}に書き換え" >> $template_folder/debug.txt
     fi
  fi


#VIDがnullっているのでhogeから該当行を削除
elif [ -n "$pre_VID" -a "$VID" = "null" ] ;then
  sed -i  "/$key:$pre_VID/d" "$template_folder/hoge.txt"
  echo "$(date) DB_Access:VIDがnullだったため${key}:${pre_VID}の記述を削除" >> $template_folder/debug.txt
  echo "$date $keyが配信を終了しました"
fi

echo "$(date) value_info:key=$key , PID=$pre_VID , VID=$VID ," >> $template_folder/debug.txt
echo "$(date) search_result:$key,$VIDで$(date +%H:%M)に該当ライバーの探査終了"  >> $template_folder/debug.txt

done

time="Processing was completed in $SECONDS at $date"
echo $time >> $template_folder/log.txt


fi
