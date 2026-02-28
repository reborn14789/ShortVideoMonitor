# 短视频时间监测器

一个Android应用，用于监测用户在竖屏短视频应用上的使用时间，超过设定时间（默认3分钟）会弹窗提醒。

## 功能特性

- ✅ 实时监测短视频应用使用时间
- ✅ 支持抖音、快手、哔哩哔哩、YouTube Shorts等主流短视频应用
- ✅ 可自定义时间限制（分钟）
- ✅ 超过时间限制时显示悬浮窗弹窗提醒
- ✅ 支持关闭提示或延迟提醒
- ✅ 实时显示当前应用和使用时间
- ✅ 简洁美观的用户界面

## 支持的短视频应用

- 抖音 (com.ss.android.ugc.aweme)
- 快手 (com.kuaishou.nebula)
- 哔哩哔哩 (tv.danmaku.bili)
- YouTube (com.google.android.youtube)

## 所需权限

1. **悬浮窗权限** - 用于显示弹窗提醒
2. **使用情况统计权限** - 用于监测应用使用情况

## 使用方法

### 1. 安装和设置

1. 在Android Studio中打开项目
2. 连接Android设备或启动模拟器（API 23+）
3. 构建并运行应用

### 2. 授予权限

首次运行应用时：
1. 点击"悬浮窗权限"按钮，在系统设置中开启权限
2. 点击"使用情况统计权限"按钮，在系统设置中开启权限

### 3. 开始监测

1. 设置时间限制（默认3分钟）
2. 可选择是否启用通知
3. 点击"开始监测"按钮
4. 应用将在后台监测短视频使用情况

### 4. 弹窗提醒

当在短视频应用上连续使用超过设定时间时：
- 会显示一个悬浮窗弹窗提醒
- 可选择"关闭提示"立即关闭
- 可选择"5分钟后提醒"延迟提醒
- 弹窗会在10秒后自动关闭

## 项目结构

```
ShortVideoMonitor/
├── app/
│   ├── src/main/java/com/example/shortvideomonitor/
│   │   ├── MainActivity.java          # 主活动
│   │   ├── VideoMonitorService.java   # 监测服务
│   │   └── OverlayService.java        # 悬浮窗服务
│   ├── src/main/res/
│   │   ├── layout/                    # 布局文件
│   │   ├── values/                    # 资源文件
│   │   └── drawable/                  # 图形资源
│   └── build.gradle                   # 模块构建配置
├── build.gradle                       # 项目构建配置
├── settings.gradle                    # 项目设置
└── README.md                          # 说明文档
```

## 技术实现

### 核心功能

1. **应用使用监测**
   - 使用`UsageStatsManager`获取前台应用信息
   - 每秒检查一次当前应用
   - 识别短视频应用包名

2. **时间计算**
   - 记录进入短视频应用的时间戳
   - 实时计算使用时长
   - 超过阈值时触发提醒

3. **悬浮窗弹窗**
   - 使用`WindowManager`创建悬浮窗
   - 支持触摸交互
   - 自动关闭机制

### 注意事项

1. **Android版本要求**
   - 最低支持Android 6.0 (API 23)
   - 需要`SYSTEM_ALERT_WINDOW`和`PACKAGE_USAGE_STATS`权限

2. **电池优化**
   - 应用使用前台服务进行监测
   - 建议将应用添加到电池优化白名单

3. **权限说明**
   - 使用情况统计权限需要用户手动在系统设置中开启
   - 悬浮窗权限需要用户手动授权

## 自定义配置

### 添加更多短视频应用

在`VideoMonitorService.java`中修改`VIDEO_APPS`数组：

```java
private static final String[] VIDEO_APPS = {
    "com.ss.android.ugc.aweme",     // 抖音
    "com.kuaishou.nebula",          // 快手
    "tv.danmaku.bili",              // 哔哩哔哩
    "com.google.android.youtube",   // YouTube
    // 添加更多应用包名
    "com.example.videoapp"          // 其他短视频应用
};
```

### 修改默认设置

在`MainActivity.java`中：
- 默认时间限制：`etTimeLimit.setText("3")`
- 默认启用通知：`switchNotification.setChecked(true)`

## 构建说明

### 使用Android Studio

1. 打开Android Studio
2. 选择"Open an Existing Project"
3. 选择`ShortVideoMonitor`文件夹
4. 等待Gradle同步完成
5. 连接设备或启动模拟器
6. 点击运行按钮

### 使用命令行

```bash
# 进入项目目录
cd ShortVideoMonitor

# 清理构建
./gradlew clean

# 构建APK
./gradlew assembleDebug

# 安装到设备
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 问题排查

### 常见问题

1. **无法监测应用使用情况**
   - 检查是否已授予"使用情况统计"权限
   - 重启应用后重试

2. **弹窗不显示**
   - 检查是否已授予"悬浮窗"权限
   - 检查应用是否在后台运行

3. **监测服务停止**
   - 检查电池优化设置
   - 将应用添加到后台运行白名单

### 日志查看

应用使用`Log.d(TAG, ...)`输出日志，可通过以下命令查看：

```bash
adb logcat -s VideoMonitorService
adb logcat -s OverlayService
```

## 未来改进方向

1. **更多自定义选项**
   - 自定义弹窗样式
   - 选择监测的应用列表
   - 设置不同的时间限制

2. **统计功能**
   - 每日/每周使用统计
   - 使用趋势分析
   - 导出使用报告

3. **高级功能**
   - 应用锁定功能
   - 休息提醒
   - 家长控制模式

## 许可证

本项目仅供学习参考，可根据需要自由修改和使用。

## 联系信息

如有问题或建议，请通过项目仓库提交Issue。