# Mobile VS Code

Android 设备上的原生 VS Code 开发环境。基于 Proot + Ubuntu 22.04 + VS Code Server，通过 WebView 内嵌实现"点开即用"的移动端开发体验。

## 特性

- **一键安装**: 自动下载配置 Ubuntu RootFS 和 VS Code Server
- **持久化存储**: 所有数据保存在 `~/mobile-dev-env/`，重启不丢失
- **扩展支持**: 正常安装 VS Code 扩展，重启后依然存在
- **项目托管**: 代码放在 `~/mobile-dev-env/workspace/`，支持 Git 操作
- **后台服务**: 切换应用后 VS Code Server 继续运行

## 系统要求

- Android 7.0+ (API 24)
- Termux 应用（提供 proot 环境）
- 存储空间: 建议 2GB+ 可用空间
- 内存: 建议 3GB+ RAM

## 安装步骤

### 1. 安装 Termux

从 F-Droid 或 GitHub Releases 下载安装 Termux：
- https://f-droid.org/packages/com.termux/

### 2. 在 Termux 中安装依赖

```bash
pkg update
pkg install proot curl tar -y
```

### 3. 编译安装 Mobile VS Code

#### 方法一：使用 Android Studio
1. 打开 Android Studio
2. File → Open → 选择 `android/` 目录
3. Build → Build Bundle(s) / APK(s) → Build APK(s)
4. 生成的 APK 在 `app/build/outputs/apk/debug/app-debug.apk`

#### 方法二：命令行
```bash
cd android
./gradlew assembleDebug
```

### 4. 安装 APK

将 APK 传输到手机并安装，或使用 adb：
```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

### 5. 首次启动

1. 打开 Mobile VS Code 应用
2. 授予存储权限
3. 点击"Install Environment"按钮
4. 等待下载和安装完成（约 5-10 分钟，取决于网络）
5. 安装完成后自动启动 VS Code Server
6. WebView 加载后即可开始使用

## 目录结构

```
~/mobile-dev-env/
├── ubuntu-rootfs/          # Ubuntu 22.04 RootFS
├── vscode-server/          # VS Code Server 安装
├── vscode-data/            # VS Code 用户数据
│   ├── extensions/         # 安装的扩展
│   └── globalStorage/      # 扩展存储
├── workspace/              # 代码工作目录
│   └── projects/           # 推荐项目存放位置
├── scripts/                # 管理脚本
└── config/                 # 配置文件
```

## 使用指南

### 打开项目

VS Code 打开 `/root/workspace` 作为默认工作区。你可以：
- 在 VS Code 中 `File → Open Folder` 打开子目录
- 使用终端 `git clone` 项目到 workspace

### 安装扩展

和在桌面版 VS Code 中一样操作：
1. 点击左侧扩展图标
2. 搜索需要的扩展
3. 点击 Install

扩展会保存在 `~/mobile-dev-env/vscode-data/extensions/`，重启后自动加载。

### 使用终端

VS Code 内置终端可以直接使用：
- `Ctrl + \`` 打开/关闭终端
- 终端在 Ubuntu 容器内运行，支持 apt install 安装软件

### 常见问题

**Q: 安装时下载很慢或失败？**
A: 脚本使用 ghproxy.com 镜像加速。如果仍有问题，可以在 Termux 中手动设置代理后再试。

**Q: 启动后显示"无法连接"？**
A: 首次启动需要等待 10-30 秒让 VS Code Server 初始化。如果长时间无法连接，尝试：
```bash
# 在 Termux 中手动启动
~/mobile-dev-env/scripts/stop.sh
~/mobile-dev-env/scripts/start.sh
```

**Q: 如何更新 VS Code Server 版本？**
A: 设置环境变量后重新安装：
```bash
export VSCODE_VERSION=4.91.1
~/mobile-dev-env/scripts/install.sh
```

**Q: 扩展安装失败？**
A: 部分扩展需要原生编译支持。在终端中安装编译工具：
```bash
apt update
apt install build-essential python3 -y
```

**Q: 如何完全卸载？**
```bash
~/mobile-dev-env/scripts/stop.sh
rm -rf ~/mobile-dev-env
```

## 技术栈

- **Android**: Java 11, Gradle 8.x, WebView
- **容器**: Proot, Ubuntu 22.04 ARM64
- **编辑器**: code-server (VS Code Server)
- **构建**: Android Studio / Gradle

## 许可证

MIT License

## 致谢

- [Termux](https://termux.dev/) - 提供 Android 终端环境
- [Proot](https://proot-me.github.io/) - 用户空间 chroot 实现
- [code-server](https://coder.com/) - VS Code 远程开发
- [Ubuntu](https://ubuntu.com/) - 基础操作系统
