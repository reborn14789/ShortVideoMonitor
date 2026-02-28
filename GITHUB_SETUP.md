# GitHub自动构建APK指南

## 步骤1：创建GitHub仓库
1. 访问 https://github.com 并登录/注册
2. 点击右上角 "+" → "New repository"
3. 仓库名：`ShortVideoMonitor`
4. 选择 "Public" 或 "Private"
5. 不要初始化README.md（我们已经有文件了）
6. 点击 "Create repository"

## 步骤2：上传文件到GitHub
### 方法A：使用GitHub网页上传
1. 在新建的仓库页面，点击 "Add file" → "Upload files"
2. 将本文件夹中的所有文件拖拽到上传区域
3. 点击 "Commit changes"

### 方法B：使用Git命令行
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/你的用户名/ShortVideoMonitor.git
git push -u origin main
```

## 步骤3：触发构建
1. 进入仓库的 "Actions" 标签页
2. 点击 "Android Build" 工作流
3. 点击 "Run workflow" → "Run workflow"

## 步骤4：下载APK
构建完成后（约5-10分钟）：
1. 在 "Actions" 页面查看构建结果
2. 点击成功的构建
3. 在 "Artifacts" 部分下载 `app-debug-apk.zip`
4. 解压得到 `app-debug.apk` 文件

## 步骤5：安装到手机
1. 将 `app-debug.apk` 传输到小米手机
2. 在手机上找到文件并点击安装
3. 如果提示"禁止安装未知来源应用"：
   - 点击"设置"
   - 允许"安装未知应用"
4. 安装完成后打开应用
5. 按照应用提示授予权限

## 注意事项
- 首次构建可能需要较长时间（下载依赖）
- 确保手机Android版本 >= 6.0 (API 23)
- 需要授予"悬浮窗"和"使用情况统计"权限

## 问题排查
如果构建失败：
1. 检查 "Actions" 页面的错误信息
2. 确保所有文件已正确上传
3. 可能需要调整Android SDK版本

## 替代方案
如果GitHub构建太复杂，可以考虑：
1. 使用本地Android Studio构建
2. 使用其他在线构建服务
3. 寻找现成的类似应用