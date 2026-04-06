package com.mobilevscode;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Centralizes all app-private runtime paths under Context.getFilesDir().
 *
 * This class provides deterministic path resolution for the bootstrap runtime,
 * code-server, rootfs, workspace, logs, and lifecycle markers.
 */
public class RuntimePaths {
    private static final String BASE_DIR_NAME = "mobile-dev-env";
    private static final String CODE_SERVER_PORT = "8080";

    private final File baseDir;
    private final File rootfsDir;
    private final File codeServerDir;
    private final File vscodeDataDir;
    private final File workspaceDir;
    private final File logsDir;
    private final File scriptsDir;
    private final File runtimeBinDir;
    private final File runDir;
    private final File configDir;
    private final File pidFile;
    private final File installMarkerFile;
    private final File codeServerLogFile;

    private RuntimePaths(File filesDir) {
        this.baseDir = new File(filesDir, BASE_DIR_NAME);
        this.rootfsDir = new File(baseDir, "ubuntu-rootfs");
        this.codeServerDir = new File(baseDir, "code-server");
        this.vscodeDataDir = new File(baseDir, "vscode-data");
        this.workspaceDir = new File(baseDir, "workspace");
        this.logsDir = new File(baseDir, "logs");
        this.scriptsDir = new File(baseDir, "scripts");
        this.runtimeBinDir = new File(baseDir, "runtime/bin");
        this.runDir = new File(baseDir, "run");
        this.configDir = new File(baseDir, "config");
        this.pidFile = new File(runDir, "code-server.pid");
        this.installMarkerFile = new File(baseDir, "install.complete");
        this.codeServerLogFile = new File(logsDir, "code-server.log");
    }

    /**
     * Create a RuntimePaths instance derived from the application files directory.
     *
     * @param filesDir typically from Context.getFilesDir()
     * @return configured RuntimePaths
     */
    public static RuntimePaths fromFilesDir(File filesDir) {
        return new RuntimePaths(filesDir);
    }

    public File getBaseDir() {
        return baseDir;
    }

    public File getRootfsDir() {
        return rootfsDir;
    }

    public File getCodeServerDir() {
        return codeServerDir;
    }

    public File getVscodeDataDir() {
        return vscodeDataDir;
    }

    public File getWorkspaceDir() {
        return workspaceDir;
    }

    public File getLogsDir() {
        return logsDir;
    }

    public File getScriptsDir() {
        return scriptsDir;
    }

    public File getRuntimeBinDir() {
        return runtimeBinDir;
    }

    public File getRunDir() {
        return runDir;
    }

    public File getConfigDir() {
        return configDir;
    }

    public File getPidFile() {
        return pidFile;
    }

    public File getInstallMarkerFile() {
        return installMarkerFile;
    }

    public File getCodeServerLogFile() {
        return codeServerLogFile;
    }

    /**
     * Build the environment variables expected by bootstrap and lifecycle scripts.
     *
     * @param paths RuntimePaths instance
     * @return map of environment variable names to values
     */
    public static Map<String, String> buildEnvironment(RuntimePaths paths) {
        Map<String, String> env = new HashMap<>();
        env.put("BASE_DIR", paths.getBaseDir().getAbsolutePath());
        env.put("ROOTFS_DIR", paths.getRootfsDir().getAbsolutePath());
        env.put("CODE_SERVER_DIR", paths.getCodeServerDir().getAbsolutePath());
        env.put("VSCODE_DATA_DIR", paths.getVscodeDataDir().getAbsolutePath());
        env.put("WORKSPACE_DIR", paths.getWorkspaceDir().getAbsolutePath());
        env.put("LOGS_DIR", paths.getLogsDir().getAbsolutePath());
        env.put("SCRIPTS_DIR", paths.getScriptsDir().getAbsolutePath());
        env.put("RUNTIME_BIN_DIR", paths.getRuntimeBinDir().getAbsolutePath());
        env.put("CONFIG_DIR", paths.getConfigDir().getAbsolutePath());
        env.put("PID_FILE", paths.getPidFile().getAbsolutePath());
        env.put("INSTALL_MARKER", paths.getInstallMarkerFile().getAbsolutePath());
        env.put("CODE_SERVER_LOG", paths.getCodeServerLogFile().getAbsolutePath());
        env.put("CODE_SERVER_PORT", CODE_SERVER_PORT);
        return env;
    }
}
