#!/usr/bin/env python3
"""
YOLO推理服务测试脚本 - 直接在宿主机上运行
"""
import os
import sys
import time
import cv2
import numpy as np
import requests
import json
from pathlib import Path

# 测试配置
TEST_IMAGE_PATH = r"d:\VSS-home\VSS\inference-server\test_image.jpg"
SERVER_URL = "http://localhost:8084"

def test_server_health():
    """测试服务器健康状态"""
    try:
        response = requests.get(f"{SERVER_URL}/health", timeout=5)
        print(f"健康检查: {response.status_code}")
        if response.status_code == 200:
            print("服务器健康状态:", json.dumps(response.json(), indent=2, ensure_ascii=False))
            return True
        else:
            print(f"服务器不健康: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"无法连接到服务器: {e}")
        return False

def test_server_info():
    """测试服务器信息端点"""
    try:
        response = requests.get(f"{SERVER_URL}/info", timeout=5)
        print(f"服务器信息: {response.status_code}")
        if response.status_code == 200:
            print("服务器信息:", json.dumps(response.json(), indent=2, ensure_ascii=False))
            return True
        else:
            print(f"获取服务器信息失败: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"无法获取服务器信息: {e}")
        return False

def test_image_prediction():
    """测试图像预测"""
    if not os.path.exists(TEST_IMAGE_PATH):
        print(f"测试图像不存在: {TEST_IMAGE_PATH}")
        return False
    
    try:
        # 读取测试图像
        with open(TEST_IMAGE_PATH, 'rb') as f:
            files = {'image': f}
            response = requests.post(f"{SERVER_URL}/predict", files=files, timeout=30)
        
        print(f"图像预测: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print("预测结果:", json.dumps(result, indent=2, ensure_ascii=False))
            return True
        else:
            print(f"图像预测失败: {response.status_code}")
            print("错误信息:", response.text)
            return False
    except requests.exceptions.RequestException as e:
        print(f"图像预测请求失败: {e}")
        return False

def test_models_list():
    """测试模型列表端点"""
    try:
        response = requests.get(f"{SERVER_URL}/models", timeout=5)
        print(f"模型列表: {response.status_code}")
        if response.status_code == 200:
            models = response.json()
            print("可用模型:", json.dumps(models, indent=2, ensure_ascii=False))
            return True
        else:
            print(f"获取模型列表失败: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"无法获取模型列表: {e}")
        return False

def create_test_image():
    """创建一个测试图像"""
    if not os.path.exists(TEST_IMAGE_PATH):
        print("创建测试图像...")
        # 创建一个简单的测试图像
        image = np.random.randint(0, 255, (640, 640, 3), dtype=np.uint8)
        cv2.imwrite(TEST_IMAGE_PATH, image)
        print(f"测试图像已创建: {TEST_IMAGE_PATH}")

def main():
    """主测试函数"""
    print("=" * 50)
    print("YOLO推理服务测试")
    print("=" * 50)
    
    # 创建测试图像（如果不存在）
    create_test_image()
    
    # 测试各个端点
    tests = [
        ("服务器健康检查", test_server_health),
        ("服务器信息", test_server_info),
        ("模型列表", test_models_list),
        ("图像预测", test_image_prediction),
    ]
    
    results = {}
    for test_name, test_func in tests:
        print(f"\n--- {test_name} ---")
        try:
            result = test_func()
            results[test_name] = "通过" if result else "失败"
        except Exception as e:
            print(f"测试异常: {e}")
            results[test_name] = f"异常: {e}"
    
    # 输出测试结果总结
    print("\n" + "=" * 50)
    print("测试结果总结:")
    print("=" * 50)
    for test_name, result in results.items():
        status = "✅" if result == "通过" else "❌"
        print(f"{status} {test_name}: {result}")
    
    return all(result == "通过" for result in results.values())

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
