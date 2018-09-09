# Certs

利用 `Gitlab ci` 自动部署 `ssl` 证书文件

## 如何使用

只需要修改 `git repo` 中的配置文件，配置域名和目标机器的主机名 `host` 并提交就可以自动部署。

## 说明

证书文件默认会被拷贝到目标机器 `/etc/nginx/le/` 目录下，请修改 `nginx` 等服务配置的证书路径

## 准备

1. 域名托管在 cloudflare，在 ci 运行时会需要通过 dns 认证方式获取 le 证书

2. 目标机器已经添加 ci 的 ssh 公钥 `id_rsa.pub` 到 `.ssh/authorized_keys`， ci 运行时会通过 `scp` 将证书文件拷贝到 `/etc/nginx/le` 目录。

3. 一个 s3 兼容的外部存储，如自建 `minio`，用来存储 ci 生成的证书文件，这样就不需要每次生成新证书了。 ci 在运行前会先从 s3 下载证书文件，检查是否快过期，如果不需要更新证书就会使用已有的证书文件。

4. ssh 客户端 `.ssh/config` 和 `.ssh/know_hosts` 文件并可以通过 HTTP 下载，配置好目标机器的 ssh 地址和端口 如

```
host example
hostname example.xdty.org
port 22
user root
```

## 配置

1. 添加域名

在 `sites/` 目录下增加 `your_site.conf` 配置文件，如 `wild.conf`，添加类似如下内容

```
DIR="wild.web.xdty.org"
DOMAIN="xdty.org"
CERT_DOMAINS="xdty.org *.xdty.org *.web.xdty.org > $DIR"
#ECC=true
```
其中 `DIR` 为证书生成的目录，`DOMAIN` 是域名，`CERT_DOMAINS` 是证书配置的域名，也可以增加 `ECC=true` 表示输出 `ECC` 证书。

其中 `xdty.org *.xdty.org *.web.xdty.org > $DIR` 表示指定证书到 `DIR` 目录。如果不需要多级证书，可以不显示指定目录，如下配置会直接生成证书到 `xdty.org` 目录下。

```
DIR="xdty.org"
DOMAIN="xdty.org"
CERT_DOMAINS="xdty.org *.xdty.org"
```

可以在 `sites/` 下添加多个配置文件来获取多个域名的证书并生成到相应目录。

2. 添加主机

在 `hosts` 目录下添加主机配置文件，如 `jp` 配置文件

```
DIRS=(busy wild tws route)
REMOTE_CMD="systemctl reload nginx || systemctl restart nginx"
```
注意这里的配置文件名是与目标主机的 `hostname` 对应的，运行时会根据配置文件名 `scp` 到目标 `host`

`DIRS` 表示向 `jp` 主机中添加 `busy wild tws route` 这四个域名的证书文件，这里的域名和 `sites/` 目录下的文件名相同，如域名配置文件名为 `wild.conf`，则对应的这里填为 `wild`

`REMOTE_CMD` 表示部署完成后执行的命令，这里的命令为重新加载 nginx 服务

## CI 环境变量

需要添加如下 CI 环境变量

| 环境变量         | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| API_KEY          | cloudflare api key                                           |
| CF_EMAIL         | cloudflare 登陆邮箱                                          |
| CF_TOKEN         | cloudflare api token                                         |
| KEYS_URL         | 外部 ssh 配置路径，用来获取 `.ssh/config` 和 `.ssh/known_hosts` 如 `https://keys.xdty.org` |
| MINIO_ACCESS_KEY | 外部 s3 存储服务 access key                                  |
| MINIO_SECRET_KEY | 外部 s3 存储服务 secret key                                  |
| S3_URL           | 外部 s3 存储服务 如 `https://s3.xdty.org`                    |
| SSH_PRIVATE_KEY  | CI 自动部署私匙，`id_rsa` 文本内容，与集成到目标机器的 `authorized_keys` 对应 |



----------

Automatic deployment of `ssl` certificate files with `Gitlab ci`



