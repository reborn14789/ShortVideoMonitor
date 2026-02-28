package com.example.shortvideomonitor;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.app.AppOpsManager;
import android.os.Process;

public class MainActivity extends AppCompatActivity {

    private TextView tvStatus, tvCurrentApp, tvUsageTime;
    private Button btnStart, btnStop, btnOverlayPermission, btnUsagePermission, btnSelectApps;
    private EditText etTimeLimit;
    private Switch switchNotification;
    
    private boolean isMonitoring = false;
    private static final int OVERLAY_PERMISSION_REQUEST = 1001;
    
    // 短视频应用包名列表
    private static final String[] VIDEO_APPS = {
            "com.ss.android.ugc.aweme",     // 抖音
            "com.kuaishou.nebula",          // 快手
            "tv.danmaku.bili",              // 哔哩哔哩
            "com.google.android.youtube"    // YouTube (包含Shorts)
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        initViews();
        setupClickListeners();
        checkPermissions();
    }

    private void initViews() {
        tvStatus = findViewById(R.id.tvStatus);
        tvCurrentApp = findViewById(R.id.tvCurrentApp);
        tvUsageTime = findViewById(R.id.tvUsageTime);
        btnStart = findViewById(R.id.btnStart);
        btnStop = findViewById(R.id.btnStop);
        btnOverlayPermission = findViewById(R.id.btnOverlayPermission);
        btnUsagePermission = findViewById(R.id.btnUsagePermission);
        btnSelectApps = findViewById(R.id.btnSelectApps);
        etTimeLimit = findViewById(R.id.etTimeLimit);
        switchNotification = findViewById(R.id.switchNotification);
    }

    private void setupClickListeners() {
        btnStart.setOnClickListener(v -> startMonitoring());
        btnStop.setOnClickListener(v -> stopMonitoring());
        
        btnOverlayPermission.setOnClickListener(v -> requestOverlayPermission());
        btnUsagePermission.setOnClickListener(v -> requestUsageStatsPermission());
        
        btnSelectApps.setOnClickListener(v -> {
            // 这里可以打开应用选择对话框
            Toast.makeText(this, "应用选择功能待实现", Toast.LENGTH_SHORT).show();
        });
    }

    private void checkPermissions() {
        boolean hasOverlayPermission = hasOverlayPermission();
        boolean hasUsageStatsPermission = hasUsageStatsPermission();
        
        if (hasOverlayPermission && hasUsageStatsPermission) {
            btnOverlayPermission.setVisibility(View.GONE);
            btnUsagePermission.setVisibility(View.GONE);
        } else {
            if (!hasOverlayPermission) {
                btnOverlayPermission.setVisibility(View.VISIBLE);
            }
            if (!hasUsageStatsPermission) {
                btnUsagePermission.setVisibility(View.VISIBLE);
            }
        }
    }

    private boolean hasOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.canDrawOverlays(this);
        }
        return true;
    }

    private boolean hasUsageStatsPermission() {
        AppOpsManager appOps = (AppOpsManager) getSystemService(Context.APP_OPS_SERVICE);
        int mode = appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                getPackageName()
        );
        return mode == AppOpsManager.MODE_ALLOWED;
    }

    private void requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:" + getPackageName()));
            startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST);
        }
    }

    private void requestUsageStatsPermission() {
        Intent intent = new Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS);
        startActivity(intent);
    }

    private void startMonitoring() {
        if (!hasOverlayPermission() || !hasUsageStatsPermission()) {
            Toast.makeText(this, "请先授予所有权限", Toast.LENGTH_SHORT).show();
            return;
        }
        
        isMonitoring = true;
        tvStatus.setText(R.string.status_monitoring);
        btnStart.setEnabled(false);
        btnStop.setEnabled(true);
        
        // 启动监测服务
        Intent serviceIntent = new Intent(this, VideoMonitorService.class);
        serviceIntent.putExtra("TIME_LIMIT", Integer.parseInt(etTimeLimit.getText().toString()));
        serviceIntent.putExtra("ENABLE_NOTIFICATION", switchNotification.isChecked());
        startService(serviceIntent);
        
        Toast.makeText(this, "监测已启动", Toast.LENGTH_SHORT).show();
    }

    private void stopMonitoring() {
        isMonitoring = false;
        tvStatus.setText(R.string.status_stopped);
        btnStart.setEnabled(true);
        btnStop.setEnabled(false);
        
        // 停止监测服务
        Intent serviceIntent = new Intent(this, VideoMonitorService.class);
        stopService(serviceIntent);
        
        // 停止悬浮窗服务
        Intent overlayIntent = new Intent(this, OverlayService.class);
        stopService(overlayIntent);
        
        tvCurrentApp.setText("当前应用：无");
        tvUsageTime.setText("使用时间：0秒");
        
        Toast.makeText(this, "监测已停止", Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == OVERLAY_PERMISSION_REQUEST) {
            checkPermissions();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (isMonitoring) {
            stopMonitoring();
        }
    }
    
    // 供服务调用的更新UI方法
    public void updateAppInfo(String appName, long usageTime) {
        runOnUiThread(() -> {
            tvCurrentApp.setText("当前应用：" + (appName != null ? appName : "无"));
            tvUsageTime.setText("使用时间：" + (usageTime / 1000) + "秒");
        });
    }
}