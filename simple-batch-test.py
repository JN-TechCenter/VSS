#!/usr/bin/env python3
"""
简单的批量推理API测试
"""

import requests
import os

def test_batch_upload_api():
    """测试批量推理上传API"""
    print("🔍 测试批量推理上传API...")
    
    # 检查测试图片是否存在
    test_image = "inference-server/test_image.jpg"
    if not os.path.exists(test_image):
        print(f"❌ 测试图片不存在: {test_image}")
        return False
    
    try:
        # 准备文件上传
        with open(test_image, 'rb') as f:
            files = {
                'files': (os.path.basename(test_image), f, 'image/jpeg')
            }
            
            data = {
                'model': 'yolov5s',
                'confidence': 0.5,
                'task': 'detect'
            }
            
            print(f"📤 上传图片: {test_image}")
            
            # 发送请求
            response = requests.post(
                'http://localhost:8001/infer/batch/upload',
                files=files,
                data=data,
                timeout=30
            )
            
            print(f"📥 响应状态码: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print("✅ 批量推理成功!")
                print(f"   响应数据: {result}")
                return True
            else:
                print(f"❌ 批量推理失败: {response.status_code}")
                print(f"   错误内容: {response.text}")
                return False
                
    except Exception as e:
        print(f"❌ 测试异常: {e}")
        return False

if __name__ == "__main__":
    print("🚀 开始测试批量推理API\n")
    success = test_batch_upload_api()
    
    if success:
        print("\n🎉 测试成功!")
    else:
        print("\n❌ 测试失败!")