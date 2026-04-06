package com.mobilevscode;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import java.io.File;
import java.util.Map;

public class RuntimePathsTest {

    @Test
    public void createsExpectedAppPrivateDirectoryContract() {
        RuntimePaths paths = RuntimePaths.fromFilesDir(new File("/data/user/0/com.mobilevscode/files"));

        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env", paths.getBaseDir().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/ubuntu-rootfs", paths.getRootfsDir().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/code-server", paths.getCodeServerDir().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/vscode-data", paths.getVscodeDataDir().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/workspace", paths.getWorkspaceDir().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/logs", paths.getLogsDir().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/scripts", paths.getScriptsDir().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/runtime/bin", paths.getRuntimeBinDir().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/run/code-server.pid", paths.getPidFile().getAbsolutePath());
        assertEquals("/data/user/0/com.mobilevscode/files/mobile-dev-env/install.complete", paths.getInstallMarkerFile().getAbsolutePath());
    }

    @Test
    public void exposesScriptEnvironmentForBootstrapAndLifecycleScripts() {
        RuntimePaths paths = RuntimePaths.fromFilesDir(new File("/data/user/0/com.mobilevscode/files"));

        Map<String, String> env = ProcessRunner.buildEnvironment(paths);

        assertEquals(paths.getBaseDir().getAbsolutePath(), env.get("BASE_DIR"));
        assertEquals(paths.getRootfsDir().getAbsolutePath(), env.get("ROOTFS_DIR"));
        assertEquals(paths.getCodeServerDir().getAbsolutePath(), env.get("CODE_SERVER_DIR"));
        assertEquals(paths.getScriptsDir().getAbsolutePath(), env.get("SCRIPTS_DIR"));
        assertEquals(paths.getRuntimeBinDir().getAbsolutePath(), env.get("RUNTIME_BIN_DIR"));
        assertEquals(paths.getPidFile().getAbsolutePath(), env.get("PID_FILE"));
        assertEquals(paths.getInstallMarkerFile().getAbsolutePath(), env.get("INSTALL_MARKER"));
        assertEquals(paths.getCodeServerLogFile().getAbsolutePath(), env.get("CODE_SERVER_LOG"));
        assertEquals("8080", env.get("CODE_SERVER_PORT"));
        assertTrue(env.get("PATH").startsWith(paths.getRuntimeBinDir().getAbsolutePath()));
    }
}
