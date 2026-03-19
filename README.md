# SStar Burn Installer

这个目录用于维护公开 installer 仓库 `Entertech/SStarBurnInstall` 的同步内容。

公开 installer 仓库只发布两类文件：

- `install.sh`：bootstrap 安装脚本
- `README.md`：面向最终用户的安装说明

这份 README 会被 GitHub Actions 自动同步到公开仓库，不建议在公开仓库里直接手改。

## 安装

```bash
tmp="$(mktemp)" \
  && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" \
  && bash "$tmp" \
  && rm -f "$tmp"
```

常用安装参数：

```bash
tmp="$(mktemp)" && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" && bash "$tmp" --sudo-group entertech && rm -f "$tmp"
tmp="$(mktemp)" && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" && bash "$tmp" --no-sudoers && rm -f "$tmp"
tmp="$(mktemp)" && curl -fsSL https://raw.githubusercontent.com/Entertech/SStarBurnInstall/main/install.sh -o "$tmp" && bash "$tmp" --prefix /opt/custom/sstarburn --bin-dir /usr/local/bin && rm -f "$tmp"
```

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

## 说明

- 主仓库：[Entertech/SStarBurn](https://github.com/Entertech/SStarBurn)
- 如果主仓库仍然是私有的，执行安装脚本的用户仍然需要有主仓库访问权限
