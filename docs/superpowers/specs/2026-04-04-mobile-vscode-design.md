# Mobile VS Code - 移动端 VS Code 开发环境设计文档

## 概述

构建一个 Android 应用，打包安装后提供原生 VS Code 体验。基于 Proot + Ubuntu 22.04 + VS Code Server，通过 WebView 内嵌呈现，实现"点开即用"的移动端开发环境。

## 架构

```
Android App (APK)
├── 终端模拟层（内置）
│   └── 执行 Shell 脚本（Proot 管理、环境部署）
├── Proot 容器层
│   └── Ubuntu 22.04 ARM64 RootFS（持久化存储）
├── VS Code Server
│   └── code-server（可配置版本，默认 4.90.3）
│   └── 监听 localhost:8080，无认证模式
└── WebView 界面层
    └── 加载 http://localhost:8080
    └── 全屏显示，沉浸式体验
```

## 持久化目录结构

所有数据存储在 App 的持久化 home 目录下：

```
~/mobile-dev-env/
├── ubuntu-rootfs/          # Ubuntu 22.04 RootFS
├── vscode-server/          # VS Code Server 安装
├── scripts/                # 管理脚本
│   ├── install.sh          # 一键安装
│   ├── start.sh            # 启动环境
│   ├── stop.sh             # 停止环境
│   └── fix-libs.sh         # 库修复工具
├── workspace/              # 代码工作目录（挂载到容器 /root/workspace）
└── config/                 # 配置文件
    ├── bashrc              # 容器内 bash 配置
    └── vscode-settings.json
```

## 核心功能

### 1. 一键安装脚本 (install.sh)

- 检测并清理旧环境
- 下载 Ubuntu 22.04 ARM64 RootFS（使用 GitHub 镜像加速）
- 安装 VS Code Server（支持 `VSCODE_VERSION` 环境变量自定义版本）
- 修复库依赖（libreadline.so.8、libz.so.1 等）
- 配置 Proot 启动参数（`--shared-tmp --bind ~/mobile-dev-env/workspace:/root/workspace`）
- 容错处理：进程清理、目录创建、权限赋予

### 2. 启动脚本 (start.sh)

- 检测现有 Proot 进程，智能复用或重启
- 启动 Proot 容器（挂载持久化目录）
- 在容器内启动 VS Code Server（`--auth none --bind-addr 0.0.0.0:8080`）
- 轮询检测 8080 端口就绪，输出启动状态
- 支持终端重启后直接运行恢复环境

### 3. Android App

- **语言**：Java（兼容性好，不依赖 Kotlin 环境）
- **最低 SDK**：API 24 (Android 7.0)
- **核心组件**：
  - 终端模拟器：嵌入 Terminal Emulator 库（基于 JNI 的 pts/shell）
  - WebView：加载 VS Code Server 界面，全屏沉浸式
  - 服务管理：后台 Service 保持 VS Code Server 运行
- **启动流程**：
  1. App 打开 → 检查环境是否已安装
  2. 未安装 → 显示安装进度 → 自动执行 install.sh
  3. 已安装 → 直接执行 start.sh
  4. 检测 VS Code 就绪 → WebView 加载 http://localhost:8080
- **生命周期**：后台 Service 保持进程存活，避免系统杀掉

### 4. 库依赖修复

- 下载并安装 libreadline8、zlib1g 的 ARM64 .deb 包
- 将库文件放到 RootFS 的 `/usr/lib/aarch64-linux-gnu/`
- 处理 ldconfig 配置
- 作为安装脚本的一部分自动执行

## 关键技术决策

| 决策 | 选择 | 原因 |
|------|------|------|
| Ubuntu 版本 | 22.04 LTS | 稳定、轻量、兼容性好 |
| VS Code Server 版本 | 可配置，默认 4.90.3 | 兼顾稳定性和灵活性 |
| 界面方案 | WebView 内嵌 | 无缝集成，无需额外 App |
| 存储位置 | ~/mobile-dev-env/ | 持久化分区，重启不丢失 |
| 下载加速 | ghproxy.com 镜像 | 解决移动端 GitHub 访问慢 |
| Android 语言 | Java | 不依赖 Kotlin 环境，兼容性好 |
| Proot 参数 | --shared-tmp --bind | 确保 IPC 和工作目录持久 |

## 技术栈

### Android App
- **语言**：Java 11
- **构建工具**：Gradle 8.x + Android Gradle Plugin 8.x
- **最低 SDK**：API 24 (Android 7.0)
- **目标 SDK**：API 34 (Android 14)
- **架构**：MVVM（轻量级，单 Activity + 多 Fragment）
- **依赖库**：
  - AndroidX AppCompat（兼容库）
  - AndroidX WebView（内嵌浏览器）
  - Terminal Emulator Library（通过 AAR/JNI 嵌入，自定义编译）

### Shell 脚本
- **Shell**：Bash 5.x
- **依赖**：curl/wget, proot, tar
- **RootFS**：Ubuntu 22.04 ARM64 (tarball)
- **VS Code Server**：coder/code-server ARM64 构建

### 开发环境
- **IDE**：Android Studio Hedgehog (2023.1.1) 或更新版本
- **JDK**：OpenJDK 17
- **NDK**：不需要（使用 Termux 预编译二进制）
- **模拟器**：AVD with API 24-34

### 项目结构

```
mobile-vscode/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── java/com/mobilevscode/
│   │   │   │   ├── MainActivity.java
│   │   │   │   ├── WebViewFragment.java
│   │   │   │   ├── TerminalFragment.java
│   │   │   │   └── service/CodeServerService.java
│   │   │   ├── res/
│   │   │   └── assets/scripts/     # 内置脚本
│   │   └── build.gradle
│   └── build.gradle
├── scripts/                      # 可独立使用的脚本
│   ├── install.sh
│   ├── start.sh
│   ├── stop.sh
│   └── fix-libs.sh
├── README.md
└── docs/
```

## 常见问题处理

1. **端口 8080 被占用** → 脚本检测并杀死占用进程
2. **Proot 进程残留** → 启动前清理残留进程
3. **VS Code 启动失败** → 输出日志到 ~/mobile-dev-env/logs/，提供诊断信息
4. **RootFS 下载失败** → 支持断点续传和镜像切换
5. **库缺失** → fix-libs.sh 可独立运行修复

## 非目标

- 不做 iOS 版本
- 不做 VNC/远程桌面方案
- 不内置编译工具链（用户可自行 apt install）
- 不处理 root 权限需求（Proot 无需 root）
