#!/usr/bin/env python3
"""
测试批量推理功能的脚本
"""

import requests
import json
import os
import glob
from pathlib import Path

# 服务器配置
BASE_URL = "http://localhost:8001"
HEALTH_URL = f"{BASE_URL}/health"
MODELS_URL = f"{BASE_URL}/models"
BATCH_UPLOAD_URL = f"{BASE_URL}/infer/batch/upload"

def test_server_health():
    """测试服务器健康状态"""
    print("🔍 检查服务器健康状态...")
    try:
        response = requests.get(HEALTH_URL)
        if response.status_code == 200:
            health_data = response.json()
            print(f"✅ 服务器健康状态: {health_data['status']}")
            print(f"   运行时间: {health_data.get('uptime', 'N/A')} 秒")
            return True
        else:
            print(f"❌ 服务器健康检查失败: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 连接服务器失败: {e}")
        return False

def get_available_models():
    """获取可用模型"""
    print("\n🔍 获取可用模型...")
    try:
        response = requests.get(MODELS_URL)
        if response.status_code == 200:
            models = response.json()
            print(f"✅ 可用模型: {models}")
            return models
        else:
            print(f"❌ 获取模型失败: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ 获取模型失败: {e}")
        return []

def find_test_images():
    """查找测试图片"""
    print("\n🔍 查找测试图片...")
    
    # 查找项目中的图片文件
    image_patterns = [
        "*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif"
    ]
    
    test_images = []
    
    # 在推理服务器目录查找
    inference_dir = Path("inference-server")
    if inference_dir.exists():
        for pattern in image_patterns:
            test_images.extend(glob.glob(str(inference_dir / "**" / pattern), recursive=True))
    
    # 在前端目录查找
    frontend_dir = Path("VSS-frontend")
    if frontend_dir.exists():
        for pattern in image_patterns:
            test_images.extend(glob.glob(str(frontend_dir / "**" / pattern), recursive=True))
    
    # 在根目录查找
    for pattern in image_patterns:
        test_images.extend(glob.glob(pattern))
    
    # 去重并限制数量
    test_images = list(set(test_images))[:3]
    
    print(f"✅ 找到 {len(test_images)} 张测试图片:")
    for img in test_images:
        print(f"   - {img}")
    
    return test_images

def test_batch_inference_upload(image_files, model_name="yolov5s"):
    """测试批量推理文件上传API"""
    print(f"\n🔍 测试批量推理 (模型: {model_name})...")
    
    if not image_files:
        print("❌ 没有找到测试图片")
        return False
    
    try:
        # 准备文件上传
        files = []
        for img_path in image_files:
            if os.path.exists(img_path):
                files.append(('files', (os.path.basename(img_path), open(img_path, 'rb'), 'image/jpeg')))
        
        if not files:
            print("❌ 没有有效的图片文件")
            return False
        
        # 准备其他参数
        data = {
            'model': model_name,
            'confidence': 0.5,
            'task': 'detect'
        }
        
        print(f"📤 上传 {len(files)} 张图片进行批量推理...")
        
        # 发送请求
        response = requests.post(BATCH_UPLOAD_URL, files=files, data=data)
        
        # 关闭文件
        for _, file_tuple in files:
            file_tuple[1].close()
        
        if response.status_code == 200:
            result = response.json()
            print("✅ 批量推理成功!")
            print(f"   处理了 {len(result.get('results', []))} 张图片")
            
            # 显示结果摘要
            for i, res in enumerate(result.get('results', [])):
                filename = res.get('filename', f'image_{i}')
                detections = res.get('detections', [])
                print(f"   📸 {filename}: 检测到 {len(detections)} 个对象")
                
                # 显示前3个检测结果
                for j, det in enumerate(detections[:3]):
                    class_name = det.get('class', 'unknown')
                    confidence = det.get('confidence', 0)
                    print(f"      - {class_name} (置信度: {confidence:.2f})")
                
                if len(detections) > 3:
                    print(f"      ... 还有 {len(detections) - 3} 个检测结果")
            
            return True
        else:
            print(f"❌ 批量推理失败: {response.status_code}")
            try:
                error_detail = response.json()
                print(f"   错误详情: {error_detail}")
            except:
                print(f"   错误内容: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 批量推理异常: {e}")
        return False

def main():
    """主函数"""
    print("🚀 开始测试批量推理功能\n")
    
    # 1. 检查服务器健康状态
    if not test_server_health():
        return
    
    # 2. 获取可用模型
    models = get_available_models()
    if not models:
        return
    
    # 3. 查找测试图片
    test_images = find_test_images()
    
    # 4. 测试批量推理
    if test_images:
        # 使用第一个可用模型
        model_name = models[0] if models else "yolov5s"
        success = test_batch_inference_upload(test_images, model_name)
        
        if success:
            print("\n🎉 批量推理功能测试成功!")
        else:
            print("\n❌ 批量推理功能测试失败!")
    else:
        print("\n⚠️  没有找到测试图片，无法进行批量推理测试")
    
    print("\n✅ 测试完成!")

if __name__ == "__main__":
    main()