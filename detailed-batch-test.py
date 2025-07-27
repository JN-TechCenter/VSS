#!/usr/bin/env python3
"""
详细测试批量推理API的文件名功能
"""

import requests
import json
import os

def test_batch_upload_with_filename():
    """测试批量推理上传API的文件名功能"""
    print("🔍 测试批量推理上传API的文件名功能...")
    
    # 检查测试图片是否存在
    test_image = "inference-server/test_image.jpg"
    if not os.path.exists(test_image):
        print(f"❌ 测试图片不存在: {test_image}")
        return False
    
    try:
        # 准备文件上传
        with open(test_image, 'rb') as f:
            files = {
                'files': ('my_test_image.jpg', f, 'image/jpeg')
            }
            
            data = {
                'model': 'yolov5s',
                'confidence': 0.5,
                'task': 'detect'
            }
            
            print(f"📤 上传图片: my_test_image.jpg")
            
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
                
                # 检查文件名是否正确添加
                if 'individual_results' in result and len(result['individual_results']) > 0:
                    first_result = result['individual_results'][0]
                    filename = first_result.get('filename')
                    print(f"📁 返回的文件名: {filename}")
                    
                    if filename == 'my_test_image.jpg':
                        print("✅ 文件名正确添加!")
                        return True
                    else:
                        print(f"❌ 文件名不匹配，期望: my_test_image.jpg, 实际: {filename}")
                        return False
                else:
                    print("❌ 响应中没有individual_results")
                    return False
            else:
                print(f"❌ 批量推理失败: {response.status_code}")
                print(f"   错误内容: {response.text}")
                return False
                
    except Exception as e:
        print(f"❌ 测试异常: {e}")
        return False

if __name__ == "__main__":
    print("🚀 开始详细测试批量推理API\n")
    success = test_batch_upload_with_filename()
    
    if success:
        print("\n🎉 测试成功!")
    else:
        print("\n❌ 测试失败!")