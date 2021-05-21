#!/usr/bin/env bash
## CUSTOM_SHELL_FILE for https://gitee.com/lxk0301/jd_docker/tree/master/docker
### 编辑docker-compose.yml文件添加: - CUSTOM_SHELL_FILE=https://raw.githubusercontent.com/monk-coder/dust/dust/shell_script_mod.sh
#### 容器完全启动后执行 docker exec -it jd_scripts /bin/sh -c 'crontab -l' 查看目前修行的经书

function monkcoder(){
    # https://github.com/monk-coder/dust
    rm -rf /monkcoder /scripts/monkcoder_*
    git clone https://github.com/monk-coder/dust.git /monkcoder
    for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/|z_health_energy.js|z_mother_jump.js|z_xmf.js|z_health_community.js|monk_shop_follow_sku.js|monk_shop_add_to_car.js"); do cp ${jsname} /scripts/monkcoder_${jsname##*/}; done
}

function diycron(){
    # monkcoder定时任务
    for jsname in /scripts/monkcoder_*.js; do
        jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsnamecron" || echo "$jsnamecron node $jsname >> /scripts/logs/$(echo $jsname | cut -d/ -f3).log 2>&1" >> /scripts/docker/merged_list_file.sh
    done
}

function main(){
    # 首次运行时拷贝docker目录下文件
    [[ ! -d /jd_sku ]] && mkdir /jd_sku && cp -rf /scripts/docker/* /jd_sku
    # DIY脚本
    a_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    a_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    monkcoder
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
