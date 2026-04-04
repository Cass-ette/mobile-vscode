## Chunk 2: Android Application

### Task 6: Project Setup and Gradle Configuration

**Files:**
- Create: `android/build.gradle`
- Create: `android/settings.gradle`
- Create: `android/app/build.gradle`

- [ ] **Step 1: Create root build.gradle**

```bash
cat > android/build.gradle << 'EOF'
// Top-level build file
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF
```

- [ ] **Step 2: Create settings.gradle**

```bash
cat > android/settings.gradle << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "MobileVSCode"
include ':app'
EOF
```

- [ ] **Step 3: Create app-level build.gradle**

```bash
cat > android/app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.mobilevscode'
    compileSdk 34

    defaultConfig {
        applicationId "com.mobilevscode"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.lifecycle:lifecycle-viewmodel:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-livedata:2.7.0'
}
EOF
```

- [ ] **Step 4: Create AndroidManifest.xml**

```bash
mkdir -p android/app/src/main

cat > android/app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.mobilevscode">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.MobileVSCode"
        android:usesCleartextTraffic="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.MobileVSCode.NoActionBar">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".service.CodeServerService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="dataSync" />

    </application>

</manifest>
EOF
```

- [ ] **Step 5: Commit**

```bash
git add android/
git commit -m "feat: add Android project structure and gradle configuration"
```

### Task 7: Resources - Strings, Colors, Layouts

**Files:**
- Create: `android/app/src/main/res/values/strings.xml`
- Create: `android/app/src/main/res/values/colors.xml`
- Create: `android/app/src/main/res/values/themes.xml`

- [ ] **Step 1: Create strings.xml**

```bash
mkdir -p android/app/src/main/res/values

cat > android/app/src/main/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Mobile VS Code</string>
    <string name="title_installing">Installing Environment...</string>
    <string name="title_starting">Starting VS Code Server...</string>
    <string name="title_ready">VS Code Ready</string>
    <string name="hint_open_browser">VS Code is running at http://localhost:8080</string>
    <string name="btn_install">Install Environment</string>
    <string name="btn_start">Start VS Code</string>
    <string name="btn_stop">Stop VS Code</string>
    <string name="status_not_installed">Environment not installed</string>
    <string name="status_installed">Environment ready</string>
    <string name="status_running">VS Code Server running</string>
    <string name="error_install_failed">Installation failed</string>
    <string name="error_start_failed">Failed to start VS Code</string>
</resources>
EOF
```

- [ ] **Step 2: Create colors.xml**

```bash
cat > android/app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="purple_200">#FFBB86FC</color>
    <color name="purple_500">#FF6200EE</color>
    <color name="purple_700">#FF3700B3</color>
    <color name="teal_200">#FF03DAC5</color>
    <color name="teal_700">#FF018786</color>
    <color name="black">#FF000000</color>
    <color name="white">#FFFFFFFF</color>
    <color name="vscode_blue">#007ACC</color>
    <color name="vscode_dark">#1E1E1E</color>
</resources>
EOF
```

- [ ] **Step 3: Create themes.xml**

```bash
cat > android/app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.MobileVSCode" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
        <item name="colorPrimary">@color/vscode_blue</item>
        <item name="colorPrimaryVariant">@color/vscode_dark</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="colorSecondary">@color/teal_200</item>
        <item name="colorSecondaryVariant">@color/teal_700</item>
        <item name="colorOnSecondary">@color/black</item>
        <item name="android:statusBarColor">@color/vscode_dark</item>
    </style>

    <style name="Theme.MobileVSCode.NoActionBar">
        <item name="windowActionBar">false</item>
        <item name="windowNoTitle">true</item>
    </style>
</resources>
EOF
```

- [ ] **Step 4: Commit**

```bash
git add android/app/src/main/res/values/
git commit -m "feat: add Android resources (strings, colors, themes)"
```

### Task 8: Main Activity and Layout

**Files:**
- Create: `android/app/src/main/res/layout/activity_main.xml`
- Create: `android/app/src/main/java/com/mobilevscode/MainActivity.java`

- [ ] **Step 1: Create activity_main.xml**

```bash
mkdir -p android/app/src/main/res/layout

cat > android/app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/vscode_dark">

    <ProgressBar
        android:id="@+id/progressBar"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:visibility="visible"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <TextView
        android:id="@+id/statusText"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:text="@string/title_starting"
        android:textColor="@color/white"
        android:textSize="18sp"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/progressBar" />

    <WebView
        android:id="@+id/webView"
        android:layout_width="0dp"
        android:layout_height="0dp"
        android:visibility="gone"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <LinearLayout
        android:id="@+id/controlPanel"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp"
        android:visibility="gone"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent">

        <Button
            android:id="@+id/btnInstall"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="@string/btn_install"
            android:visibility="gone" />

        <Button
            android:id="@+id/btnStart"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="@string/btn_start"
            android:visibility="gone" />

        <Button
            android:id="@+id/btnStop"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="@string/btn_stop"
            android:visibility="gone" />

    </LinearLayout>

</androidx.constraintlayout.widget.ConstraintLayout>
EOF
```

- [ ] **Step 2: Create MainActivity.java**

```bash
mkdir -p android/app/src/main/java/com/mobilevscode

cat > android/app/src/main/java/com/mobilevscode/MainActivity.java << 'EOF'
package com.mobilevscode;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.mobilevscode.service.CodeServerService;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends AppCompatActivity {

    private static final int PERMISSION_REQUEST_CODE = 100;
    private static final String VSCODE_URL = "http://localhost:8080";
    private static final String BASE_DIR = "/data/data/com.termux/files/home/mobile-dev-env";

    private WebView webView;
    private ProgressBar progressBar;
    private TextView statusText;
    private View controlPanel;
    private Button btnInstall, btnStart, btnStop;

    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        initViews();
        checkPermissions();
    }

    private void initViews() {
        webView = findViewById(R.id.webView);
        progressBar = findViewById(R.id.progressBar);
        statusText = findViewById(R.id.statusText);
        controlPanel = findViewById(R.id.controlPanel);
        btnInstall = findViewById(R.id.btnInstall);
        btnStart = findViewById(R.id.btnStart);
        btnStop = findViewById(R.id.btnStop);

        setupWebView();
        setupButtons();
    }

    private void setupWebView() {
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);

        webView.setWebChromeClient(new WebChromeClient());
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                view.loadUrl(url);
                return true;
            }
        });
    }

    private void setupButtons() {
        btnInstall.setOnClickListener(v -> installEnvironment());
        btnStart.setOnClickListener(v -> startCodeServer());
        btnStop.setOnClickListener(v -> stopCodeServer());
    }

    private void checkPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                Manifest.permission.READ_EXTERNAL_STORAGE},
                        PERMISSION_REQUEST_CODE);
            } else {
                checkEnvironment();
            }
        } else {
            checkEnvironment();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                checkEnvironment();
            } else {
                statusText.setText("Storage permission required");
            }
        }
    }

    private void checkEnvironment() {
        executor.execute(() -> {
            boolean installed = new File(BASE_DIR).exists();
            boolean running = isCodeServerRunning();

            mainHandler.post(() -> {
                if (!installed) {
                    showControlPanel();
                    btnInstall.setVisibility(View.VISIBLE);
                    statusText.setText(R.string.status_not_installed);
                } else if (!running) {
                    showControlPanel();
                    btnStart.setVisibility(View.VISIBLE);
                    statusText.setText(R.string.status_installed);
                } else {
                    loadVSCode();
                }
            });
        });
    }

    private void installEnvironment() {
        progressBar.setVisibility(View.VISIBLE);
        statusText.setText(R.string.title_installing);
        btnInstall.setVisibility(View.GONE);
        controlPanel.setVisibility(View.GONE);

        executor.execute(() -> {
            try {
                // Copy scripts from assets
                copyScriptsFromAssets();

                // Run install script
                ProcessBuilder pb = new ProcessBuilder(
                        "/data/data/com.termux/files/usr/bin/bash",
                        BASE_DIR + "/scripts/install.sh"
                );
                pb.redirectErrorStream(true);
                Process process = pb.start();

                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(process.getInputStream()));
                String line;
                while ((line = reader.readLine()) != null) {
                    final String logLine = line;
                    mainHandler.post(() -> statusText.setText(logLine));
                }

                int exitCode = process.waitFor();

                mainHandler.post(() -> {
                    if (exitCode == 0) {
                        statusText.setText(R.string.status_installed);
                        startCodeServer();
                    } else {
                        statusText.setText(R.string.error_install_failed);
                        btnInstall.setVisibility(View.VISIBLE);
                    }
                });

            } catch (Exception e) {
                mainHandler.post(() -> {
                    statusText.setText("Error: " + e.getMessage());
                    btnInstall.setVisibility(View.VISIBLE);
                });
            }
        });
    }

    private void startCodeServer() {
        progressBar.setVisibility(View.VISIBLE);
        statusText.setText(R.string.title_starting);
        controlPanel.setVisibility(View.GONE);

        // Start background service
        Intent serviceIntent = new Intent(this, CodeServerService.class);
        startService(serviceIntent);

        // Wait for server and load
        executor.execute(() -> {
            boolean started = waitForCodeServer(30000);
            mainHandler.post(() -> {
                if (started) {
                    loadVSCode();
                } else {
                    statusText.setText(R.string.error_start_failed);
                    showControlPanel();
                    btnStart.setVisibility(View.VISIBLE);
                }
            });
        });
    }

    private void stopCodeServer() {
        Intent serviceIntent = new Intent(this, CodeServerService.class);
        stopService(serviceIntent);

        executor.execute(() -> {
            try {
                ProcessBuilder pb = new ProcessBuilder(
                        "/data/data/com.termux/files/usr/bin/bash",
                        BASE_DIR + "/scripts/stop.sh"
                );
                pb.start().waitFor();

                mainHandler.post(() -> {
                    webView.setVisibility(View.GONE);
                    showControlPanel();
                    btnStart.setVisibility(View.VISIBLE);
                    btnStop.setVisibility(View.GONE);
                    statusText.setText(R.string.status_installed);
                });
            } catch (Exception e) {
                mainHandler.post(() -> statusText.setText("Error stopping: " + e.getMessage()));
            }
        });
    }

    private void loadVSCode() {
        progressBar.setVisibility(View.GONE);
        statusText.setVisibility(View.GONE);
        webView.setVisibility(View.VISIBLE);
        webView.loadUrl(VSCODE_URL);
    }

    private void showControlPanel() {
        progressBar.setVisibility(View.GONE);
        controlPanel.setVisibility(View.VISIBLE);
    }

    private void copyScriptsFromAssets() {
        // Implementation to copy bundled scripts
        // This assumes scripts are bundled in assets/scripts/
    }

    private boolean isCodeServerRunning() {
        try {
            HttpURLConnection conn = (HttpURLConnection) new URL(VSCODE_URL).openConnection();
            conn.setConnectTimeout(1000);
            conn.setRequestMethod("GET");
            int responseCode = conn.getResponseCode();
            conn.disconnect();
            return responseCode == 200;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean waitForCodeServer(int timeoutMs) {
        long startTime = System.currentTimeMillis();
        while (System.currentTimeMillis() - startTime < timeoutMs) {
            if (isCodeServerRunning()) {
                return true;
            }
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return false;
            }
        }
        return false;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        executor.shutdown();
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
EOF
```

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/res/layout/ android/app/src/main/java/com/mobilevscode/MainActivity.java
git commit -m "feat: add MainActivity and layout with WebView integration"
```

### Task 9: Background Service

**Files:**
- Create: `android/app/src/main/java/com/mobilevscode/service/CodeServerService.java`

- [ ] **Step 1: Create background service**

```bash
mkdir -p android/app/src/main/java/com/mobilevscode/service

cat > android/app/src/main/java/com/mobilevscode/service/CodeServerService.java << 'EOF'
package com.mobilevscode.service;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.mobilevscode.MainActivity;
import com.mobilevscode.R;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class CodeServerService extends Service {

    private static final String CHANNEL_ID = "codeserver_channel";
    private static final int NOTIFICATION_ID = 1;
    private static final String BASE_DIR = "/data/data/com.termux/files/home/mobile-dev-env";

    private Process codeServerProcess;
    private Thread logThread;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startForeground(NOTIFICATION_ID, buildNotification());
        startCodeServer();
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopCodeServer();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "VS Code Server",
                    NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Keeps VS Code Server running in background");
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
    }

    private Notification buildNotification() {
        Intent intent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, intent, PendingIntent.FLAG_IMMUTABLE);

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Mobile VS Code")
                .setContentText("VS Code Server is running")
                .setSmallIcon(android.R.drawable.ic_menu_edit)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build();
    }

    private void startCodeServer() {
        new Thread(() -> {
            try {
                ProcessBuilder pb = new ProcessBuilder(
                        "/data/data/com.termux/files/usr/bin/bash",
                        BASE_DIR + "/scripts/start.sh"
                );
                pb.redirectErrorStream(true);
                codeServerProcess = pb.start();

                // Log output
                logThread = new Thread(() -> {
                    try {
                        BufferedReader reader = new BufferedReader(
                                new InputStreamReader(codeServerProcess.getInputStream()));
                        String line;
                        while ((line = reader.readLine()) != null) {
                            android.util.Log.d("CodeServer", line);
                        }
                    } catch (Exception e) {
                        android.util.Log.e("CodeServer", "Error reading log", e);
                    }
                });
                logThread.start();

                codeServerProcess.waitFor();

            } catch (Exception e) {
                android.util.Log.e("CodeServer", "Error starting service", e);
            }
        }).start();
    }

    private void stopCodeServer() {
        try {
            if (codeServerProcess != null && codeServerProcess.isAlive()) {
                codeServerProcess.destroy();
            }

            // Run stop script
            ProcessBuilder pb = new ProcessBuilder(
                    "/data/data/com.termux/files/usr/bin/bash",
                    BASE_DIR + "/scripts/stop.sh"
            );
            pb.start();

        } catch (Exception e) {
            android.util.Log.e("CodeServer", "Error stopping service", e);
        }
    }
}
EOF
```

- [ ] **Step 2: Commit**

```bash
git add android/app/src/main/java/com/mobilevscode/service/
git commit -m "feat: add background service for VS Code Server lifecycle"
```

### Task 10: README and Documentation

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create comprehensive README**

```bash
cat > README.md << 'EOF'
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
EOF
```

- [ ] **Step 2: Final commit**

```bash
git add README.md
git commit -m "docs: add comprehensive README with installation and usage guide"
```

### Task 11: Push to GitHub

- [ ] **Step 1: Push all commits**

```bash
git push origin main
```

---

## Summary

This implementation plan creates:

1. **Shell Scripts** (`scripts/`):
   - `config.sh` - Environment configuration
   - `install.sh` - One-click installer with download and setup
   - `start.sh` - VS Code Server launcher with process management
   - `stop.sh` - Cleanup and stop script
   - `fix-libs.sh` - Library dependency repair

2. **Android App** (`android/`):
   - Complete Gradle project structure
   - MainActivity with WebView integration
   - Background service for server lifecycle
   - Resources (layouts, strings, themes)
   - AndroidManifest with permissions

3. **Documentation**:
   - README with installation steps
   - Usage guide for extensions and projects
   - FAQ for common issues

**Total estimated time**: 4-6 hours for implementation + testing

**Ready to execute?** Use @superpowers:subagent-driven-development or @superpowers:executing-plans to proceed.
