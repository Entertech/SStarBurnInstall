# SStar Burn Installer

这个仓库用于公开发布 `SStar Burn` 的 bootstrap 安装入口。

这份 README 在主仓库 `Entertech/SStarBurn` 的 `public-installer/README.md` 中维护，并由 GitHub Actions 自动同步到这里。

公开 installer 仓库只发布两类文件：

- `install.sh`：bootstrap 安装脚本
- `README.md`：面向最终用户的安装说明

## 安装

默认安装会跟踪内部主仓库 `git@github.com:Entertech/SStarBurn.git` 的 `main` 分支：

```bash
tmp="$(mktemp)" \
  && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" \
  && chmod +x "$tmp" \
  && "$tmp" \
  && rm -f "$tmp"
```

如果你不是从内部私有仓库安装，而是从公开镜像、客户仓库或 fork 安装，可以显式覆盖源码地址：

```bash
tmp="$(mktemp)" \
  && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" \
  && chmod +x "$tmp" \
  && "$tmp" --repo-url https://github.com/ORG/SStarBurn.git --ref main \
  && rm -f "$tmp"
```

如果你要安装一个固定版本，而不是持续跟踪某个分支，可以把 `--ref` 指到 tag：

```bash
tmp="$(mktemp)" \
  && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" \
  && chmod +x "$tmp" \
  && "$tmp" --repo-url https://github.com/ORG/SStarBurn.git --ref v0.1.0 \
  && rm -f "$tmp"
```

常用安装参数：

```bash
tmp="$(mktemp)" && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" && chmod +x "$tmp" && "$tmp" --sudo-group entertech && rm -f "$tmp"
tmp="$(mktemp)" && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" && chmod +x "$tmp" && "$tmp" --no-sudoers && rm -f "$tmp"
tmp="$(mktemp)" && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" && chmod +x "$tmp" && "$tmp" --prefix /opt/custom/sstarburn --bin-dir /usr/local/bin && rm -f "$tmp"
```

如果刚更新过公开 installer 仓库，`raw.githubusercontent.com` 的分支 URL 可能会有几分钟 CDN 缓存；加执行位的写法对新旧脚本都兼容。

## 使用

安装后直接执行：

```bash
ssburn -p /dev/tty.usbserial-xxxx -f /path/to/USB_UPGRADE_UFU.bin
```

升级和卸载：

```bash
ssburn self upgrade
ssburn self remove
```

`ssburn self upgrade` 会更新“安装时记录下来的 managed checkout”并重装系统副本。

- 如果初始安装跟踪的是分支，例如 `main`，升级会继续从同一个 repo 拉取这个分支的最新代码
- 如果初始安装用的是固定 tag，managed checkout 没有可持续跟踪的 upstream；这时建议重新执行安装脚本并指定新的 `--ref`

## 说明

- 主仓库：[Entertech/SStarBurn](https://github.com/Entertech/SStarBurn)
- 如果主仓库仍然是私有的，执行安装脚本的用户仍然需要有主仓库访问权限
- 如果使用公开仓库，建议优先使用 HTTPS `--repo-url`，这样安装机器不需要预先配置 GitHub SSH key
