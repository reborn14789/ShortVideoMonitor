name: Build Android APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # 允许手动触发

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Grant execute permission for gradlew
      run: chmod +x gradlew
    
    - name: Build with Gradle
      run: ./gradlew assembleDebug
    
    - name: Upload APK artifact
      uses: actions/upload-artifact@v3
      with:
        name: app-debug-apk
        path: app/build/outputs/apk/debug/app-debug.apk
    
    - name: Create release with APK
      if: github.event_name == 'workflow_dispatch' || github.ref == 'refs/heads/main'
      uses: softprops/action-gh-release@v1
      with:
        files: app/build/outputs/apk/debug/app-debug.apk
        tag_name: v1.0.0
        name: Release v1.0.0
        body: |
          Auto-built APK from GitHub Actions
          
          ### 安装说明
          1. 下载 `app-debug.apk`
          2. 在Android手机上安装
          3. 授予所需权限
        draft: false
        prerelease: false