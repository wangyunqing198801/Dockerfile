#!/usr/bin/env bash

#和尚仓库脚本
function initDust() {
    git clone git@github.com:monk-coder/dust.git /monkcoder
}

#京东到家仓库脚本
function initJddj() {
    git clone https://github.com/passerby-b/JDDJ.git /scripts/jddj
}

#### monk-coder https://github.com/monk-coder/dust
function monkcoder(){
    # https://github.com/monk-coder/dust
    if [ ! -d "/monkcoder/" ]; then
        echo "未检查到和尚仓库脚本，初始化下载相关脚本"
        initDust
    else
        echo "更新和尚仓库脚本相关文件"
        git -C /monkcoder reset --hard
        git -C /monkcoder pull --rebase
    fi
    # 拷贝脚本
    rm -rf /scripts/monkcoder_*
    for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/"); do cp ${jsname} /scripts/monkcoder_${jsname##*/}; done
}

#### JDDJ https://github.com/passerby-b/JDDJ
function jddj(){
    rm -rf /scripts/jddj
    initJddj
    echo "更新京东到家仓库完成..."
}

function diycron(){
    # monkcoder 定时任务
    for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/"); do
        jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsnamecron" || echo "$jsnamecron node /scripts/monkcoder_${jsname##*/} >> /scripts/logs/monkcoder_${jsname##*/}.log 2>&1" >> /scripts/docker/merged_list_file.sh
    done
    # JDDJ 定时任务
    for jsname in $(ls /scripts/jddj | grep -E "js$" | tr "\n" " "); do
        jsnamecron="$(cat /scripts/jddj/$jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsnamecron" || echo "$jsnamecron node /scripts/jddj/$jsname >> /scripts/logs/jddj_$jsname.log 2>&1" >> /scripts/docker/merged_list_file.sh
    done    
    #https://github.com/nianyuguai/longzhuzhu
    wget --no-check-certificate -O /scripts/lzz_super_redrain.js https://raw.githubusercontent.com/nianyuguai/longzhuzhu/main/qx/jd_super_redrain.js
    echo "0,1 0-23/1 * * * node /scripts/lzz_super_redrain.js |ts >> /scripts/logs/lzz_super_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
    #https://github.com/nianyuguai/longzhuzhu
    wget --no-check-certificate -O /scripts/lzz_half_redrain.js https://raw.githubusercontent.com/nianyuguai/longzhuzhu/main/qx/jd_half_redrain.js
    echo "30 20-23/1 * * * node /scripts/lzz_half_redrain.js |ts >> /scripts/logs/lzz_half_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
    #https://raw.githubusercontent.com/ZCY01/daily_scripts/main/jd/jd_try.js
    #wget --no-check-certificate -O /scripts/zcy01_jd_try.js https://raw.githubusercontent.com/ZCY01/daily_scripts/main/jd/jd_try.js
    #echo "55 17 */7 * * node /scripts/zcy01_jd_try.js |ts >> /scripts/logs/zcy01_jd_try.log 2>&1" >> /scripts/docker/merged_list_file.sh
}


function main(){
    # 首次运行时拷贝docker目录下文件及创建dust脚本使用文件夹
    [[ ! -d /jd_diy ]] && mkdir /jd_diy && cp -rf /scripts/docker/* /jd_diy
    # DIY脚本执行前后信息
    a_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    a_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    monkcoder
    jddj
    b_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    b_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    # DIY任务
    diycron
    # DIY脚本更新TG通知
    info_more=$(echo $a_jsname  $b_jsname | tr " " "\n" | sort | uniq -c | grep -oE "1 .*$" | grep -oE "[^ ]*js$" | tr "\n" " ")
    [[ "$a_jsnum" == "0" || "$a_jsnum" == "$b_jsnum" ]] || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=DIY脚本更新完成：$a_jsnum $b_jsnum $info_more" >/dev/null
    # LXK脚本更新TG通知
    lxktext="$(diff /jd_diy/crontab_list.sh /scripts/docker/crontab_list.sh | grep -E "^[+-]{1}[^+-]+" | grep -oE "node.*\.js" | cut -d/ -f3 | tr "\n" " ")"
    test -z "$lxktext" || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=LXK脚本更新完成：$(cat /jd_diy/crontab_list.sh | grep -vE "^#" | wc -l) $(cat /scripts/docker/crontab_list.sh | grep -vE "^#" | wc -l) $lxktext" >/dev/null
    # 拷贝docker目录下文件供下次更新时对比
    cp -rf /scripts/docker/* /jd_diy
}

main
