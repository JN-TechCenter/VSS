@echo off
chcp 65001 >nul 2>&1
echo 🔧 修复脚本编码显示问题
echo ========================

REM 设置控制台为UTF-8编码
chcp 65001

echo ✅ 控制台编码已设置为 UTF-8 (代码页 65001)
echo.
echo 📋 脚本编码修复完成！
echo.
echo 使用说明:
echo 1. 运行此脚本修复编码显示问题
echo 2. 之后运行其他脚本应该能正常显示中文
echo 3. 如果问题仍存在，请检查终端设置
echo.

pause
