package com.mobilevscode;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Handles installation of the runtime environment from assets.
 *
 * Responsibilities:
 * - Copy scripts and proot binary from assets to app-private storage
 * - Create directory structure
 * - Write install marker when complete
 * Note: Uses system curl and toybox instead of downloading binaries.
 */
public class RuntimeInstaller {
    private static final String TAG = "RuntimeInstaller";
    private static final String ASSETS_SCRIPTS_DIR = "scripts";
    private static final String ASSETS_RUNTIME_DIR = "runtime";

    private final Context context;
    private final RuntimePaths paths;

    public RuntimeInstaller(Context context) {
        this.context = context.getApplicationContext();
        this.paths = RuntimePaths.fromFilesDir(context.getFilesDir());
    }

    /**
     * Ensure the bootstrap runtime is available.
     *
     * This copies scripts and proot binary from assets to the runtime directory.
     *
     * @return true if bootstrap is ready
     */
    public boolean ensureBootstrap() {
        try {
            ensureDirectories();
            copyScriptsFromAssets();
            copyProotFromAssets();
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Bootstrap setup failed", e);
            return false;
        }
    }

    /**
     * Check if the full environment is installed (marker file exists).
     */
    public boolean isEnvironmentInstalled() {
        return paths.getInstallMarkerFile().exists();
    }

    private void ensureDirectories() {
        paths.getBaseDir().mkdirs();
        paths.getRootfsDir().mkdirs();
        paths.getCodeServerDir().mkdirs();
        paths.getVscodeDataDir().mkdirs();
        paths.getWorkspaceDir().mkdirs();
        paths.getLogsDir().mkdirs();
        paths.getScriptsDir().mkdirs();
        paths.getRuntimeBinDir().mkdirs();
        paths.getConfigDir().mkdirs();
        paths.getRunDir().mkdirs();
    }

    private void copyProotFromAssets() throws IOException {
        File prootDest = new File(paths.getRuntimeBinDir(), "proot");
        if (prootDest.exists()) {
            Log.i(TAG, "proot already exists");
            return;
        }

        try (InputStream in = context.getAssets().open(ASSETS_RUNTIME_DIR + "/proot");
             OutputStream out = new FileOutputStream(prootDest)) {
            byte[] buffer = new byte[8192];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
        }

        prootDest.setExecutable(true, false);
        Log.i(TAG, "Copied proot binary to " + prootDest.getAbsolutePath());
    }

    private void copyScriptsFromAssets() throws IOException {
        AssetManager assets = context.getAssets();
        String[] scripts = assets.list(ASSETS_SCRIPTS_DIR);
        if (scripts == null || scripts.length == 0) {
            Log.w(TAG, "No scripts found in assets/" + ASSETS_SCRIPTS_DIR);
            return;
        }

        for (String script : scripts) {
            File destFile = new File(paths.getScriptsDir(), script);
            // Always copy scripts to ensure updates are applied
            try (InputStream in = assets.open(ASSETS_SCRIPTS_DIR + "/" + script);
                 OutputStream out = new FileOutputStream(destFile)) {
                byte[] buffer = new byte[4096];
                int read;
                while ((read = in.read(buffer)) != -1) {
                    out.write(buffer, 0, read);
                }
            }

            destFile.setExecutable(true, false);
            Log.i(TAG, "Copied script: " + script);
        }
    }
}
