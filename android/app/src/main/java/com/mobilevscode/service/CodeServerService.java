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
import com.mobilevscode.ProcessRunner;
import com.mobilevscode.R;
import com.mobilevscode.RuntimePaths;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;

public class CodeServerService extends Service {

    private static final String CHANNEL_ID = "codeserver_channel";
    private static final int NOTIFICATION_ID = 1;

    private RuntimePaths paths;
    private Process codeServerProcess;
    private Thread logThread;

    @Override
    public void onCreate() {
        super.onCreate();
        paths = RuntimePaths.fromFilesDir(getFilesDir());
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
                File startScript = new File(paths.getScriptsDir(), "start.sh");
                ProcessBuilder pb = ProcessRunner.createScriptProcessBuilder(paths, startScript);
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
            File stopScript = new File(paths.getScriptsDir(), "stop.sh");
            ProcessBuilder pb = ProcessRunner.createScriptProcessBuilder(paths, stopScript);
            pb.start();

        } catch (Exception e) {
            android.util.Log.e("CodeServer", "Error stopping service", e);
        }
    }
}
