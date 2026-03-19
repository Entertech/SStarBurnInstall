# SStar Burn Installer

这个仓库只公开发布 `install.sh`，用于安装内部工具 **SStar Burn**。

- `install.sh` 会自动从主仓库拉取代码并完成系统安装
- 这个仓库的 `install.sh` 由主仓库 CI 自动同步，不建议直接手改

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

安装后用户只需要用：

```bash
ssburn -p /dev/tty.usbserial-xxxx -f /path/to/USB_UPGRADE_UFU.bin
```

升级和卸载：

```bash
ssburn self upgrade
ssburn self remove
```

## 说明

- 主仓库：<https://github.com/Entertech/SStarBurn>
- 如果主仓库仍然是私有的，执行安装脚本的用户仍然需要有主仓库访问权限
