#!/usr/bin/env bash

function nianyuguai(){
    # https://github.com/nianyuguai/longzhuzhu.git
    rm -rf /longzhuzhu /scripts/longzhuzhu_*
    git clone -b main https://github.com/nianyuguai/longzhuzhu.git /longzhuzhu
    for jsname in $(ls /longzhuzhu/qx | grep -oE ".*\js$"); do cp -rf /longzhuzhu/qx/$jsname /scripts/longzhuzhu_$jsname; done
}

function jddj(){
    # https://github.com/passerby-b/JDDJ.git
    rm -rf /jddj /scripts/jddj_*
    git clone -b main https://github.com/passerby-b/JDDJ.git /jddj
    for jsname in $(ls /jddj | grep -oE ".*\js$"); do cp -rf /jddj/$jsname /scripts/$jsname; done
}

function didi_fruit(){
    # https://github.com/passerby-b/didi_fruit.git
    rm -rf /didi_fruit /scripts/didi_fruit_*
    git clone -b main https://github.com/passerby-b/didi_fruit.git /didi_fruit
    for jsname in $(ls /didi_fruit | grep -oE ".*\js$"); do cp -rf /didi_fruit/$jsname /scripts/didi_fruit_$jsname; done
}

function utterliar(){
    # https://github.com/utterliar1/Dockerfile.git
    rm -rf /utterliar /scripts/utterliar_*
    git clone https://github.com/utterliar1/Dockerfile.git /utterliar
    for jsname in $(find /utterliar -name "*.js" | grep -vE "\/backup\/"); do cp ${jsname} /scripts/utterliar_${jsname##*/}; done
}

function diycron(){
    # jddj didi_fruit utterliar定时任务
    for jsname in /scripts/utterliar_*.js /scripts/jddj_*.js /scripts/didi_fruit_*.js; do
        jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsnamecron" || echo "$jsnamecron node $jsname >> /scripts/logs/$(echo $jsname | cut -d/ -f3).log 2>&1" >> /scripts/docker/merged_list_file.sh
    done
    # 设置京豆雨cron
    echo "0 * * * * node /scripts/longzhuzhu_jd_super_redrain.js >> /scripts/logs/longzhuzhu_jd_super_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
    echo "30 16-23/1 * * * node /scripts/longzhuzhu_jd_half_redrain.js >> /scripts/logs/longzhuzhu_jd_half_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
}

function main(){
    # 首次运行时拷贝docker目录下文件
    [[ ! -d /jd_sku ]] && mkdir /jd_sku && cp -rf /scripts/docker/* /jd_sku
    # DIY脚本
    a_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    a_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    nianyuguai
    jddj
    didi_fruit
    utterliar        
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
