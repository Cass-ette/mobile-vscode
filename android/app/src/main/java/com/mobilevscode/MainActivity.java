package com.mobilevscode;

import android.content.Intent;
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

import com.mobilevscode.service.CodeServerService;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * MainActivity for Mobile VS Code.
 *
 * Uses app-owned runtime under Context.getFilesDir() (no external storage or Termux required).
 */
public class MainActivity extends AppCompatActivity {

    private static final int PERMISSION_REQUEST_CODE = 100;
    private static final String VSCODE_URL = "http://localhost:8080";

    private WebView webView;
    private ProgressBar progressBar;
    private TextView statusText;
    private View controlPanel;
    private Button btnInstall, btnStart, btnStop;

    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private RuntimePaths paths;
    private RuntimeInstaller installer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        paths = RuntimePaths.fromFilesDir(getFilesDir());
        installer = new RuntimeInstaller(this);

        initViews();
        checkEnvironment();
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

    private void checkEnvironment() {
        executor.execute(() -> {
            boolean bootstrapReady = installer.ensureBootstrap();
            boolean installed = installer.isEnvironmentInstalled();
            boolean running = isCodeServerRunning();

            mainHandler.post(() -> {
                if (!bootstrapReady) {
                    statusText.setText("Bootstrap failed");
                    showControlPanel();
                    btnInstall.setVisibility(View.GONE);
                } else if (!installed) {
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
                // Bootstrap should already be done in checkEnvironment, but ensure it
                installer.ensureBootstrap();

                // Run install script
                File installScript = new File(paths.getScriptsDir(), "install.sh");
                ProcessBuilder pb = ProcessRunner.createScriptProcessBuilder(paths, installScript);
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
                File stopScript = new File(paths.getScriptsDir(), "stop.sh");
                ProcessBuilder pb = ProcessRunner.createScriptProcessBuilder(paths, stopScript);
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
