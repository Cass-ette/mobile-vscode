package com.mobilevscode;

import java.io.File;
import java.util.Map;

/**
 * Provides a consistent way to run external scripts and processes within the app-owned runtime.
 *
 * Handles environment variable injection, shell resolution (app-owned runtime or system fallback),
 * and common process setup patterns (working directory, error stream merging, log redirection).
 */
public class ProcessRunner {

    /**
     * Resolve the preferred shell to use for running scripts.
     *
     * Priority:
     * 1. App-owned runtime shell (runtime/bin/sh) if it exists
     * 2. System shell (/system/bin/sh) as fallback
     *
     * @param paths RuntimePaths for locating the app-owned shell
     * @return absolute path to the shell executable
     */
    public static String resolveShell(RuntimePaths paths) {
        File runtimeSh = new File(paths.getRuntimeBinDir(), "sh");
        if (runtimeSh.exists() && runtimeSh.canExecute()) {
            return runtimeSh.getAbsolutePath();
        }
        return "/system/bin/sh";
    }

    /**
     * Create a ProcessBuilder for executing a script.
     *
     * The returned builder has:
     * - Environment variables from RuntimePaths injected
     * - Error stream redirected to output stream for unified logging
     * - Working directory set to the scripts directory
     *
     * @param paths RuntimePaths for shell resolution and env injection
     * @param scriptFile the script to execute
     * @return configured ProcessBuilder
     */
    public static ProcessBuilder createScriptProcessBuilder(RuntimePaths paths, File scriptFile) {
        String shell = resolveShell(paths);
        ProcessBuilder pb = new ProcessBuilder(shell, scriptFile.getAbsolutePath());
        pb.directory(paths.getScriptsDir());
        pb.redirectErrorStream(true);

        Map<String, String> env = pb.environment();
        env.putAll(RuntimePaths.buildEnvironment(paths));

        return pb;
    }

    /**
     * Start a script process with the configured environment.
     *
     * @param paths RuntimePaths for shell/env
     * @param scriptFile script to execute
     * @return started Process
     * @throws java.io.IOException if the process fails to start
     */
    public static java.lang.Process startScript(RuntimePaths paths, File scriptFile) throws java.io.IOException {
        return createScriptProcessBuilder(paths, scriptFile).start();
    }
}
