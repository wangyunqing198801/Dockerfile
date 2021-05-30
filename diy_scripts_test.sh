#!/usr/bin/env bash
## 编辑docker-compose.yml文件添加 - CUSTOM_SHELL_FILE=https://raw.githubusercontent.com/mixool/jd_sku/main/jd_diy.sh
### CUSTOM_SHELL_FILE for https://gitee.com/lxk0301/jd_docker/tree/master/docker
#### DIY脚本仅供参考,由于更新可能引入未知BUG,建议Fork后使用自己项目的raw地址

if [ ! -f "/root/.ssh/utterliar1" ]; then
    echo "未检查到仓库密钥，复制密钥2"
    cp /scripts/logs/.ssh/utterliar1 /root/.ssh/utterliar1
    chmod 600 /root/.ssh/utterliar1
fi

if [ ! -f "/root/.ssh/config" ]; then
    echo "未检查到仓库密钥配置，复制密钥配置"
    cp /scripts/logs/.ssh/config /root/.ssh/config
fi

function monkcoder(){
    # https://github.com/monk-coder/dust
    rm -rf /monkcoder /scripts/monkcoder_*
    git clone git@github.com:utterliar1/monkcoer.git /monkcoder
    for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/|adolf_pk.js|adolf_star.js|z_health_energy.js|z_city_cash.js|z_carnivalcity.js|z_mother_jump.js|z_xmf.js|z_health_community.js|monk_shop_follow_sku.js|monk_shop_add_to_car.js"); do cp ${jsname} /scripts/monkcoder_${jsname##*/}; done
}

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
    git clone -b main https://github.com/utterliar1/Dockerfile.git /utterliar
    for jsname in $(ls /utterliar | grep -oE ".*\js$"); do cp -rf /utterliar/$jsname /scripts/utterliar_$jsname; done
}

function diycron(){
    # monkcoder jddj didi_fruit定时任务
    for jsname in /scripts/monkcoder_*.js /scripts/jddj_*.js /scripts/didi_fruit_*.js; do
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
    monkcoder
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
