#超级直播间红包雨
#30 20-23 * * * node /scripts/utterliar_lxk_live_redrain.js >> /scripts/logs/lxk_live_redrain.log 2>&1

#领现金兑换红包
#0,1,2 0 * * * node /scripts/utterliar_jd_cash_exchange.js >> /scripts/logs/jd_cash_exchange.log 2>&1

#直播间抽奖（全局）
#15 9 * * 5 node /scripts/utterliar_jd_live_lottery_social.js >> /scripts/logs/jd_live_lottery_social.log 2>&1

#超级直播间盲盒
#35 20 * * * node /scripts/utterliar_jd_super_mh.js >> /scripts/logs/jd_super_mh.log 2>&1

#天天加速
8 0-23/3 * * * node /scripts/utterliar_jd_speed.js >> /scripts/logs/jd_speed.log 2>&1

#金榜创造营
0 8 21-31 5-12 * node /scripts/utterliar_jd_jbczy.js >> /scripts/logs/jd_jbczy.log 2>&1

#超市兑换
0 0 * * * node /scripts/utterliar_lxk_blueCoin.js >> /scripts/logs/lxk_blueCoin.log 2>&1

#宠汪汪兑换
0 16 * * * node /scripts/utterliar_lxk_joy_reward.js >> /scripts/logs/lxk_joy_reward.log 2>&1

#彩票查询
0 16 * * * node /scripts/utterliar_ssq.js >> /scripts/logs/ssq.log 2>&1


