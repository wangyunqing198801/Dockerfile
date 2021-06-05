#!/usr/bin/env bash

:<<!
function nianyuguai(){
    # https://github.com/nianyuguai/longzhuzhu.git
    rm -rf /longzhuzhu /scripts/longzhuzhu_*
    git clone -b main https://github.com/nianyuguai/longzhuzhu.git /longzhuzhu
    for jsname in $(ls /longzhuzhu/qx | grep -oE ".*\js$"); do cp -rf /longzhuzhu/qx/$jsname /scripts/longzhuzhu_$jsname; done
}
!

function jddj(){
    # https://github.com/passerby-b/JDDJ.git
    rm -rf /jddj /scripts/jddj_*
    git clone -b main https://github.com/passerby-b/JDDJ.git /jddj
    for jsname in $(ls /jddj | grep -oE ".*\js$"); do cp -rf /jddj/$jsname /scripts/$jsname; done
}

:<<!
function didi_fruit(){
    # https://github.com/passerby-b/didi_fruit.git
    rm -rf /didi_fruit /scripts/didi_fruit_*
    git clone -b main https://github.com/passerby-b/didi_fruit.git /didi_fruit
    for jsname in $(ls /didi_fruit | grep -oE ".*\js$"); do cp -rf /didi_fruit/$jsname /scripts/didi_fruit_$jsname; done
}
!

function dd(){
    # https://github.com/passerby-b/didi_fruit.git
    rm -rf /dd /scripts/dd_*
    git clone -b main https://github.com/passerby-b/didi_fruit.git /dd
    for jsname in $(ls /dd | grep -oE ".*\js$"); do cp -rf /dd/$jsname /scripts/$jsname; done
}

function utterliar(){
    # https://github.com/utterliar1/Dockerfile.git
    rm -rf /utterliar /scripts/utterliar_*
    git clone https://github.com/utterliar1/Dockerfile.git /utterliar
    for jsname in $(find /utterliar -name "*.js" | grep -vE "\/backup\/"); do cp ${jsname} /scripts/utterliar_${jsname##*/}; done
}

function panghu(){
    # https://github.com/panghu999/panghu.git
    rm -rf /panghu /scripts/panghu_*
    git clone https://github.com/panghu999/panghu.git /panghu
    for jsname in $(find /panghu -name "*.js" | grep -vE "txsp.js|jdCookie.js|sendNotify.js"); do cp ${jsname} /scripts/panghu_${jsname##*/}; done
}

function Wenmoux(){
    # https://github.com/Wenmoux/scripts.git
    rm -rf /Wenmoux /scripts/Wenmoux_*
    git clone https://github.com/Wenmoux/scripts.git /Wenmoux
    for jsname in $(find /Wenmoux -name "*.js" | grep -vE "jddj_help.js"); do cp ${jsname} /scripts/Wenmoux_${jsname##*/}; done
}

function panda(){
    # https://github.com/zooPanda/zoo.git
    rm -rf /panda /scripts/panda_*
    git clone https://github.com/zooPanda/zoo.git /panda
    for jsname in $(find /panda -name "*.js" | grep -vE "member"); do cp ${jsname} /scripts/panda_${jsname##*/}; done
}

function diycron(){
    # jddj dd utterliar panghu Wenmoux定时任务
    for jsname in /scripts/utterliar_*.js /scripts/jddj_*.js /scripts/dd_*.js /scripts/panghu_*.js /scripts/Wenmoux_*.js; do
        jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsnamecron" || echo "$jsnamecron node $jsname >> /scripts/logs/$(echo $jsname | cut -d/ -f3).log 2>&1" >> /scripts/docker/merged_list_file.sh
    done
:<<!
    # 设置京豆雨cron
    echo "0 * * * * node /scripts/longzhuzhu_jd_super_redrain.js >> /scripts/logs/longzhuzhu_jd_super_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
    echo "30 16-23/1 * * * node /scripts/longzhuzhu_jd_half_redrain.js >> /scripts/logs/longzhuzhu_jd_half_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
    echo "1 20 1-18 6 * node /scripts/longzhuzhu_long_hby_lottery.js >> /scripts/logs/longzhuzhu_long_hby_lottery.log 2>&1" >> /scripts/docker/merged_list_file.sh
    # 浓情618 与“粽”不同
    # https://github.com/zooPanda/zoo.git
    wget --no-check-certificate -O /scripts/zooLongzhou.js https://github.com/zooPanda/zoo/blob/dev/zooLongzhou.js
    echo "15 13 1-18 6 * node /scripts/zooLongzhou.js |ts >> /scripts/logs/zooLongzhou.log 2>&1" >> /scripts/docker/merged_list_file.sh
    # https://github.com/yangtingxiao/QuantumultX.git   
    wget --no-check-certificate -O /scripts/jd_starStore.js https://github.com/yangtingxiao/QuantumultX/raw/master/scripts/jd/jd_starStore.js
    echo "5 9 * * * node /scripts/jd_starStore.js |ts >> /scripts/logs/jd_starStore.log 2>&1" >> /scripts/docker/merged_list_file.sh
!
    echo "15 13 1-18 6 * node /scripts/panda_zooLongzhou.js |ts >> /scripts/logs/zooLongzhou.log 2>&1" >> /scripts/docker/merged_list_file.sh
    echo "18 9 1-18 6 * node /scripts/panda_zooBaojiexiaoxiaole.js |ts >> /scripts/logs/zooBaojiexiaoxiaole.log 2>&1" >> /scripts/docker/merged_list_file.sh
}

function main(){
    # 首次运行时拷贝docker目录下文件
    [[ ! -d /jd_sku ]] && mkdir /jd_sku && cp -rf /scripts/docker/* /jd_sku
    # DIY脚本
    a_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    a_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    jddj
    dd
    utterliar
    panghu
    Wenmoux
    b_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    b_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    # DIY任务
    diycron
    # DIY脚本更新TG通知
    info_more=$(echo $a_jsname  $b_jsname | tr " " "\n" | sort | uniq -c | grep -oE "1 .*$" | grep -oE "[^ ]*js$" | tr "\n" " ")
    [[ "$a_jsnum" == "0" || "$a_jsnum" == "$b_jsnum" ]] || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=DIY脚本更新完成：$a_jsnum $b_jsnum $info_more" >/dev/null
    # LXK脚本更新TG通知
    lxktext="$(diff /jd_sku/crontab_list.sh /scripts/docker/crontab_list.sh | grep -E "^[+-]{1}[^+-]+" | grep -oE "node.*\.js" | cut -d/ -f3 | tr "\n" " ")"
    test -z "$lxktext" || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=LXK脚本更新完成：$(cat /jd_sku/crontab_list.sh | grep -vE "^#" | wc -l) $(cat /scripts/docker/crontab_list.sh | grep -vE "^#" | wc -l) $lxktext" >/dev/null
    # 拷贝docker目录下文件供下次更新时对比
    cp -rf /scripts/docker/* /jd_sku
}

main
