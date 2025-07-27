#!/usr/bin/env python3
"""
VSS 推理历史功能简化测试脚本
直接测试AI推理服务和基础功能
"""

import requests
import json
import time
from datetime import datetime

# 配置
AI_SERVICE_URL = "http://localhost:8000"

def test_ai_service():
    """测试AI推理服务"""
    print("🤖 测试AI推理服务...")
    
    # 1. 测试健康检查
    print("\n1. 测试健康检查")
    try:
        response = requests.get(f"{AI_SERVICE_URL}/health")
        if response.status_code == 200:
            health_data = response.json()
            print(f"✅ AI服务健康检查成功")
            print(f"   状态: {health_data.get('status', 'unknown')}")
            print(f"   服务: {health_data.get('service', 'unknown')}")
            print(f"   版本: {health_data.get('version', 'unknown')}")
        else:
            print(f"❌ 健康检查失败: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 健康检查请求失败: {e}")
        return False
    
    # 2. 测试获取可用模型
    print("\n2. 测试获取可用模型")
    try:
        response = requests.get(f"{AI_SERVICE_URL}/models")
        if response.status_code == 200:
            models = response.json()
            print(f"✅ 获取模型列表成功，共 {len(models)} 个模型")
            for model in models:
                print(f"   - {model}")
        else:
            print(f"❌ 获取模型列表失败: {response.status_code}")
    except Exception as e:
        print(f"❌ 获取模型列表请求失败: {e}")
    
    # 3. 测试单张图片推理
    print("\n3. 测试单张图片推理")
    try:
        inference_data = {
            "image_url": "https://via.placeholder.com/640x480.jpg",
            "model_name": "yolov8n",
            "confidence_threshold": 0.5
        }
        
        response = requests.post(f"{AI_SERVICE_URL}/infer", json=inference_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ 推理执行成功")
            print(f"   任务ID: {result.get('task_id', 'N/A')}")
            print(f"   状态: {result.get('status', 'N/A')}")
            print(f"   检测结果数: {len(result.get('results', []))}")
            print(f"   处理时间: {result.get('processing_time', 'N/A')}ms")
            return True
        else:
            print(f"❌ 推理执行失败: {response.status_code}")
            print(f"   错误信息: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 推理请求失败: {e}")
        return False

def test_frontend_access():
    """测试前端访问"""
    print("🌐 测试前端访问...")
    
    try:
        response = requests.get("http://localhost:3001", timeout=5)
        if response.status_code == 200:
            print("✅ 前端服务访问正常")
            return True
        else:
            print(f"❌ 前端服务访问异常: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 前端服务连接失败: {e}")
        return False

def main():
    """主函数"""
    print("=" * 60)
    print("🚀 VSS 推理历史功能简化测试")
    print("=" * 60)
    print(f"⏰ 测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # 测试AI服务
    ai_success = test_ai_service()
    print()
    
    # 测试前端访问
    frontend_success = test_frontend_access()
    print()
    
    # 总结
    print("=" * 60)
    print("📊 测试结果总结:")
    print(f"   AI推理服务: {'✅ 正常' if ai_success else '❌ 异常'}")
    print(f"   前端服务: {'✅ 正常' if frontend_success else '❌ 异常'}")
    
    if ai_success and frontend_success:
        print("\n🎉 推理历史功能基础环境测试通过！")
        print("💡 提示: 可以在浏览器中访问 http://localhost:3001 查看完整功能")
    else:
        print("\n⚠️ 部分服务存在问题，请检查服务状态")
    
    print("=" * 60)

if __name__ == "__main__":
    main()