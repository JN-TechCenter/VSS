#!/usr/bin/env python3
"""
VSS视觉监控平台 - 系统功能验证脚本
测试所有关键API端点和功能
"""

import requests
import json
import time
from pathlib import Path

def test_service(name, url, timeout=5):
    """测试服务是否可访问"""
    try:
        response = requests.get(url, timeout=timeout)
        if response.status_code == 200:
            print(f"✅ {name}: 正常 (状态码: {response.status_code})")
            return True
        else:
            print(f"⚠️ {name}: 异常 (状态码: {response.status_code})")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ {name}: 无法访问 ({str(e)})")
        return False

def test_ai_inference():
    """测试AI推理服务"""
    print("\n🤖 测试AI推理服务...")
    
    # 测试健康检查
    health_ok = test_service("AI推理健康检查", "http://localhost:8001/health")
    
    # 测试模型列表
    models_ok = test_service("AI模型列表", "http://localhost:8001/models")
    
    # 测试单张图片推理
    try:
        # 创建测试图片
        test_image_path = Path("test_image.jpg")
        if not test_image_path.exists():
            print("⚠️ 测试图片不存在，跳过推理测试")
            return health_ok and models_ok
        
        with open(test_image_path, 'rb') as f:
            files = {'file': ('test.jpg', f, 'image/jpeg')}
            response = requests.post(
                "http://localhost:8001/infer/upload",
                files=files,
                timeout=30
            )
        
        if response.status_code == 200:
            print("✅ 单张图片推理: 正常")
            result = response.json()
            print(f"   检测到 {len(result.get('detections', []))} 个目标")
            return True
        else:
            print(f"❌ 单张图片推理: 失败 (状态码: {response.status_code})")
            return False
            
    except Exception as e:
        print(f"❌ 单张图片推理: 异常 ({str(e)})")
        return False

def test_backend_service():
    """测试后端服务"""
    print("\n🔧 测试后端服务...")
    
    # 测试健康检查
    health_ok = test_service("后端健康检查", "http://localhost:3002/actuator/health")
    
    # 测试API端点
    api_ok = test_service("后端API", "http://localhost:3002/api/test", timeout=10)
    
    return health_ok

def test_frontend_service():
    """测试前端服务"""
    print("\n🎨 测试前端服务...")
    
    # 测试主页
    main_ok = test_service("前端主页", "http://localhost:3001")
    
    # 测试AI推理页面
    ai_page_ok = test_service("AI推理页面", "http://localhost:3001/ai-inference")
    
    return main_ok and ai_page_ok

def main():
    """主测试函数"""
    print("=" * 50)
    print("VSS视觉监控平台 - 系统功能验证")
    print("=" * 50)
    
    start_time = time.time()
    
    # 测试各个服务
    frontend_ok = test_frontend_service()
    backend_ok = test_backend_service()
    ai_ok = test_ai_inference()
    
    # 汇总结果
    print("\n" + "=" * 50)
    print("📊 测试结果汇总")
    print("=" * 50)
    
    services = [
        ("前端服务", frontend_ok),
        ("后端服务", backend_ok),
        ("AI推理服务", ai_ok)
    ]
    
    all_ok = True
    for service_name, status in services:
        status_icon = "✅" if status else "❌"
        status_text = "正常" if status else "异常"
        print(f"{status_icon} {service_name}: {status_text}")
        if not status:
            all_ok = False
    
    elapsed_time = time.time() - start_time
    print(f"\n⏱️ 测试耗时: {elapsed_time:.2f}秒")
    
    if all_ok:
        print("\n🎉 所有服务运行正常！")
        print("\n🔗 快速访问链接:")
        print("   前端应用: http://localhost:3001")
        print("   AI推理页面: http://localhost:3001/ai-inference")
        print("   后端健康检查: http://localhost:3002/actuator/health")
        print("   AI服务健康: http://localhost:8001/health")
    else:
        print("\n⚠️ 部分服务存在问题，请检查日志")
    
    return all_ok

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)