本站所有文章和Github上所有脚本均可随意转载和修改使用，无任何约束，无需附上原文链接和本人名字

铭记大佬--hijkpw 已于2021年09月01日退网

## 谷歌云Google Cloud Platform开启SSH访问及设置root访问密码

使用root用户登录，使用sudo -i切换登录身份

设置root密码，使用passwd命令设置root密码

修改SSH配置文件
```
vim /etc/ssh/sshd_config
```
找到以下内容并修改；
PermitRootLogin yes //默认为no，需要开启root用户访问改为yes
PasswordAuthentication yes //默认为no，改为yes开启密码登陆

修改完成之后重启

## 一键脚本
V2ray多合一脚本，支持VMESS+websocket+TLS+Nginx、VLESS+TCP+XTLS、VLESS+TCP+TLS等组合: </br>
```
bash <(curl -s -L https://raw.githubusercontent.com/Krito-LiXing/hijkpw--/master/v2ray.sh)
```
```
bash <(curl -s -L https://raw.githubusercontent.com/Krito-LiXing/hijkpw--/master/hiifeng_v2ray.sh)
```
如果脚本未找到Dig命令，可能需要安装

[ centos系统]
``` 
yum install bind-utils
```
[ Debain系统]
``` 
apt install dnsutils
 ``` 
安装完成再执行脚本
[Xray一键脚本](https://v2raytech.com/xray-one-click-script/)
[ Xray 一键脚本] ( https://v2raytech.com/xray-one-click-script/ )
## 魔改BBR加速脚本
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Krito-LiXing/Linux-NetSpeed/master/tcp.sh"
chmod +x tcp.sh
./tcp.sh
```
## TG代理脚本
```bash
mkdir /home/mtproxy && cd /home/mtproxy

curl -s -o mtproxy.sh https://raw.githubusercontent.com/Krito-LiXing/hijkpw--/master/mtproxy.sh && chmod +x mtproxy.sh && bash mtproxy.sh
```
## 使用

运行服务

```bash
bash mtproxy.sh start
```
调试运行

```bash
bash mtproxy.sh debug
```

停止服务

```bash
bash mtproxy.sh stop
```

重启服务

```bash
bash mtproxy.sh restart
```



## 卸载安装

因为是绿色版卸载极其简单，直接删除所在目录即可。

```bash
rm -rf /home/mtproxy
```

## 开机启动

开机启动脚本，如果你的rc.local文件不存在请检查开机自启服务。

通过编辑文件`vi /etc/rc.local`再按i进行编辑将如下代码加入到开机自启脚本中，修改完毕后，先按ESC进入底线命令模式，之后输入 :wq，再回车即可保存修改并退出

```bash
bash /home/mtproxy/mtproxy.sh start > /dev/null 2>&1 &
```
如果提示 curl: command not found ，那是因为你的 VPS 没装 Curl
ubuntu/debian 系统安装 Curl 方法: apt-get update -y && apt-get install curl -y
centos 系统安装 Curl 方法: yum update -y && yum install curl -y
安装好 curl 之后就能安装脚本了

## Shadowsocks/SS一键脚本 </br>
```
bash <(curl -sL https://raw.githubusercontent.com/Krito-LiXing/hijkpw--/master/ss.sh)
```

## Shadowsocks/SSR一键脚本 </br>
```
bash <(curl -sL https://raw.githubusercontent.com/Krito-LiXing/hijkpw--/master/ssr.sh)
```

# 客户端配置教程

## SS

[Shadowsocks/SS windows客户端配置教程](https://v2raytech.com/shadowsocks-windows-client-config-tutorial/)

[Shadowsocks/SS安卓配置教程](https://v2raytech.com/shadowsocks-android-config-tutorial/)

[小火箭(Shadowrocket)配置ss/ssr教程](https://v2raytech.com/shadowrocket-config-shadowsocks-shadowsocksr-tutorial/)
 	
[ShadowsocksX-NG配置教程](https://v2raytech.com/shadowsocksx-ng-config-tutorial/)

Shadowsocks/SS一键脚本 </br>
```
bash <(curl -sL https://raw.githubusercontent.com/Krito-LiXing/hijkpw--/master/ss.sh)
```

## SSR

[ShadowsocksR/SSR windows客户端配置教程](https://v2raytech.com/shadowsocksr-ssr-windows-client-config-tutorial/)
 	
[ShadowsocksR/SSR/SSRR安卓客户端配置教程](https://v2raytech.com/shadowsocksr-ssr-ssrr-android-config-tutorial/)

[小火箭(Shadowrocket)配置ss/ssr教程](https://v2raytech.com/shadowrocket-config-shadowsocks-shadowsocksr-tutorial/)

[SSR版ShadowsocksX-NG配置教程](https://v2raytech.com/ssr-shadowsocksx-ng-config-tutorial/)



## V2Ray

[V2rayN 4.12配置教程](https://v2raytech.com/v2rayn-4-12-config-tutorial/)

[V2rayN配置教程](https://v2raytech.com/v2rayn-config-tutorial/)

[V2rayW配置教程](https://v2raytech.com/v2rayw-config-tutorial/)

[V2rayU配置教程](https://v2raytech.com/v2rayu-config-tutorial/)

[V2rayX配置教程](https://v2raytech.com/v2rayx-config-tutorial/)

[V2rayNG配置教程](https://v2raytech.com/v2rayng-config-tutorial/)

[Kitsunebi安卓版配置教程](https://v2raytech.com/kitsunebi-android-config-tutorial/)

[bifrostV配置教程](https://v2raytech.com/bifrostv-config-tutorial/)

[v2ray多用户配置](https://v2raytech.com/v2ray-multiple-users/)

[v2ray伪装建站教程](https://v2raytech.com/v2ray-mask-with-website/)

[Clash for Windows配置V2ray教程](https://v2raytech.com/clash-for-windows-v2ray-tutorial/)

[ClashX配置V2ray教程](https://v2raytech.com/clashx-config-v2ray-tutorial/)

[Clash for Android配置V2ray教程](https://v2raytech.com/clash-for-android-config-v2ray-tutorial/)

## trojan

[trojan Windows客户端配置教程](https://v2raytech.com/trojan-windows-client-tutorial/)

[trojan安卓客户端配置教程](https://v2raytech.com/trojan-android-client-config-tutorial/)

[trojan mac客户端配置教程](https://v2raytech.com/trojan-mac-client-config-tutorial/)

[Shadowrocket配置trojan教程](https://v2raytech.com/shadowrocket-config-trojan-tutorial/)

[Clash for Windows配置trojan教程](https://v2raytech.com/clash-for-windows-trojan-config/)

[ClashX配置Trojan教程](https://v2raytech.com/clashx-config-trojan-tutorial/)

[Clash for Android配置trojan教程](https://v2raytech.com/clash-for-android-config-trojan-tutorial/)

[trojan建站教程](https://v2raytech.com/build-website-with-trojan/)

[trojan-go建站教程](https://v2raytech.com/trojan-go-with-website/)

# VPS教程

[VPS可以用来做什么？](https://v2raytech.com/what-can-vps-do/)

[CN2 GIA商家推荐](https://v2raytech.com/cn2-gia-merchants/)

[做站VPS推荐](https://v2raytech.com/vps-for-website/)

[搬瓦工购买服务器详细教程](https://v2raytech.com/bandwagonghost-buy-vps-tutorial/)

[购买vultr服务器超详细图文教程](https://v2raytech.com/vultr-buy-vps-tutorial/)

[DMIT服务器购买和使用教程](https://v2raytech.com/dmit-vps-tutorial/)

[性价比最高的香港服务器](https://v2raytech.com/best-hongkong-vps/)

[HostDare购买服务器超详细教程](https://v2raytech.com/hostdare-buy-vps-tutorial/)

[vps ping测试、去程/回程路由跟踪、vps一键测试脚本](https://v2raytech.com/benchmark-your-vps/)

[IP、域名、DNS和VPS之间的关系](https://v2raytech.com/ip-vps-domain-relations/)

[为什么回程路由比去程路由重要？](https://v2raytech.com/why-return-route-important/)

[CloudCone CN2 GIA套餐开售了，趁还没超售可买来香一把](https://v2raytech.com/cloudcone-cn2-gia-plans-on-sale/)

[Bitvise连接Linux服务器教程](https://v2raytech.com/bitvise-connect-linux-server-tutorial/)

[Mac电脑连接Linux教程](https://v2raytech.com/mac-connect-to-linux-tutorial/)

[vultr常见问题](https://v2raytech.com/vultr-faq/)

[v2ray使用cloudflare中转流量，拯救被墙ip](https://v2raytech.com/use-cloudflare-unlock-blocked-ip/)

[CloudCone特价VPS促销，就在今天！](https://v2raytech.com/cloudcone-special-vps-offers/)

[购买VPS的建议](https://v2raytech.com/buy-vps-tips/)

[使用NAT VPS中转加速](https://v2raytech.com/use-nat-vps-forward-traffic/)

[frp内网穿透教程](https://v2raytech.com/frp-nat-tunnel-tutorial/)

[流畅看1080p、2k、4k视频需要多大带宽？](https://v2raytech.com/1080p-2k-4k-video-bandwidth-requirement/)

[阿里云卸载云盾/安骑士](https://v2raytech.com/uninstall-aliyun-dun/)

[腾讯云监控软件一键卸载脚本](https://v2raytech.com/uninstall-tencent-cloud-monitors/)

[致富经：每天1000+京豆，京东薅羊毛全攻略（星推官、红包、游戏、签到等）](https://v2raytech.com/jd-script-to-get-rich/)

# Just My Socks

[Just My Socks购买和使用教程](https://v2raytech.com/just-my-socks-buy-and-use-tutorial/)

[Just My Socks Windows配置教程](https://v2raytech.com/just-my-socks-windows-config-tutorial/)

[Just My Socks安卓配置教程](https://v2raytech.com/just-my-socks-android-config-tutorial/)

[Just My Socks iOS配置教程](https://v2raytech.com/just-my-socks-ios-config-tutorial/)

[Just My Socks苹果配置教程](https://v2raytech.com/just-my-socks-mac-config-tutorial/)

[Clash for Windows配置Just My Socks教程](https://v2raytech.com/clash-for-windows-config-just-my-socks-tutorial/)

[ClashX配置Just My Socks教程](https://v2raytech.com/clashx-config-just-my-socks-tutorial/)

[Clash for Android配置Just My Socks教程](https://v2raytech.com/clash-for-android-config-just-my-socks-tutorial/)

[深入理解Clash配置文件](https://v2raytech.com/deep-in-clash-config-file/)

# 其他

[境外apple id信息汇总](https://v2raytech.com/external-apple-id-summary/)

[切换apple id下载其它国家和地区的应用](https://v2raytech.com/switch-appleid-to-download-app/)

[Namesilo购买域名详细教程](https://v2raytech.com/namesilo-buy-domain-tutorial/)

[免费vpn有风险，请慎用](https://v2raytech.com/be-careful-when-use-free-vpn/)

[对机场/vpn的看法](https://v2raytech.com/opinion-on-vpn-service/)

[Telegram新手指南和使用教程](https://v2raytech.com/telegram-tutorial/)

[别太把自己当回事](https://v2raytech.com/do-not-treat-yourself-important/)

[那些年跑路的机场](https://v2raytech.com/proxy-service-suspended-unexpected/)

[科学上网常见问题](https://v2raytech.com/vpn-faq/)

[PC端科学上网常见问题](https://v2raytech.com/pc-vpn-problem-faq/)

[通过国内服务器转发流量](https://v2raytech.com/forward-traffic-via-internal-vps/)

[该选用哪种加密算法？](https://v2raytech.com/choose-crypto-method/)

[添加ipv6支持](https://v2raytech.com/add-ipv6-support/)

[不建议开启tcp fast open功能](https://v2raytech.com/donot-use-tcp-fast-open/)

[安装魔改BBR/BBR Plus/锐速(Lotserver)](https://v2raytech.com/install-bbr-plus-lotserver/)

[配置Telegram走SS/SSR/V2ray/trojan代理](https://v2raytech.com/pc-config-telegram-use-proxy/)

[WordPress插件推荐及性能优化建议](https://v2raytech.com/wordpress-plugin-recommand-and-mentions/)

[Google Scholar/谷歌学术403: your client does not have permission to get URL或者we’re sorry的解决办法](https://v2raytech.com/google-scholar-403-error-solution/)
