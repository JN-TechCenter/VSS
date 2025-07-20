# 🔧 VSS 编码问题解决方案

## 问题描述
Windows 批处理脚本在显示中文字符时出现乱码或"was unexpected at this time"错误。

## 解决方案

### 1. 字符编码修复
- 在所有 `.bat` 脚本开头添加 `chcp 65001 >nul 2>&1`
- 确保控制台使用 UTF-8 编码（代码页 65001）

### 2. 批处理语法优化
- 移除括号 `()` 中包含特殊字符的描述
- 简化中文描述，避免复杂字符组合
- 使用英文标记替代特殊符号

### 3. 修复内容

#### 原问题：
```bat
echo   proxy        - Start proxy mode (推荐)
echo   dev-proxy    - Start development with proxy + hot reload (⭐开发推荐⭐)
```

#### 修复后：
```bat
@echo off
chcp 65001 >nul 2>&1

echo   proxy        - Start proxy mode [recommended] 
echo   dev-proxy    - Start development with proxy + hot reload [dev recommended]
```

### 4. 已修复的脚本
- ✅ `scripts/docker-manage.bat` - 主要的 Docker 管理脚本
- ✅ `scripts/fix-encoding.bat` - 编码修复工具脚本

### 5. 验证结果
```cmd
scripts\docker-manage.bat help
```
现在可以正确显示帮助信息，无编码错误。

## 使用建议

1. **首次使用**：运行 `scripts\fix-encoding.bat` 确保编码设置
2. **日常使用**：直接使用修复后的脚本
3. **新脚本**：参考 `docker-manage.bat` 的编码设置模板

## 编码最佳实践

### 脚本模板：
```bat
@echo off
chcp 65001 >nul 2>&1
REM Your script description

REM Script content here...
```

### 避免的字符：
- 特殊符号：⭐ ✅ ❌ 🔥 等
- 复杂括号组合：`(推荐)` → `[recommended]`
- 长句中文描述

### 推荐用法：
- 使用简洁的英文标记
- 中文描述独立成行
- 避免在 echo 语句中混合特殊字符

---
*最后更新: 2025-01-20*
