#！/bin/bash
# v2ray一键安装脚本
#作者：hijk<https://hijk.art>


RED= " \033[31m "       #错误信息
GREEN= " \033[32m "     #成功信息
YELLOW= " \033[33m "    #警告信息
BLUE= " \033[36m "      #信息信息
普通 = ' \033[0m '

#以下网站是随机从谷歌上找到的无广告小说网站，不喜欢请改成其他网址，以http或https开头
#搭建好后无法打开假冒网站，可能是反代网站挂了，请在网站留言，或者Github发问题，以便更换新的网站
站点=（
http://www.zhuzishu.com/
http://xs.56dyc.com/
# http://www.xiaoshuosk.com/
# https://www.quledu.net/
http://www.ddxsku.com/
http://www.biqu6.com/
https://www.wenshulou.cc/
# http://www.auutea.com/
http://www.55shuba.com/
http://www.39shubao.com/
https://www.23xsw.cc/
https://www.huanbige.com/
https://www.jueshitangmen.info/
https://www.zhetian.org/
http://www.bequgexs.com/
http://www.tjwl.com/
)

CONFIG_FILE= “/ etc/v2ray/config.json ”
SERVICE_FILE = " /etc/systemd/system/v2ray.service "
OS= ` hostnamectl | grep -i 系统| cut -d: -f2 `

V6_PROXY= " "
IP= ` curl -sL -4 ip.sb `
如果[[ “ $? ”  !=  “ 0 ” ]] ;  然后
    IP= ` curl -sL -6 ip.sb `
    V6_PROXY= " https://gh.​​hijk.art/ "
菲

BT= “假”
NGINX_CONF_PATH= “/ etc/nginx/conf.d/ ”
res= ` which bt 2> /dev/null `
如果[[ “ $res ” ！=  “ ” ]] ； 然后
    BT= “真”
    NGINX_CONF_PATH= “ /www/server/panel/vhost/nginx/ ”
菲

VLESS= “假”
木马= “假”
TLS = "假"
WS= “假”
XTLS= “假”
KCP= “假”

检查系统（）{
    结果= $( id | awk ' {print $1} ' )
    if [[ $result  !=  " uid=0(root) " ]] ;  然后
        colorEcho $RED  "请以root身份执行该脚本"
        出口1
    菲

    res= ` which yum 2> /dev/null `
    如果[[ “ $? ”  !=  “ 0 ” ]] ;  然后
        res= ` which apt 2> /dev/null `
        如果[[ “ $? ”  !=  “ 0 ” ]] ;  然后
            colorEcho $RED  "不受支持的 Linux 系统"
            出口1
        菲
        PMT= “适合”
        CMD_INSTALL = " apt install -y "
        CMD_REMOVE= " apt remove -y "
        CMD_UPGRADE= " apt update; apt upgrade -y; apt autoremove -y "
    别的
        PMT= “嗯”
        CMD_INSTALL= " yum install -y "
        CMD_REMOVE= " yum remove -y "
        CMD_UPGRADE= " yum update -y "
    菲
    res= ` which systemctl 2> /dev/null `
    如果[[ “ $? ”  !=  “ 0 ” ]] ;  然后
        colorEcho $RED  "系统版本过低，请升级到最新版本"
        出口1
    菲
}

颜色回声（）{
    echo -e " ${1}${ @: 2}${PLAIN} "
}

configNeedNginx () {
    本地ws= ` grep wsSettings $CONFIG_FILE `
    如果[[ -z  " $ws " ]] ;  然后
        回声没有
        返回
    菲
    回声是的
}

需要Nginx（）{
    如果[[ “ $WS ”  =  “假” ]] ； 然后
        回声没有
        返回
    菲
    回声是的
}

状态（）{
    如果[[ !  -f /usr/bin/v2ray/v2ray ]] ;  然后
        回声0
        返回
    菲
    如果[[ !  -f  $CONFIG_FILE ]] ;  然后
        回声1
        返回
    菲
    port= ` grep port $CONFIG_FILE | 头-n 1 | 剪切 -d: -f2 | tr -d \" , '  ' `
    res= ` ss -nutlp | grep ${port}  | grep -i v2ray `
    如果[[ -z  " $res " ]] ;  然后
        回声2
        返回
    菲

    如果[ ` configNeedNginx `  =！  “是” ]] ;  然后
        回声3
    别的
        res= ` ss -nutlp | grep -i nginx `
        如果[[ -z  " $res " ]] ;  然后
            回声4
        别的
            回声5
        菲
    菲
}

状态文本（）{
    res= `状态`
    案例 $res  in
        2)
            echo -e ${GREEN}已安装${PLAIN}  ${RED}未运行${PLAIN}
            ;;
        3)
            echo -e ${GREEN}已安装${PLAIN}  ${GREEN} V2ray正在运行${PLAIN}
            ;;
        4)
            echo -e ${GREEN}已安装${PLAIN}  ${GREEN} V2ray正在运行${PLAIN} , ${RED} Nginx未运行${PLAIN}
            ;;
        5)
            echo -e ${GREEN}已安装${PLAIN}  ${GREEN} V2ray正在运行，Nginx正在运行${PLAIN}
            ;;
        * )
            echo -e ${RED}未安装${PLAIN}
            ;;
    esac
}

规范化版本（）{
    如果[ -n  " $1 " ] ;  然后
        案例 “ $1 ” 在
            v * )
                回声 “ $1 ”
            ;;
            * )
                回声 “ v $ 1 ”
            ;;
        esac
    别的
        回声 “ ”
    菲
}

# 1：新的 V2Ray。0：没有。1：是的。2：未安装。3：检查失败。
获取版本（）{
    VER= " $( /usr/bin/v2ray/v2ray -version 2> /dev/null ) "
    返回值 = $?
    CUR_VER= " $( normalizeVersion " $( echo " $VER "  | head -n 1 | cut -d "  " -f2 ) " ) "
    TAG_URL= " ${V6_PROXY} https://api.github.com/repos/v2fly/v2ray-core/releases/latest "
    NEW_VER= " $( normalizeVersion " $( curl -s " ${TAG_URL} " --connect-timeout 10 | tr ' , '  ' \n '  | grep ' tag_name '  | cut -d \" -f4 ) " ) "
    if [[ " $XTLS "  =  " true " ]] ;  然后
        NEW_VER=v4.32.1
    菲

    如果[[ $?  -ne 0 ]] || [[ $NEW_VER  ==  " " ]] ;  然后
        colorEcho $RED  "检查V2ray版本信息失败，请检查网络"
        返回3
    elif [[ $RETVAL  -ne 0 ]] ; 然后
        返回2
    elif [[ $NEW_VER  !=  $CUR_VER ]] ; 然后
        返回1
    菲
    返回0
}

词缀(){
    案例 “ $( uname -m ) ” 中
        i686|i386)
            回声 ' 32 '
        ;;
        x86_64|amd64)
            回声 ' 64 '
        ;;
        * armv7 * )
            回声 ' arm32-v7a '
            ;;
        armv6 * )
            回声 ' arm32-v6a '
        ;;
        * armv8 * |aarch64)
            回声 ' arm64-v8a '
        ;;
        * mips64le * )
            回声 ' mips64le '
        ;;
        * mips64 * )
            回声 ' mips64 '
        ;;
        * mipsle * )
            回声 ' mipsle '
        ;;
        *米普* )
            回声 ' mips '
        ;;
        * s390x * )
            回声 ' s390x '
        ;;
        ppc64le)
            回声 ' ppc64le '
        ;;
        ppc64)
            回声 ' ppc64 '
        ;;
        * )
            colorEcho $RED  "不支持的 CPU 系统！"
            出口1
        ;;
    esac

	返回0
}

获取数据（）{
    if [[ " $TLS "  =  " true "  ||  " $XTLS "  =  " true " ]] ;  然后
        回声 “ ”
        echo  " V2ray一键脚本，运行之前请确认以下条件已经具备："
        colorEcho ${YELLOW}  "   1. 一个伪装域名"
        colorEcho ${YELLOW}  "   2.伪装域名DNS解析桌面当前服务器ip（${IP}}）"
        colorEcho ${BLUE}  "   3. 如果/root目录下有 v2ray.pem 和 v2ray.key 证书密钥文件，不需要理会条件 2 "
        回声 “  ”
        read -p "确认满足按y，按其他退出剧本：" answer
        if [[ " ${answer,,} "  !=  " y " ]] ;  然后
            退出0
        菲

        回声 “ ”
        虽然是 真的
        做
            read -p "请输入伪装域名：" DOMAIN
            if [[ -z  " ${DOMAIN} " ]] ;  然后
                colorEcho ${RED}  "域名输入错误，请重输入！"
            别的
                休息
            菲
        完毕
        域= ${域,,}
        colorEcho ${BLUE}   "伪装域名(host)：$DOMAIN "

        if [[ -f  ~ /v2ray.pem &&  -f  ~ /v2ray.key ]] ;  然后
            colorEcho ${BLUE}   "检测到自有证书，将使用其部署"
            CERT_FILE = " /etc/v2ray/ ${DOMAIN} .pem "
            KEY_FILE= " /etc/v2ray/ ${DOMAIN} .key "
        别的
            resolve= ` curl -sL https://hijk.art/hostip.php ？d= ${域} `
            res= ` echo -n ${resolve}  | grep ${IP} `
            如果[[ -z  " ${res} " ]] ;  然后
                colorEcho ${BLUE}   " ${DOMAIN}解析结果：${resolve} "
                colorEcho ${RED}   "域名未解析到当前服务器IP( ${IP} )！"
                出口1
            菲
        菲
    菲

    回声 “ ”
    if [[ " $( needNginx ) "  =  " no " ]] ;  然后
        if [[ “ $TLS ”  =  “真” ]] ； 然后
            read -p "请输入v2ray监听端口[强烈建议443，默认443]：" PORT
            [[ -z  " ${PORT} " ]] && PORT=443
        别的
            read -p "请输入v2ray监听端口[100-6535的一个数字]：" PORT
            [[ -z  " ${PORT} " ]] && PORT= ` shuf -i200-65000 -n1 `
            if [[ " ${PORT : 0 : 1} "  =  " 0 " ]] ;  然后
                colorEcho ${RED}   "端口不能以0开头"
                出口1
            菲
        菲
        colorEcho ${BLUE}   " v2ray端口：$PORT "
    别的
        read -p "请输入Nginx监听端口[100-65535的一个数字，默认443]：" PORT
        [[ -z  " ${PORT} " ]] && PORT=443
        if [ " ${PORT : 0 : 1} "  =  " 0 " ] ;  然后
            colorEcho ${BLUE}   “端口不能以0开头”
            出口1
        菲
        colorEcho ${BLUE}   " Nginx 端口：$PORT "
        V2PORT= ` shuf -i10000-65000 -n1 `
    菲

    if [[ “ $KCP ”  =  “真” ]] ； 然后
        回声 “ ”
        colorEcho $BLUE  "请选择伪装类型："
        回声 “    1）无”
        echo  "    2) BT下载"
        echo  "    3) 视频通话"
        echo  "    4) 微信视频通话"
        回声 “    5）dtls ”
        回声 “    6）wiregard ”
        read -p "  请选择伪装类型[默认：无]：" answer
        案例 $answer  in
            2)
                HEADER_TYPE = " utp "
                ;;
            3)
                HEADER_TYPE= “ srtp ”
                ;;
            4)
                HEADER_TYPE= "微信视频"
                ;;
            5)
                HEADER_TYPE= “ dtls ”
                ;;
            6)
                HEADER_TYPE= “线卫”
                ;;
            * )
                HEADER_TYPE= "无"
                ;;
        esac
        colorEcho $BLUE  "伪装类型：$HEADER_TYPE "
        SEED= ` cat /proc/sys/kernel/random/uuid `
    菲

    if [[ " $TROJAN "  =  " true " ]] ;  然后
        回声 “ ”
        read -p "请设置木马密码（不输则随机生成）：" PASSWORD
        [[ -z  " $PASSWORD " ]] && PASSWORD= ` cat /dev/urandom | tr -dc ' a-zA-Z0-9 '  | 折叠 -w 16 | 头-n 1`
        colorEcho $BLUE  "木马密码：$PASSWORD "
    菲

    if [[ " $XTLS "  =  " true " ]] ;  然后
        回声 “ ”
        colorEcho $BLUE  "请选择流控模式：" 
        echo -e "    1) xtls-rprx-direct [ $RED推荐$PLAIN ] "
        回声 “    2）xtls-rprx-origin ”
        read -p "  请选择流控模式[默认:direct] " answer
        [[ -z  " $answer " ]] && answer=1
        案例 $answer  in
            1)
                FLOW= " xtls-rprx-direct "
                ;;
            2)
                FLOW= " xtls-rprx-origin "
                ;;
            * )
                colorEcho $RED  "输入选项，默认的xtls-rprx-direct "
                FLOW= " xtls-rprx-direct "
                ;;
        esac
        colorEcho $BLUE  "流控模式：$FLOW "
    菲

    if [[ " ${WS} "  =  " true " ]] ;  然后
        回声 “ ”
        虽然是 真的
        做
            read -p "请输入伪装路径，以/开头(不懂请直接回车)：" WSPATH
            if [[ -z  " ${WSPATH} " ]] ;  然后
                len= ` shuf -i5-12 -n1 `
                ws= ` cat /dev/urandom | tr -dc ' a-zA-Z0-9 '  | 折叠 -w $len  | 头-n 1`
                WSPATH= " / $ws "
                休息
            elif [[ " ${WSPATH : 0 : 1} "  !=  " / " ]] ;  然后
                colorEcho ${RED}   "伪装路径必须以/开始！"
            elif [[ " ${WSPATH} "  =  " / " ]] ;  然后
                colorEcho ${RED}    "不能使用根路径！"
            别的
                休息
            菲
        完毕
        colorEcho ${BLUE}   " ws 路径：$WSPATH "
    菲

    if [[ " $TLS "  =  " true "  ||  " $XTLS "  =  " true " ]] ;  然后
        回声 “ ”
        colorEcho $BLUE  "请选择伪装站类型："
        echo  "    1) 网站(位于/usr/share/nginx/html) "
        echo  "    2) 小说站(随机选择) "
        echo  "    3) 美女站(https://imeizi.me) "
        echo  "    4) 高清壁纸站(https://bing.imeizi.me) "
        echo  "    5) 自定义反代站点(需以http或者https开头) "
        read -p "  请选择伪装网站类型[默认：高清壁纸站] " answer
        如果[[ -z  " $answer " ]] ;  然后
            PROXY_URL = " https://bing.imeizi.me "
        别的
            案例 $answer  in
            1)
                PROXY_URL = " "
                ;;
            2)
                len= ${ # SITES[@]}
                (( len -- ))
                虽然是 真的
                做
                    索引= ` shuf -i0- ${len} -n1 `
                    PROXY_URL= ${SITES[$index]}
                    host= ` echo ${PROXY_URL}  | cut -d/ -f3 `
                    ip= ` curl -sL https://hijk.art/hostip.php ？d= ${host} `
                    res= ` echo -n ${ip}  | grep ${host} `
                    如果[[ " ${res} "  =  " " ]] ;  然后
                        echo  " $ip  $host "  >> /etc/hosts
                        休息
                    菲
                完毕
                ;;
            3)
                PROXY_URL = " https://imeizi.me "
                ;;
            4)
                PROXY_URL = " https://bing.imeizi.me "
                ;;
            5)
                read -p "请输入反代站点(以http或者https开头)：" PROXY_URL
                if [[ -z  " $PROXY_URL " ]] ;  然后
                    colorEcho $RED  "请输入反代网站！"
                    出口1
                elif [[ " ${PROXY_URL : 0 : 4} "  !=  " http " ]] ;  然后
                    colorEcho $RED  "反代网站必须以http或https开头！"
                    出口1
                菲
                ;;
            * )
                colorEcho $RED  "请输入正确的选项！"
                出口1
            esac
        菲
        REMOTE_HOST= ` echo ${PROXY_URL}  | cut -d/ -f3 `
        colorEcho $BLUE  "伪装网站：$PROXY_URL "

        回声 “ ”
        colorEcho $BLUE  "  是否允许搜索爬取网站？[默认引擎：禁止] "
        echo  "     y)允许，会有更多ip请求网站，但会消耗一些流量，vps流量必要情况下推荐使用"
        echo  "     n) 拒绝，爬不会访问网站，访问 ip 比较个体，但能节省vps "
        read -p "  请选择：[y/n] " answer
        如果[[ -z  " $answer " ]] ;  然后
            ALLOW_SPIDER= " n "
        elif [[ " ${answer,,} "  =  " y " ]] ;  然后
            ALLOW_SPIDER = " y "
        别的
            ALLOW_SPIDER= " n "
        菲
        colorEcho $BLUE  "允许搜索引擎：$ALLOW_SPIDER "
    菲

    回声 “ ”
    read -p "是否安装 BBR(默认安装)?[y/n]: " NEED_BBR
    [[ -z  " $NEED_BBR " ]] && NEED_BBR=y
    [[ " $NEED_BBR "  =  " Y " ]] && NEED_BBR=y
    colorEcho $BLUE  "安装 BBR：$NEED_BBR "
}

安装Nginx（）{
    回声 “ ”
    colorEcho $BLUE  "安装nginx... "
    如果[[ “ $BT ”  =  “假” ]] ； 然后
        if [[ " $PMT "  =  " yum " ]] ;  然后
            $CMD_INSTALL epel-release
            如果[[ “ $? ”  !=  “ 0 ” ]] ;  然后
                echo  ' [nginx 稳定]
名称=nginx 稳定存储库
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
启用=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true '  > /etc/yum.repos.d/nginx.repo
            菲
        菲
        $CMD_INSTALL nginx
        如果[[ “ $? ”  !=  “ 0 ” ]] ;  然后
            colorEcho $RED  " Nginx 安装失败，请到 https://hijk.art 反馈"
            出口1
        菲
        systemctl启用nginx
    别的
        res= ` which nginx 2> /dev/null `
        如果[[ “ $? ”  !=  “ 0 ” ]] ;  然后
            colorEcho $RED  "您安装了宝塔，请在宝塔后台安装nginx再运行本脚本"
            出口1
        菲
    菲
}

启动Nginx（）{
    如果[[ “ $BT ”  =  “假” ]] ； 然后
        systemctl 启动 nginx
    别的
        nginx -c /www/server/nginx/conf/nginx.conf
    菲
}

停止Nginx（）{
    如果[[ “ $BT ”  =  “假” ]] ； 然后
        systemctl 停止 nginx
    别的
        res= ` ps 辅助| grep -i nginx `
        如果[[ “ $res ” ！=  “ ” ]] ； 然后
            nginx -s 停止
        菲
    菲
}

获取证书（）{
    mkdir -p /etc/v2ray
    if [[ -z  ${CERT_FILE+x} ]] ;  然后
        停止Nginx
        睡觉 2
        res= ` netstat -ntlp | grep -E ' :80 |:443 ' `
        如果[[ " ${res} "  !=  " " ]] ;  然后
            colorEcho ${RED}   "其他进程占用了80或443端口，请先关闭再运行一键脚本"
            echo  "端口占用信息如下："
            回声 ${res}
            出口1
        菲

        $CMD_INSTALL socat openssl
        if [[ " $PMT "  =  " yum " ]] ;  然后
            $CMD_INSTALL密友
            systemctl 启动 crond
            systemctl启用crond
        别的
            $CMD_INSTALL cron
            systemctl 启动 cron
            systemctl启用cron
        菲
        curl -sL https://get.acme.sh | sh -s email=hijk.pw@protonmail.ch
        源 ~ /.bashrc
        ~ /.acme.sh/acme.sh --upgrade --auto-upgrade
        ~ /.acme.sh/acme.sh --set-default-ca --serverletsencrypt
        如果[[ “ $BT ”  =  “假” ]] ； 然后
            ~ /.acme.sh/acme.sh --issue -d $DOMAIN --keylength ec-256 --pre-hook " systemctl stop nginx " --post-hook " systemctl restart nginx "   --standalone
        别的
            ~ /.acme.sh/acme.sh --issue -d $DOMAIN --keylength ec-256 --pre-hook " nginx -s stop || { echo -n ''; } " --post-hook " nginx -c /www/server/nginx/conf/nginx.conf || { echo -n ''; } "   --standalone
        菲
        [[ -f  ~ /.acme.sh/ ${DOMAIN} _ecc/ca.cer ]] || {
            colorEcho $RED  "获取证书失败，请复制上面的红色文字到 https://hijk.art 反馈"
            出口1
        }
        CERT_FILE = " /etc/v2ray/ ${DOMAIN} .pem "
        KEY_FILE= " /etc/v2ray/ ${DOMAIN} .key "
        ~ /.acme.sh/acme.sh --install-cert -d $DOMAIN --ecc \
            --key-file        $KEY_FILE   \
            --fullchain-file $CERT_FILE \
            --reloadcmd      "服务 nginx 强制重新加载"
        [[ -f  $CERT_FILE  &&  -f  $KEY_FILE ]] || {
            colorEcho $RED  "获取证书失败，请到 https://hijk.art 反馈"
            出口1
        }
    别的
        cp ~ /v2ray.pem /etc/v2ray/ ${DOMAIN} .pem
        cp ~ /v2ray.key /etc/v2ray/ ${DOMAIN} .key
    菲
}

配置Nginx（）{
    mkdir -p /usr/share/nginx/html ;
    if [[ " $ALLOW_SPIDER "  =  " n " ]] ;  然后
        echo  '用户代理：* '  > /usr/share/nginx/html/robots.txt
        echo  '禁止：/ '  >> /usr/share/nginx/html/robots.txt
        ROBOT_CONFIG= “    位置=/ robots.txt {} ”
    别的
        ROBOT_CONFIG= " "
    菲

    如果[[ “ $BT ”  =  “假” ]] ； 然后
        如果[[ !  -f /etc/nginx/nginx.conf.bak ]] ;  然后
            mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
        菲
        res= ` id nginx 2> /dev/null `
        如果[[ “ $? ”  !=  “ 0 ” ]] ;  然后
            用户= " www-data "
        别的
            用户= “ nginx ”
        菲
        cat > /etc/nginx/nginx.conf << - EOF
用户 $user;
worker_processes 自动；
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# 加载动态模块。请参阅 /usr/share/doc/nginx/README.dynamic。
包括/usr/share/nginx/modules/*.conf;

事件{
    worker_connections 1024;
}

http {
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
		      
    access_log /var/log/nginx/access.log main;
    server_tokens 关闭；
    
    发送文件；
    tcp_nopush 开启；
    tcp_nodelay 开启；
    keepalive_timeout 65;
    types_hash_max_size 2048;
    gzip 上；
    
    包括 /etc/nginx/mime.types;
    default_type 应用程序/八位字节流；
    
    # 从 /etc/nginx/conf.d 目录加载模块化配置文件。
    # 见 http://nginx.org/en/docs/ngx_core_module.html#include
    ＃ 想要查询更多的信息。
    包括/etc/nginx/conf.d/*.conf;
}
EOF
    菲

    if [[ " $PROXY_URL "  =  " " ]] ;  然后
        动作= “ ”
    别的
        action= " proxy_ssl_server_name on;
        proxy_pass $PROXY_URL ;
        proxy_set_header Accept-Encoding '';
        sub_filter \" $REMOTE_HOST \"  \" $DOMAIN \" ;
        sub_filter_once 关闭；”
    菲

    if [[ " $TLS "  =  " true "  ||  " $XTLS "  =  " true " ]] ;  然后
        mkdir -p $NGINX_CONF_PATH
        # VMESS+WS+TLS
        # VLESS+WS+TLS
        如果[[ “ $WS ”  =  “真” ]] ； 然后
            cat >  ${NGINX_CONF_PATH}${DOMAIN} .conf << - EOF
服务器 {
    听80；
    听 [::]:80;
    server_name ${DOMAIN};
    返回 301 https://\$server_name:${PORT}\$request_uri;
}

服务器 {
    听 ${PORT} ssl http2;
    听 [::]:${PORT} ssl http2;
    server_name ${DOMAIN};
    字符集 utf-8；
    
    #ssl配置
    ssl_protocols TLSv1.1 TLSv1.2；
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_ecdh_curve secp384r1；
    ssl_prefer_server_ciphers 开启；
    ssl_session_cache 共享：SSL：10m；
    ssl_session_timeout 10m;
    ssl_session_tickets 关闭；
    ssl_certificate $CERT_FILE;
    ssl_certificate_key $KEY_FILE;
    
    根目录 /usr/share/nginx/html;
    地点 / {
        $动作
    }
    $ROBOT_CONFIG
    
    位置 ${WSPATH} {
      proxy_redirect 关闭；
      proxy_pass http://127.0.0.1:${V2PORT};
      proxy_http_version 1.1;
      proxy_set_header 升级 \$http_upgrade;
      proxy_set_header 连接“升级”；
      proxy_set_header 主机 \$host;
      # 在 v2ray access.log 中显示真实 IP
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
        别的
            # VLESS+TCP+TLS
            # VLESS+TCP+XTLS
            #木马
            cat >  ${NGINX_CONF_PATH}${DOMAIN} .conf << - EOF
服务器 {
    听80；
    听 [::]:80;
    听 81 http2;
    server_name ${DOMAIN};
    根目录 /usr/share/nginx/html;
    地点 / {
        $动作
    }
    $ROBOT_CONFIG
}
EOF
        菲
    菲
}

setSelinux (){
    if [[ -s /etc/selinux/config ]] && grep ' SELINUX=enforcing ' /etc/selinux/config ;  然后
        sed -i ' s/SELINUX=enforcing/SELINUX=permissive/g ' /etc/selinux/config
        设置强制 0
    菲
}

设置防火墙（）{
    res= ` which firewall-cmd 2> /dev/null `
    如果[[ $?  -eq 0 ]] ;  然后
        systemctl status firewalld > /dev/null 2>&1
        如果[[ $?  -eq 0 ]] ; 然后
            firewall-cmd --permanent --add-service=http
            firewall-cmd --permanent --add-service=https
            if [[ “ $PORT ” ！=  “ 443 ” ]] ； 然后
                firewall-cmd --permanent --add-port= ${PORT} /tcp
                firewall-cmd --permanent --add-port= ${PORT} /udp
            菲
            防火墙-cmd --reload
        别的
            nl= ` iptables -nL | nl | grep 前进| awk ' {打印 $1} ' `
            如果[[ “ $nl ” ！=  “ 3 ” ]] ； 然后
                iptables -I 输入 -p tcp --dport 80 -j 接受
                iptables -I 输入 -p tcp --dport 443 -j 接受
                if [[ “ $PORT ” ！=  “ 443 ” ]] ； 然后
                    iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
                    iptables -I INPUT -p udp --dport ${PORT} -j ACCEPT
                菲
            菲
        菲
    别的
        res= ` which iptables 2> /dev/null `
        如果[[ $?  -eq 0 ]] ;  然后
            nl= ` iptables -nL | nl | grep 前进| awk ' {打印 $1} ' `
            如果[[ “ $nl ” ！=  “ 3 ” ]] ； 然后
                iptables -I 输入 -p tcp --dport 80 -j 接受
                iptables -I 输入 -p tcp --dport 443 -j 接受
                if [[ “ $PORT ” ！=  “ 443 ” ]] ； 然后
                    iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
                    iptables -I INPUT -p udp --dport ${PORT} -j ACCEPT
                菲
            菲
        别的
            res= ` which ufw 2> /dev/null `
            如果[[ $?  -eq 0 ]] ;  然后
                res= ` ufw 状态| grep -i 不活动`
                如果[[ “ $res ”  =  “ ” ]] ； 然后
                    ufw 允许 http/tcp
                    ufw 允许 https/tcp
                    if [[ “ $PORT ” ！=  “ 443 ” ]] ； 然后
                        ufw 允许${PORT} /tcp
                        ufw 允许${PORT} /udp
                    菲
                菲
            菲
        菲
    菲
}

安装BBR（）{
    if [[ " $NEED_BBR "  !=  " y " ]] ;  然后
        INSTALL_BBR=假
        返回
    菲
    结果= $( lsmod | grep bbr )
    如果[[ " $result "  !=  " " ]] ;  然后
        colorEcho $BLUE  " BBR 模块已安装"
        INSTALL_BBR=假
        返回
    菲
    res= ` hostnamectl | grep -i openvz `
    如果[[ “ $res ” ！=  “ ” ]] ； 然后
        colorEcho $BLUE  " openvz机器，跳过安装"
        INSTALL_BBR=假
        返回
    菲
    
    echo  " net.core.default_qdisc=fq "  >> /etc/sysctl.conf
    回声 “ net.ipv4.tcp_congestion_control=bbr ”  >> /etc/sysctl.conf
    sysctl -p
    结果= $( lsmod | grep bbr )
    如果[[ " $result "  !=  " " ]] ;  然后
        colorEcho $GREEN  " BBR 模块已启用"
        INSTALL_BBR=假
        返回
    菲

    colorEcho $BLUE  "安装BBR模块... "
    if [[ " $PMT "  =  " yum " ]] ;  然后
        if [[ " $V6_PROXY "  =  " " ]] ;  然后
            rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
            rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
            $CMD_INSTALL --enablerepo=elrepo-kernel kernel-ml
            $CMD_REMOVE kernel-3。*
            grub2-set-default 0
            回声 “ tcp_bbr ”  >> /etc/modules-load.d/modules.conf
            INSTALL_BBR=真
        菲
    别的
        $CMD_INSTALL --install-recommends linux-generic-hwe-16.04
        grub-set-default 0
        回声 “ tcp_bbr ”  >> /etc/modules-load.d/modules.conf
        INSTALL_BBR=真
    菲
}

安装V2ray（）{
    rm -rf /tmp/v2ray
    mkdir -p /tmp/v2ray
    DOWNLOAD_LINK= " ${V6_PROXY} https://github.com/v2fly/v2ray-core/releases/download/ ${NEW_VER} /v2ray-linux- $( archAffix ) .zip "
    colorEcho $BLUE  "下载 V2Ray: ${DOWNLOAD_LINK} "
    curl -L -H "缓存控制：无缓存" -o /tmp/v2ray/v2ray.zip ${DOWNLOAD_LINK}
    如果[ $?  != 0 ] ; 然后
        colorEcho $RED  "下载V2ray文件失败，请检查服务器网络设置"
        出口1
    菲
    mkdir -p ' /etc/v2ray '  ' /var/log/v2ray '  && \
    解压/tmp/v2ray/v2ray.zip -d /tmp/v2ray
    mkdir -p /usr/bin/v2ray
    cp /tmp/v2ray/v2ctl /usr/bin/v2ray/ ; cp /tmp/v2ray/v2ray /usr/bin/v2ray/ ; cp /tmp/v2ray/geo * /usr/bin/v2ray/ ;
    chmod +x ' /usr/bin/v2ray/v2ray '  ' /usr/bin/v2ray/v2ctl '  || {
        colorEcho $RED  " V2ray 安装失败"
        出口1
    }

    猫> $SERVICE_FILE << - EOF
[单元]
说明=V2ray服务
文档=https://hijk.art
After=network.target nss-lookup.target

[服务]
# 如果systemd版本为240以上，则取消Type=exec的注释并注释掉Type=simple
#类型=执行
类型=简单
# 此服务以 root 身份运行。出于安全考虑，您可以考虑以其他用户身份运行它。
# 通过取消注释 User=nobody 并注释掉 User=root，服务将以用户 nobody 运行。
# 更多讨论见 https://github.com/v2ray/v2ray-core/issues/1011
用户=root
#用户=没人
NoNewPrivileges=true
ExecStart=/usr/bin/v2ray/v2ray -config /etc/v2ray/config.json
重启=失败

[安装]
WantedBy=multi-user.target
EOF
    systemctl 守护进程重新加载
    systemctl enable v2ray.service
}

木马配置（）{
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$ PORT，
    “协议”：“特洛伊木马”，
    “设置”：{
      “客户”：[
        {
          “密码”：“$密码”
        }
      ],
      “后备”：[
        {
              "alpn": "http/1.1",
              “目标”：80
          },
          {
              "alpn": "h2",
              “目标”：81
          }
      ]
    },
    “流设置”：{
        "网络": "tcp",
        "security": "tls",
        “tls设置”：{
            "serverName": "$DOMAIN",
            "alpn": ["http/1.1", "h2"],
            “证书”：[
                {
                    "证书文件": "$CERT_FILE",
                    "keyFile": "$KEY_FILE"
                }
            ]
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

木马XTLSConfig (){
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$ PORT，
    “协议”：“特洛伊木马”，
    “设置”：{
      “客户”：[
        {
          "密码": "$密码",
          “流量”：“$流量”
        }
      ],
      “后备”：[
          {
              "alpn": "http/1.1",
              “目标”：80
          },
          {
              "alpn": "h2",
              “目标”：81
          }
      ]
    },
    “流设置”：{
        "网络": "tcp",
        “安全”：“xtls”，
        “xtls设置”：{
            "serverName": "$DOMAIN",
            "alpn": ["http/1.1", "h2"],
            “证书”：[
                {
                    "证书文件": "$CERT_FILE",
                    "keyFile": "$KEY_FILE"
                }
            ]
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

vmssConfig () {
    本地uuid= " $( cat ' /proc/sys/kernel/random/uuid ' ) "
    本地alterid = ` shuf -i50-80 -n1 `
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$ PORT，
    “协议”：“vmess”，
    “设置”：{
      “客户”：[
        {
          "id": "$uuid",
          “1级，
          "alterId": $alterid
        }
      ]
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

vmessKCPConfig () {
    本地uuid= " $( cat ' /proc/sys/kernel/random/uuid ' ) "
    本地alterid = ` shuf -i50-80 -n1 `
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$ PORT，
    “协议”：“vmess”，
    “设置”：{
      “客户”：[
        {
          "id": "$uuid",
          “1级，
          "alterId": $alterid
        }
      ]
    },
    “流设置”：{
        “网络”：“mkcp”，
        “kcpSettings”：{
            “上行容量”：100，
            “下行容量”：100，
            “拥堵”：真的，
            “标题”：{
                “类型”：“$HEADER_TYPE”
            },
            “种子”：“$SEED”
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

vmessTLSConfig () {
    本地uuid= " $( cat ' /proc/sys/kernel/random/uuid ' ) "
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$ PORT，
    “协议”：“vmess”，
    “设置”：{
      “客户”：[
        {
          "id": "$uuid",
          “1级，
          “alterId”：0
        }
      ],
      “disableInsecureEncryption”：false
    },
    “流设置”：{
        "网络": "tcp",
        "security": "tls",
        “tls设置”：{
            "serverName": "$DOMAIN",
            "alpn": ["http/1.1", "h2"],
            “证书”：[
                {
                    "证书文件": "$CERT_FILE",
                    "keyFile": "$KEY_FILE"
                }
            ]
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

vmessWSConfig () {
    本地uuid= " $( cat ' /proc/sys/kernel/random/uuid ' ) "
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$V2PORT，
    “听”：“127.0.0.1”，
    “协议”：“vmess”，
    “设置”：{
      “客户”：[
        {
          "id": "$uuid",
          “1级，
          “alterId”：0
        }
      ],
      “disableInsecureEncryption”：false
    },
    “流设置”：{
        "网络": "ws",
        “ws设置”：{
            "路径": "$WSPATH",
            “标题”：{
                “主机”：“$DOMAIN”
            }
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

vlessTLSConfig () {
    本地uuid= " $( cat ' /proc/sys/kernel/random/uuid ' ) "
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$ PORT，
    “协议”：“vless”，
    “设置”：{
      “客户”：[
        {
          "id": "$uuid",
          “级别”：0
        }
      ],
      "解密": "无",
      “后备”：[
          {
              "alpn": "http/1.1",
              “目标”：80
          },
          {
              "alpn": "h2",
              “目标”：81
          }
      ]
    },
    “流设置”：{
        "网络": "tcp",
        "security": "tls",
        “tls设置”：{
            "serverName": "$DOMAIN",
            "alpn": ["http/1.1", "h2"],
            “证书”：[
                {
                    "证书文件": "$CERT_FILE",
                    "keyFile": "$KEY_FILE"
                }
            ]
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

vlessXTLSConfig () {
    本地uuid= " $( cat ' /proc/sys/kernel/random/uuid ' ) "
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$ PORT，
    “协议”：“vless”，
    “设置”：{
      “客户”：[
        {
          "id": "$uuid",
          “流量”：“$流量”，
          “级别”：0
        }
      ],
      "解密": "无",
      “后备”：[
          {
              "alpn": "http/1.1",
              “目标”：80
          },
          {
              "alpn": "h2",
              “目标”：81
          }
      ]
    },
    “流设置”：{
        "网络": "tcp",
        “安全”：“xtls”，
        “xtls设置”：{
            "serverName": "$DOMAIN",
            "alpn": ["http/1.1", "h2"],
            “证书”：[
                {
                    "证书文件": "$CERT_FILE",
                    "keyFile": "$KEY_FILE"
                }
            ]
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

vlessWSConfig () {
    本地uuid= " $( cat ' /proc/sys/kernel/random/uuid ' ) "
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$V2PORT，
    “听”：“127.0.0.1”，
    “协议”：“vless”，
    “设置”：{
        “客户”：[
            {
                "id": "$uuid",
                “级别”：0
            }
        ],
        “解密”：“无”
    },
    “流设置”：{
        "网络": "ws",
        "安全": "无",
        “ws设置”：{
            "路径": "$WSPATH",
            “标题”：{
                “主机”：“$DOMAIN”
            }
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

vlessKCPConfig () {
    本地uuid= " $( cat ' /proc/sys/kernel/random/uuid ' ) "
    猫>  $CONFIG_FILE << - EOF
{
  “入站”：[{
    “端口”：$ PORT，
    “协议”：“vless”，
    “设置”：{
      “客户”：[
        {
          "id": "$uuid",
          “级别”：0
        }
      ],
      “解密”：“无”
    },
    “流设置”：{
        “流设置”：{
            “网络”：“mkcp”，
            “kcpSettings”：{
                “上行容量”：100，
                “下行容量”：100，
                “拥堵”：真的，
                “标题”：{
                    “类型”：“$HEADER_TYPE”
                },
                “种子”：“$SEED”
            }
        }
    }
  }],
  “出站”：[{
    "协议": "自由",
    “设置”：{}
  },{
    "协议": "黑洞",
    “设置”：{}，
    “标签”：“阻止”
  }]
}
EOF
}

configV2ray () {
    mkdir -p /etc/v2ray
    if [[ " $TROJAN "  =  " true " ]] ;  然后
        if [[ " $XTLS "  =  " true " ]] ;  然后
            木马XTLS配置
        别的
            木马配置
        菲
        返回0
    菲
    如果[[ “ $VLESS ”  =  “假” ]] ;  然后
        # VMESS + kcp
        if [[ “ $KCP ”  =  “真” ]] ； 然后
            vmssKCPConfig
            返回0
        菲
        #虚拟机
        if [[ “ $TLS ”  =  “假” ]] ； 然后
            虚拟机配置
        elif [[ “ $WS ”  =  “假” ]] ； 然后
            # VMESS+TCP+TLS
            vmssTLS 配置
        # VMESS+WS+TLS
        别的
            虚拟机WSConfig
        菲
    ＃ VLESS
    别的
        if [[ “ $KCP ”  =  “真” ]] ； 然后
            无KCP配置
            返回0
        菲
        # VLESS+TCP
        如果[[ “ $WS ”  =  “假” ]] ； 然后
            # VLESS+TCP+TLS
            if [[ “ $XTLS ”  =  “假” ]] ； 然后
                无TLS配置
            # VLESS+TCP+XTLS
            别的
                vlessXTLSConfig
            菲
        # VLESS+WS+TLS
        别的
            无WSConfig
        菲
    菲
}

安装（）{
    获取数据

    $PMT清除所有
    [[ " $PMT "  =  " apt " ]] &&  $PMT更新
    # echo $CMD_UPGRADE | 猛击
    $CMD_INSTALL wget vim unzip tar gcc openssl
    $CMD_INSTALL网络工具
    if [[ " $PMT "  =  " apt " ]] ;  然后
        $CMD_INSTALL libssl-dev g++
    菲
    res= ` which unzip 2> /dev/null `
    如果[[ $?  -ne 0 ]] ;  然后
        colorEcho $RED  "解压安装失败，请检查网络"
        出口1
    菲

    安装Nginx
    设置防火墙
    if [[ " $TLS "  =  " true "  ||  " $XTLS "  =  " true " ]] ;  然后
        获取证书
    菲
    配置Nginx

    colorEcho $BLUE  "安装V2ray... "
    获取版本
    RETVAL= “ $？”
    如果[[ $RETVAL  == 0 ]] ;  然后
        colorEcho $BLUE  " V2ray最新版${CUR_VER}已经安装"
    elif [[ $RETVAL  == 3 ]] ;  然后
        出口1
    别的
        colorEcho $BLUE  "安装 V2Ray ${NEW_VER}，架构$( archAffix ) "
        安装V2ray
    菲

    configV2ray

    设置Selinux
    安装BBR

    开始
    显示信息

    重启
}

bbr重新启动（）{
    if [[ " ${INSTALL_BBR} "  ==  " true " ]] ;  然后
        回声  
        echo  "为使BBR模块生效，系统将在30秒后重启"
        回声  
        echo -e "您可以 ctrl + c 按取消重启，稍后输入${RED} reboot ${PLAIN}重启系统"
        睡 30
        重启
    菲
}

更新（）{
    res= `状态`
    如果[[ $res  -lt 2 ]] ;  然后
        colorEcho $RED  " V2ray 未安装，请先安装！"
        返回
    菲

    获取版本
    RETVAL= “ $？”
    如果[[ $RETVAL  == 0 ]] ;  然后
        colorEcho $BLUE  " V2ray最新版${CUR_VER}已经安装"
    elif [[ $RETVAL  == 3 ]] ;  然后
        出口1
    别的
        colorEcho $BLUE  "安装 V2Ray ${NEW_VER}，架构$( archAffix ) "
        安装V2ray
        停止
        开始

        colorEcho $GREEN  "最新版V2ray安装成功！"
    菲
}

卸载（）{
    res= `状态`
    如果[[ $res  -lt 2 ]] ;  然后
        colorEcho $RED  " V2ray 未安装，请先安装！"
        返回
    菲

    回声 “ ”
    read -p "确定卸载V2ray？[y/n]：" answer
    if [[ " ${answer,,} "  =  " y " ]] ;  然后
        domain= ` grep 主机$CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
        如果[[ “ $domain ”  =  “ ” ]] ； 然后
            domain= ` grep serverName $CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
        菲
        
        停止
        systemctl 禁用 v2ray
        rm -rf $SERVICE_FILE
        rm -rf /etc/v2ray
        rm -rf /usr/bin/v2ray

        如果[[ “ $BT ”  =  “假” ]] ； 然后
            systemctl 禁用 nginx
            $CMD_REMOVE nginx
            if [[ " $PMT "  =  " apt " ]] ;  然后
                $CMD_REMOVE nginx-common
            菲
            rm -rf /etc/nginx/nginx.conf
            if [[ -f /etc/nginx/nginx.conf.bak ]] ;  然后
                mv /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf
            菲
        菲
        如果[[ “ $domain ”  !=  “ ” ]] ;  然后
            rm -rf $NGINX_CONF_PATH ${domain} .conf
        菲
        [[ -f  ~ /.acme.sh/acme.sh ]] &&  ~ /.acme.sh/acme.sh --uninstall
        colorEcho $GREEN  " V2ray 卸载成功"
    菲
}

开始（）{
    res= `状态`
    如果[[ $res  -lt 2 ]] ;  然后
        colorEcho $RED  " V2ray 未安装，请先安装！"
        返回
    菲
    停止Nginx
    启动Nginx
    systemctl restart v2ray
    睡觉 2
    port= ` grep port $CONFIG_FILE | 头-n 1 | 剪切 -d: -f2 | tr -d \" , '  ' `
    res= ` ss -nutlp | grep ${port}  | grep -i v2ray `
    如果[[ “ $res ”  =  “ ” ]] ； 然后
        colorEcho $RED  " v2ray 启动失败，请检查日志或查看端口是否被占用！"
    别的
        colorEcho $BLUE  " v2ray 启动成功"
    菲
}

停止（）{
    停止Nginx
    systemctl 停止 v2ray
    colorEcho $BLUE  " V2ray停止成功"
}


重新启动（）{
    res= `状态`
    如果[[ $res  -lt 2 ]] ;  然后
        colorEcho $RED  " V2ray 未安装，请先安装！"
        返回
    菲

    停止
    开始
}

获取配置文件信息（）{
    vless= “假”
    tls = "假"
    ws= “假”
    xtls = "假"
    特洛伊木马= “假”
    协议= “ VMess ”
    kcp= “假”

    uid= ` grep id $CONFIG_FILE  | 头-n1 | 剪切 -d: -f2 | tr -d \" , '  ' `
    alterid= ` grep alterId $CONFIG_FILE   | 剪切 -d: -f2 | tr -d \" , '  ' `
    network= ` grep network $CONFIG_FILE   | 尾-n1 | 剪切 -d: -f2 | tr -d \" , '  ' `
    [[ -z  " $network " ]] && network= " tcp "
    domain= ` grep serverName $CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
    如果[[ “ $domain ”  =  “ ” ]] ； 然后
        domain= ` grep 主机$CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
        如果[[ “ $domain ”  !=  “ ” ]] ;  然后
            ws= “真”
            tls = "真"
            wspath= ` grep 路径$CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
        菲
    别的
        tls = "真"
    菲
    if [[ “ $ws ”  =  “真” ]] ； 然后
        port= ` grep -i ssl $NGINX_CONF_PATH ${domain} .conf | 头-n1 | awk ' {print $2} ' `
    别的
        port= ` grep port $CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
    菲
    res= ` grep -i kcp $CONFIG_FILE `
    如果[[ “ $res ” ！=  “ ” ]] ； 然后
        kcp= "真"
        type= ` grep header -A 3 $CONFIG_FILE  | grep '类型'  | 剪切 -d: -f2 | tr -d \" , '  ' `
        种子= ` grep 种子$CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
    菲

    vmess= ` grep vmess $CONFIG_FILE `
    if [[ " $vmess "  =  " " ]] ;  然后
        特洛伊木马= ` grep 特洛伊木马$CONFIG_FILE `
        如果[[ " $trojan "  =  " " ]] ;  然后
            vless= “真”
            协议= “ VLESS ”
        别的
            特洛伊木马= “真”
            密码= ` grep 密码$CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
            协议= “木马”
        菲
        tls = "真"
        加密= “无”
        xtls= ` grep xtlsSettings $CONFIG_FILE `
        如果[[ " $xtls "  !=  " " ]] ;  然后
            xtls = "真"
            flow= ` grep flow $CONFIG_FILE  | 剪切 -d: -f2 | tr -d \" , '  ' `
        别的
            流= “无”
        菲
    菲
}

输出Vmess（）{
    原始= “ {
  \" v \" : \" 2 \" ,
  \" ps \" : \"\" ,
  \"添加\" : \" $IP \" ,
  \"端口\" : \" ${port} \" ,
  \" id \" : \" ${uid} \" ,
  \"援助\" : \" $alterid \" ,
  \"网络\" : \" tcp \" ,
  \"输入\" : \"无\" ,
  \"主机\" : \"\" ,
  \"路径\" : \"\" ,
  \" tls \" : \"\"
} "
    link= ` echo -n ${raw}  | base64 -w 0 `
    链接= “ vmess:// ${link} ”

    echo -e "    ${BLUE} IP(地址): ${PLAIN}  ${RED}${IP}${PLAIN} "
    echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
    echo -e "    ${BLUE} id(uuid)：${PLAIN}${RED}${uid}${PLAIN} "
    echo -e "    ${BLUE}额外id(alterid)：${PLAIN}  ${RED}${alterid}${PLAIN} "
    echo -e "    ${BLUE}身体方式(security)：${PLAIN}  ${RED} auto ${PLAIN} "
    echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} " 
    回声  
    echo -e "    ${BLUE} vmesslink: ${PLAIN}  $RED$link$PLAIN "
}

输出VmessKCP（）{
    echo -e "    ${BLUE} IP(地址): ${PLAIN}  ${RED}${IP}${PLAIN} "
    echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
    echo -e "    ${BLUE} id(uuid)：${PLAIN}${RED}${uid}${PLAIN} "
    echo -e "    ${BLUE}额外id(alterid)：${PLAIN}  ${RED}${alterid}${PLAIN} "
    echo -e "    ${BLUE}身体方式(security)：${PLAIN}  ${RED} auto ${PLAIN} "
    echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} "
    echo -e "    ${BLUE}伪装类型(type)：${PLAIN}  ${RED}${type}${PLAIN} "
    echo -e "    ${BLUE} mkcp 种子：${PLAIN}  ${RED}${seed}${PLAIN} " 
}

输出木马（）{
    if [[ " $xtls "  =  " true " ]] ;  然后
        echo -e "    ${BLUE} IP/域名(地址): ${PLAIN}  ${RED}${domain}${PLAIN} "
        echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
        echo -e "    ${BLUE}密码(password)：${PLAIN}${RED}${password}${PLAIN} "
        echo -e "    ${BLUE}流控(flow)：${PLAIN} $RED$flow ${PLAIN} "
        echo -e "    ${BLUE}智能(encryption)：${PLAIN}  ${RED none ${PLAIN} "
        echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} " 
        echo -e "    ${BLUE}分享安全传输(tls)：${PLAIN}${RED} XTLS ${PLAIN} "
    别的
        echo -e "    ${BLUE} IP/域名(地址): ${PLAIN}  ${RED}${domain}${PLAIN} "
        echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
        echo -e "    ${BLUE}密码(password)：${PLAIN}${RED}${password}${PLAIN} "
        echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} " 
        echo -e "    ${BLUE}分享安全传输(tls)：${PLAIN}${RED} TLS ${PLAIN} "
    菲
}

输出VmessTLS（）{
    原始= “ {
  \" v \" : \" 2 \" ,
  \" ps \" : \"\" ,
  \"添加\" : \" $IP \" ,
  \"端口\" : \" ${port} \" ,
  \" id \" : \" ${uid} \" ,
  \"援助\" : \" $alterid \" ,
  \"网络\" : \" ${network} \" ,
  \"输入\" : \"无\" ,
  \"主机\" : \" ${domain} \" ,
  \"路径\" : \"\" ,
  \" tls \" : \" tls \"
} "
    link= ` echo -n ${raw}  | base64 -w 0 `
    链接= “ vmess:// ${link} ”
    echo -e "    ${BLUE} IP(地址): ${PLAIN}  ${RED}${IP}${PLAIN} "
    echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
    echo -e "    ${BLUE} id(uuid)：${PLAIN}${RED}${uid}${PLAIN} "
    echo -e "    ${BLUE}额外id(alterid)：${PLAIN}  ${RED}${alterid}${PLAIN} "
    echo -e "    ${BLUE}身体方式(security)：${PLAIN}  ${RED none ${PLAIN} "
    echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} " 
    echo -e "    ${BLUE}伪装域名/主机名(host)/SNI/peer名称：${PLAIN}${RED}${domain}${PLAIN} "
    echo -e "    ${BLUE}分享安全传输(tls)：${PLAIN}${RED} TLS ${PLAIN} "
    回声  
    echo -e "    ${BLUE} vmesslink: ${PLAIN} $RED$link$PLAIN "
}

输出VmessWS（）{
    原始= “ {
  \" v \" : \" 2 \" ,
  \" ps \" : \"\" ,
  \"添加\" : \" $IP \" ,
  \"端口\" : \" ${port} \" ,
  \" id \" : \" ${uid} \" ,
  \"援助\" : \" $alterid \" ,
  \"网络\" : \" ${network} \" ,
  \"输入\" : \"无\" ,
  \"主机\" : \" ${domain} \" ,
  \"路径\" : \" ${wspath} \" ,
  \" tls \" : \" tls \"
} "
    link= ` echo -n ${raw}  | base64 -w 0 `
    链接= “ vmess:// ${link} ”

    echo -e "    ${BLUE} IP(地址): ${PLAIN}  ${RED}${IP}${PLAIN} "
    echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
    echo -e "    ${BLUE} id(uuid)：${PLAIN}${RED}${uid}${PLAIN} "
    echo -e "    ${BLUE}额外id(alterid)：${PLAIN}  ${RED}${alterid}${PLAIN} "
    echo -e "    ${BLUE}身体方式(security)：${PLAIN}  ${RED none ${PLAIN} "
    echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} " 
    echo -e "    ${BLUE}伪装类型(type)：${PLAIN}${RED} none $PLAIN "
    echo -e "    ${BLUE}伪装域名/主机名(host)/SNI/peer名称：${PLAIN}${RED}${domain}${PLAIN} "
    echo -e "    ${BLUE}路径(path)：${PLAIN}${RED}${wspath}${PLAIN} "
    echo -e "    ${BLUE}分享安全传输(tls)：${PLAIN}${RED} TLS ${PLAIN} "
    回声  
    echo -e "    ${BLUE} vmesslink: ${PLAIN}  $RED$link$PLAIN "
}

显示信息（）{
    res= `状态`
    如果[[ $res  -lt 2 ]] ;  然后
        colorEcho $RED  " V2ray 未安装，请先安装！"
        返回
    菲

    回声 “ ”
    echo -n -e "  ${BLUE} V2ray 运行状态：${PLAIN} "
    状态文本
    echo -e "  ${BLUE} V2ray 配置文件: ${PLAIN}  ${RED}${CONFIG_FILE}${PLAIN} "
    colorEcho $BLUE  " V2ray 配置信息："

    获取配置文件信息

    echo -e "    ${BLUE}协议: ${PLAIN}  ${RED}${protocol}${PLAIN} "
    if [[ " $trojan "  =  " true " ]] ;  然后
        输出木马
        返回0
    菲
    if [[ “ $vless ”  =  “假” ]] ； 然后
        if [[ “ $kcp ”  =  “真” ]] ； 然后
            输出VmessKCP
            返回0
        菲
        if [[ “ $tls ”  =  “假” ]] ； 然后
            输出Vmess
        elif [[ " $ws "  =  " false " ]] ;  然后
            输出VmessTLS
        别的
            输出VmessWS
        菲
    别的
        if [[ “ $kcp ”  =  “真” ]] ； 然后
            echo -e "    ${BLUE} IP(地址): ${PLAIN}  ${RED}${IP}${PLAIN} "
            echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
            echo -e "    ${BLUE} id(uuid)：${PLAIN}${RED}${uid}${PLAIN} "
            echo -e "    ${BLUE}智能(encryption)：${PLAIN}  ${RED none ${PLAIN} "
            echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} "
            echo -e "    ${BLUE}伪装类型(type)：${PLAIN}  ${RED}${type}${PLAIN} "
            echo -e "    ${BLUE} mkcp 种子：${PLAIN}  ${RED}${seed}${PLAIN} " 
            返回0
        菲
        if [[ " $xtls "  =  " true " ]] ;  然后
            echo -e "    ${BLUE} IP(地址): ${PLAIN}  ${RED}${IP}${PLAIN} "
            echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
            echo -e "    ${BLUE} id(uuid)：${PLAIN}${RED}${uid}${PLAIN} "
            echo -e "    ${BLUE}流控(flow)：${PLAIN} $RED$flow ${PLAIN} "
            echo -e "    ${BLUE}智能(encryption)：${PLAIN}  ${RED none ${PLAIN} "
            echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} " 
            echo -e "    ${BLUE}伪装类型(type)：${PLAIN}${RED} none $PLAIN "
            echo -e "    ${BLUE}伪装域名/主机名(host)/SNI/peer名称：${PLAIN}${RED}${domain}${PLAIN} "
            echo -e "    ${BLUE}分享安全传输(tls)：${PLAIN}${RED} XTLS ${PLAIN} "
        elif [[ " $ws "  =  " false " ]] ;  然后
            echo -e "    ${BLUE} IP(地址):   ${PLAIN}${RED}${IP}${PLAIN} "
            echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
            echo -e "    ${BLUE} id(uuid)：${PLAIN}${RED}${uid}${PLAIN} "
            echo -e "    ${BLUE}流控(flow)：${PLAIN} $RED$flow ${PLAIN} "
            echo -e "    ${BLUE}智能(encryption)：${PLAIN}  ${RED none ${PLAIN} "
            echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} " 
            echo -e "    ${BLUE}伪装类型(type)：${PLAIN}${RED} none $PLAIN "
            echo -e "    ${BLUE}伪装域名/主机名(host)/SNI/peer名称：${PLAIN}${RED}${domain}${PLAIN} "
            echo -e "    ${BLUE}分享安全传输(tls)：${PLAIN}${RED} TLS ${PLAIN} "
        别的
            echo -e "    ${BLUE} IP(地址): ${PLAIN}  ${RED}${IP}${PLAIN} "
            echo -e "    ${BLUE}端口(port)：${PLAIN}${RED}${port}${PLAIN} "
            echo -e "    ${BLUE} id(uuid)：${PLAIN}${RED}${uid}${PLAIN} "
            echo -e "    ${BLUE}流控(flow)：${PLAIN} $RED$flow ${PLAIN} "
            echo -e "    ${BLUE}智能(encryption)：${PLAIN}  ${RED none ${PLAIN} "
            echo -e "    ${BLUE}传输协议(网络)：${PLAIN}  ${RED}${network}${PLAIN} " 
            echo -e "    ${BLUE}伪装类型(type)：${PLAIN}${RED} none $PLAIN "
            echo -e "    ${BLUE}伪装域名/主机名(host)/SNI/peer名称：${PLAIN}${RED}${domain}${PLAIN} "
            echo -e "    ${BLUE}路径(path)：${PLAIN}${RED}${wspath}${PLAIN} "
            echo -e "    ${BLUE}分享安全传输(tls)：${PLAIN}${RED} TLS ${PLAIN} "
        菲
    菲
}

显示日志（）{
    res= `状态`
    如果[[ $res  -lt 2 ]] ;  然后
        colorEcho $RED  " V2ray 未安装，请先安装！"
        返回
    菲

    journalctl -xen -u v2ray --no-pager
}

菜单（）{
    清除
    echo  " ############################################# ############## "
    echo -e " #                    ${RED} v2ray一键安装脚本${PLAIN}                       # "
    echo -e " # ${GREEN}作者${PLAIN} : 网络跳越(hijk) # "
    echo -e " # ${GREEN}网址${PLAIN} : https://hijk.art # "
    echo -e " # ${GREEN}论坛${PLAIN} : https://hijk.club # "
    echo -e " # ${GREEN} TG群${PLAIN} : https://t.me/hijkclub # "
    echo -e " # ${GREEN} Youtube 频道${PLAIN} : https://youtube.com/channel/UCYTB--VsObzepVJtc9yvUxQ # "
    echo  " ############################################# ############## "

    echo -e "   ${GREEN} 1. ${PLAIN}   安装V2ray-VMESS "
    echo -e "   ${GREEN} 2. ${PLAIN}   安装V2ray- ${BLUE} VMESS+mKCP ${PLAIN} "
    echo -e "   ${GREEN} 3. ${PLAIN}   安装V2ray-VMESS+TCP+TLS "
    echo -e "   ${GREEN} 4. ${PLAIN}   安装V2ray- ${BLUE} VMESS+WS+TLS ${PLAIN}${RED} (推荐) ${PLAIN} "
    echo -e "   ${GREEN} 5. ${PLAIN}   安装V2ray- ${BLUE} VLESS+mKCP ${PLAIN} "
    echo -e "   ${GREEN} 6. ${PLAIN}   安装V2ray-VLESS+TCP+TLS "
    echo -e "   ${GREEN} 7. ${PLAIN}   安装V2ray- ${BLUE} VLESS+WS+TLS ${PLAIN}${RED} (可过cdn) ${PLAIN} "
    echo -e "   ${GREEN} 8. ${PLAIN}   安装V2ray- ${BLUE} VLESS+TCP+XTLS ${PLAIN}${RED} (推荐) ${PLAIN} "
    echo -e "   ${GREEN} 9. ${PLAIN}   安装${BLUE}木马${PLAIN}${RED} (推荐) ${PLAIN} "
    echo -e "   ${GREEN} 10. ${PLAIN}  安装${BLUE} trojan+XTLS ${PLAIN}${RED} (推荐) ${PLAIN} "
    回声 “ ------------- ”
    echo -e "   ${GREEN} 11. ${PLAIN}  更新V2ray "
    echo -e "   ${GREEN} 12.   ${RED}卸V2ray ${PLAIN} "
    回声 “ ------------- ”
    echo -e "   ${GREEN} 13. ${PLAIN}  启动V2ray "
    echo -e "   ${GREEN} 14. ${PLAIN}  重启V2ray "
    echo -e "   ${GREEN} 15. ${PLAIN}  停止V2ray "
    回声 “ ------------- ”
    echo -e "   ${GREEN} 16. ${PLAIN}  查看V2ray配置"
    echo -e "   ${GREEN} 17. ${PLAIN}  查看V2ray日志"
    回声 “ ------------- ”
    echo -e "   ${GREEN} 0. ${PLAIN}   退出"
    echo -n "当前状态："
    状态文本
    回声 

    read -p "请选择操作[0-17]："答案
    案例 $answer  in
        0)
            退出0
            ;;
        1)
            安装
            ;;
        2)
            KCP= “真”
            安装
            ;;
        3)
            TLS = "真"
            安装
            ;;
        4)
            TLS = "真"
            WS= “真”
            安装
            ;;
        5)
            VLESS= “真”
            KCP= “真”
            安装
            ;;
        6)
            VLESS= “真”
            TLS = "真"
            安装
            ;;
        7)
            VLESS= “真”
            TLS = "真"
            WS= “真”
            安装
            ;;
        8)
            VLESS= “真”
            TLS = "真"
            XTLS= “真”
            安装
            ;;
        9)
            特洛伊木马= “真”
            TLS = "真"
            安装
            ;;
        10)
            特洛伊木马= “真”
            TLS = "真"
            XTLS= “真”
            安装
            ;;
        11)
            更新
            ;;
        12)
            卸载
            ;;
        13)
            开始
            ;;
        14)
            重新开始
            ;;
        15)
            停止
            ;;
        16)
            显示信息
            ;;
        17)
            显示日志
            ;;
        * )
            colorEcho $RED  "请选择正确的操作！"
            出口1
            ;;
    esac
}

检查系统

行动= $1
[[ -z  $1 ]] &&动作=菜单
案例 “ $action ” 中
    菜单|更新|卸载|开始|重启|停止|showInfo|showLog)
        ${动作}
        ;;
    * )
        echo  "参数错误"
        echo  "最佳方法: ` basename $0 ` [menu|update|uninstall|start|restart|stop|showInfo|showLog] "
        ;;
esac
