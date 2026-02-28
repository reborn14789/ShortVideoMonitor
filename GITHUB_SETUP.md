package com.example.shortvideomonitor;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

public class OverlayService extends Service {

    private WindowManager windowManager;
    private View overlayView;
    private Handler handler;
    
    private static final int AUTO_CLOSE_DELAY = 10000; // 10秒后自动关闭

    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        handler = new Handler();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        showOverlay(intent);
        return START_NOT_STICKY;
    }

    private void showOverlay(Intent intent) {
        // 移除已有的悬浮窗
        removeOverlay();
        
        // 创建悬浮窗布局
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        overlayView = inflater.inflate(R.layout.alert_overlay, null);
        
        // 设置弹窗内容
        TextView tvMessage = overlayView.findViewById(R.id.tvAlertMessage);
        if (intent != null && intent.hasExtra("TIME_LIMIT")) {
            int timeLimit = intent.getIntExtra("TIME_LIMIT", 3);
            String message = "您已经在竖屏短视频上连续使用超过" + timeLimit + "分钟，请注意休息！";
            tvMessage.setText(message);
        }
        
        // 设置按钮点击事件
        Button btnClose = overlayView.findViewById(R.id.btnCloseAlert);
        Button btnSnooze = overlayView.findViewById(R.id.btnSnoozeAlert);
        
        btnClose.setOnClickListener(v -> {
            removeOverlay();
            stopSelf();
        });
        
        btnSnooze.setOnClickListener(v -> {
            removeOverlay();
            Toast.makeText(this, "5分钟后会再次提醒", Toast.LENGTH_SHORT).show();
            // 设置5分钟后再次提醒的逻辑
            handler.postDelayed(() -> {
                Intent newIntent = new Intent(this, OverlayService.class);
                if (intent != null) {
                    newIntent.putExtra("TIME_LIMIT", intent.getIntExtra("TIME_LIMIT", 3));
                }
                startService(newIntent);
            }, 5 * 60 * 1000); // 5分钟
            stopSelf();
        });
        
        // 设置窗口参数
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                        WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL |
                        WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT);
        
        params.gravity = Gravity.CENTER;
        params.x = 0;
        params.y = 0;
        
        // 添加悬浮窗
        try {
            windowManager.addView(overlayView, params);
            
            // 10秒后自动关闭
            handler.postDelayed(() -> {
                removeOverlay();
                stopSelf();
            }, AUTO_CLOSE_DELAY);
            
        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(this, "无法显示弹窗，请检查悬浮窗权限", Toast.LENGTH_LONG).show();
        }
    }

    private void removeOverlay() {
        if (overlayView != null && windowManager != null) {
            try {
                windowManager.removeView(overlayView);
                overlayView = null;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        removeOverlay();
        handler.removeCallbacksAndMessages(null);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}