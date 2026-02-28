package com.example.shortvideomonitor;

import android.app.Service;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;

public class VideoMonitorService extends Service {

    private static final String TAG = "VideoMonitorService";
    private static final long CHECK_INTERVAL = 1000; // 1秒检查一次
    
    private Handler handler;
    private Runnable monitorRunnable;
    
    private String currentVideoApp = null;
    private long startTime = 0;
    private long timeLimit = 3 * 60 * 1000; // 默认3分钟
    private boolean enableNotification = true;
    
    // 短视频应用包名列表
    private static final String[] VIDEO_APPS = {
            "com.ss.android.ugc.aweme",     // 抖音
            "com.kuaishou.nebula",          // 快手
            "tv.danmaku.bili",              // 哔哩哔哩
            "com.google.android.youtube"    // YouTube
    };

    @Override
    public void onCreate() {
        super.onCreate();
        handler = new Handler(Looper.getMainLooper());
        Log.d(TAG, "VideoMonitorService created");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            timeLimit = intent.getIntExtra("TIME_LIMIT", 3) * 60 * 1000;
            enableNotification = intent.getBooleanExtra("ENABLE_NOTIFICATION", true);
            Log.d(TAG, "Time limit: " + (timeLimit / 60000) + " minutes");
        }
        
        startMonitoring();
        return START_STICKY;
    }

    private void startMonitoring() {
        if (monitorRunnable != null) {
            handler.removeCallbacks(monitorRunnable);
        }
        
        monitorRunnable = new Runnable() {
            @Override
            public void run() {
                checkCurrentApp();
                handler.postDelayed(this, CHECK_INTERVAL);
            }
        };
        
        handler.post(monitorRunnable);
        Log.d(TAG, "Monitoring started");
    }

    private void checkCurrentApp() {
        String foregroundApp = getForegroundApp();
        
        if (foregroundApp == null) {
            if (currentVideoApp != null) {
                // 离开了短视频应用
                currentVideoApp = null;
                startTime = 0;
                updateUI(null, 0);
                Log.d(TAG, "Left video app");
            }
            return;
        }
        
        boolean isVideoApp = isVideoApp(foregroundApp);
        
        if (isVideoApp) {
            if (currentVideoApp == null || !currentVideoApp.equals(foregroundApp)) {
                // 新打开或切换到另一个短视频应用
                currentVideoApp = foregroundApp;
                startTime = System.currentTimeMillis();
                Log.d(TAG, "Started using video app: " + getAppName(foregroundApp));
            }
            
            long usageTime = System.currentTimeMillis() - startTime;
            updateUI(getAppName(foregroundApp), usageTime);
            
            // 检查是否超过时间限制
            if (usageTime >= timeLimit) {
                showAlert();
                // 重置计时器，避免连续弹窗
                startTime = System.currentTimeMillis();
            }
        } else {
            if (currentVideoApp != null) {
                // 切换到非短视频应用
                currentVideoApp = null;
                startTime = 0;
                updateUI(null, 0);
                Log.d(TAG, "Switched to non-video app");
            }
        }
    }

    private String getForegroundApp() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            UsageStatsManager usageStatsManager = (UsageStatsManager) 
                    getSystemService(Context.USAGE_STATS_SERVICE);
            
            long time = System.currentTimeMillis();
            List<UsageStats> stats = usageStatsManager.queryUsageStats(
                    UsageStatsManager.INTERVAL_DAILY, time - 1000 * 10, time);
            
            if (stats != null && !stats.isEmpty()) {
                SortedMap<Long, UsageStats> sortedMap = new TreeMap<>();
                for (UsageStats usageStats : stats) {
                    sortedMap.put(usageStats.getLastTimeUsed(), usageStats);
                }
                
                if (!sortedMap.isEmpty()) {
                    String packageName = sortedMap.get(sortedMap.lastKey()).getPackageName();
                    return packageName;
                }
            }
        }
        return null;
    }

    private boolean isVideoApp(String packageName) {
        for (String videoApp : VIDEO_APPS) {
            if (videoApp.equals(packageName)) {
                return true;
            }
        }
        return false;
    }

    private String getAppName(String packageName) {
        try {
            PackageManager pm = getPackageManager();
            ApplicationInfo ai = pm.getApplicationInfo(packageName, 0);
            return pm.getApplicationLabel(ai).toString();
        } catch (PackageManager.NameNotFoundException e) {
            return packageName;
        }
    }

    private void updateUI(String appName, long usageTime) {
        // 通知主活动更新UI
        Intent updateIntent = new Intent("UPDATE_APP_INFO");
        updateIntent.putExtra("app_name", appName);
        updateIntent.putExtra("usage_time", usageTime);
        sendBroadcast(updateIntent);
    }

    private void showAlert() {
        Log.d(TAG, "Time limit exceeded, showing alert");
        
        if (enableNotification) {
            // 显示Toast通知
            handler.post(() -> {
                Toast.makeText(VideoMonitorService.this, 
                        "您已经在短视频上连续使用超过" + (timeLimit / 60000) + "分钟，请注意休息！",
                        Toast.LENGTH_LONG).show();
            });
        }
        
        // 启动悬浮窗服务显示弹窗
        Intent overlayIntent = new Intent(this, OverlayService.class);
        overlayIntent.putExtra("TIME_LIMIT", timeLimit / 60000);
        startService(overlayIntent);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (monitorRunnable != null) {
            handler.removeCallbacks(monitorRunnable);
        }
        Log.d(TAG, "VideoMonitorService destroyed");
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}