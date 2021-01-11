#!/bin/bash
DIR=/home/data/esdump
if [[ -d $DIR ]]; then
        echo yes $DIR >> /dev/null
else
        mkdir -p $DIR
fi
DIRC=/home/data/escorequerydump
if [[ -d $DIRC ]]; then
        echo yes $DIRC >> /dev/null
else
        mkdir -p $DIRC
fi


esname=(es5-elasticsearch)
escorequery=(es5-corequery)
ns=(default)
PORT=$( kubectl get svc -n $ns |grep $esname|awk '{print $5}'|head -1|awk -F':' '{print $1}' |tr -d  '/TCP')
ESIP=$( kubectl get svc -n $ns |grep $esname|awk '{print $3}'|head -1 )
URL=$ESIP:$PORT

PORTC=$( kubectl get svc -n $ns |grep $escorequery|awk '{print $5}'|head -1|awk -F':' '{print $1}' |tr -d  '/TCP')
ESIPC=$( kubectl get svc -n $ns |grep $escorequery|awk '{print $3}'|head -1 )
URLC=$ESIPC:$PORTC


case $1 in
        dump )

#cd $DIR
for item in $(curl 'http://'$ESIP':'$PORT'/_cat/indices' | awk '{print $3}')
do
  echo mapping $item
  elasticdump --input=http://$URL/$item --output=$DIR/$item'=mapping.json' --limit=1000 --type=mapping 
  echo settings $item
  elasticdump --input=http://$URL/$item --output=$DIR/$item'=settings.json' --limit=1000 --type=settings
  echo data $item
  elasticdump --input=http://$URL/$item --output=$DIR/$item'=data.json' --limit=1000 --type=data

done

# cd $DIRC
for itemc in $(curl 'http://'$ESIPC':'$PORTC'/_cat/indices' | awk '{print $3}')
do
  echo mapping $itemc
  elasticdump --input=http://$URLC/$itemc --output=$DIRC/$itemc'=mapping.json' --limit=1000 --type=mapping
  echo settings $itemc
  elasticdump --input=http://$URLC/$itemc --output=$DIRC/$itemc'=settings.json' --limit=1000 --type=settings
  echo data $itemc
  elasticdump --input=http://$URLC/$itemc --output=$DIRC/$itemc'=data.json' --limit=1000 --type=data

done


                ;;

    up )


# 恢复

find $DIR  -empty -delete 
find $DIRC  -empty -delete 

for item in $(ls $DIR)
do
        echo 开始 $item mapping
        elasticdump --input=$DIR/$item  --output=http://$URL/${item%=*} --type=mapping
        echo 开始 $item settings
        elasticdump --input=$DIR/$item  --output=http://$URL/${item%=*} --type=settings
        echo 开始 $item data
        elasticdump --input=$DIR/$item  --output=http://$URL/${item%=*} --type=data

done

for itemc in $(ls $DIRC)
do
        echo 开始 $itemc mapping
        elasticdump --input=$DIRC/$itemc  --output=http://$URLC/${itemc%=*} --type=mapping
    echo 开始 $itemc settings
        elasticdump --input=$DIRC/$itemc  --output=http://$URLC/${itemc%=*} --type=settings
        echo 开始 $itemc data
        elasticdump --input=$DIRC/$itemc --output=http://$URLC/${itemc%=*} --type=data

done

      ;; 
          *) echo "$0 {dump|up}"
             exit 4
             ;;
esac
