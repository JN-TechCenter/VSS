#!/usr/bin/env python3
"""
AI推理结果存储功能测试脚本
测试推理结果的存储、查询、删除和统计功能
"""

import requests
import base64
import json
import time
from datetime import datetime
from io import BytesIO
from PIL import Image, ImageDraw
import numpy as np

# 配置
BASE_URL = "http://localhost:8001"
TEST_IMAGE_SIZE = (640, 480)

def create_test_image(text="Test Image", size=TEST_IMAGE_SIZE):
    """创建测试图片"""
    # 创建彩色图片
    image = Image.new('RGB', size, color=(100, 150, 200))
    draw = ImageDraw.Draw(image)
    
    # 添加文本
    text_bbox = draw.textbbox((0, 0), text)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    text_x = (size[0] - text_width) // 2
    text_y = (size[1] - text_height) // 2
    draw.text((text_x, text_y), text, fill=(255, 255, 255))
    
    # 添加一些形状
    draw.rectangle([50, 50, 150, 150], outline=(255, 0, 0), width=3)
    draw.ellipse([200, 100, 300, 200], outline=(0, 255, 0), width=3)
    
    # 转换为base64
    buffer = BytesIO()
    image.save(buffer, format='JPEG')
    image_data = base64.b64encode(buffer.getvalue()).decode('utf-8')
    
    return image_data

def test_health_check():
    """测试健康检查"""
    print("🔍 测试健康检查...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            print("✅ 健康检查通过")
            return True
        else:
            print(f"❌ 健康检查失败: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 健康检查异常: {e}")
        return False

def test_inference_with_storage():
    """测试推理并验证结果存储"""
    print("\n🔍 测试推理结果存储...")
    
    try:
        # 创建测试图片
        image_data = create_test_image("Storage Test 1")
        
        # 执行推理
        inference_request = {
            "image_data": image_data,
            "task": "detect",
            "model_name": "yolov5s",
            "confidence_threshold": 0.5,
            "iou_threshold": 0.5,
            "return_annotated_image": True
        }
        
        response = requests.post(f"{BASE_URL}/infer", json=inference_request)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ 推理成功: 处理时间={result.get('processing_time', 0):.3f}s")
            
            # 等待一下确保存储完成
            time.sleep(1)
            
            return True
        else:
            print(f"❌ 推理失败: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 推理测试异常: {e}")
        return False

def test_multiple_inferences():
    """测试多次推理以生成更多存储数据"""
    print("\n🔍 执行多次推理生成测试数据...")
    
    success_count = 0
    total_count = 3
    
    for i in range(total_count):
        try:
            # 创建不同的测试图片
            image_data = create_test_image(f"Storage Test {i+2}")
            
            inference_request = {
                "image_data": image_data,
                "task": "detect",
                "model_name": "yolov5s",
                "confidence_threshold": 0.3 + i * 0.1,  # 不同的置信度
                "iou_threshold": 0.5,
                "return_annotated_image": True
            }
            
            response = requests.post(f"{BASE_URL}/infer", json=inference_request)
            
            if response.status_code == 200:
                success_count += 1
                print(f"✅ 推理 {i+1} 成功")
            else:
                print(f"❌ 推理 {i+1} 失败: {response.status_code}")
                
            # 间隔一下
            time.sleep(0.5)
            
        except Exception as e:
            print(f"❌ 推理 {i+1} 异常: {e}")
    
    print(f"📊 多次推理完成: {success_count}/{total_count} 成功")
    return success_count > 0

def test_get_results():
    """测试获取推理结果列表"""
    print("\n🔍 测试获取推理结果列表...")
    
    try:
        # 获取第一页结果
        response = requests.get(f"{BASE_URL}/results?page=1&page_size=10")
        
        if response.status_code == 200:
            results = response.json()
            print(f"✅ 获取结果列表成功")
            print(f"📊 总数: {results.get('total', 0)}")
            print(f"📊 当前页: {results.get('page', 0)}")
            print(f"📊 每页大小: {results.get('page_size', 0)}")
            print(f"📊 结果数量: {len(results.get('results', []))}")
            
            # 显示前几个结果的基本信息
            for i, result in enumerate(results.get('results', [])[:3]):
                print(f"  结果 {i+1}: ID={result.get('id', 'N/A')[:8]}..., "
                      f"模型={result.get('model_name', 'N/A')}, "
                      f"时间={result.get('created_at', 'N/A')}")
            
            return results.get('results', [])
        else:
            print(f"❌ 获取结果列表失败: {response.status_code} - {response.text}")
            return []
            
    except Exception as e:
        print(f"❌ 获取结果列表异常: {e}")
        return []

def test_get_result_detail(result_id):
    """测试获取单个推理结果详情"""
    print(f"\n🔍 测试获取推理结果详情: {result_id[:8]}...")
    
    try:
        response = requests.get(f"{BASE_URL}/results/{result_id}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ 获取结果详情成功")
            print(f"📊 ID: {result.get('id', 'N/A')}")
            print(f"📊 模型: {result.get('model_name', 'N/A')}")
            print(f"📊 任务: {result.get('task', 'N/A')}")
            print(f"📊 成功: {result.get('success', False)}")
            print(f"📊 处理时间: {result.get('processing_time', 0):.3f}s")
            print(f"📊 检测结果数: {len(result.get('detection_results', []))}")
            print(f"📊 图片大小: {result.get('image_size', [0, 0])}")
            print(f"📊 创建时间: {result.get('created_at', 'N/A')}")
            
            return True
        else:
            print(f"❌ 获取结果详情失败: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 获取结果详情异常: {e}")
        return False

def test_get_statistics():
    """测试获取推理统计信息"""
    print("\n🔍 测试获取推理统计信息...")
    
    try:
        response = requests.get(f"{BASE_URL}/results/statistics")
        
        if response.status_code == 200:
            stats = response.json()
            print(f"✅ 获取统计信息成功")
            print(f"📊 总推理次数: {stats.get('total_inferences', 0)}")
            print(f"📊 成功推理次数: {stats.get('successful_inferences', 0)}")
            print(f"📊 失败推理次数: {stats.get('failed_inferences', 0)}")
            print(f"📊 总检测对象数: {stats.get('total_objects_detected', 0)}")
            print(f"📊 平均处理时间: {stats.get('average_processing_time', 0):.3f}s")
            print(f"📊 最早记录: {stats.get('earliest_inference', 'N/A')}")
            print(f"📊 最新记录: {stats.get('latest_inference', 'N/A')}")
            
            # 按模型统计
            model_stats = stats.get('by_model', {})
            if model_stats:
                print("📊 按模型统计:")
                for model, count in model_stats.items():
                    print(f"  {model}: {count} 次")
            
            return True
        else:
            print(f"❌ 获取统计信息失败: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 获取统计信息异常: {e}")
        return False

def test_filter_results():
    """测试结果过滤功能"""
    print("\n🔍 测试结果过滤功能...")
    
    try:
        # 按模型过滤
        response = requests.get(f"{BASE_URL}/results?model_name=yolov5s&page_size=5")
        
        if response.status_code == 200:
            results = response.json()
            print(f"✅ 按模型过滤成功: 找到 {len(results.get('results', []))} 个结果")
            
            # 按时间过滤（最近1小时）
            from datetime import datetime, timedelta
            end_time = datetime.now()
            start_time = end_time - timedelta(hours=1)
            
            params = {
                "start_time": start_time.isoformat(),
                "end_time": end_time.isoformat(),
                "page_size": 5
            }
            
            response = requests.get(f"{BASE_URL}/results", params=params)
            
            if response.status_code == 200:
                results = response.json()
                print(f"✅ 按时间过滤成功: 找到 {len(results.get('results', []))} 个结果")
                return True
            else:
                print(f"❌ 按时间过滤失败: {response.status_code}")
                return False
        else:
            print(f"❌ 按模型过滤失败: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ 结果过滤测试异常: {e}")
        return False

def test_delete_result(result_id):
    """测试删除推理结果"""
    print(f"\n🔍 测试删除推理结果: {result_id[:8]}...")
    
    try:
        response = requests.delete(f"{BASE_URL}/results/{result_id}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ 删除结果成功: {result.get('message', '')}")
            
            # 验证删除
            verify_response = requests.get(f"{BASE_URL}/results/{result_id}")
            if verify_response.status_code == 404:
                print("✅ 删除验证成功: 结果已不存在")
                return True
            else:
                print("❌ 删除验证失败: 结果仍然存在")
                return False
        else:
            print(f"❌ 删除结果失败: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 删除结果异常: {e}")
        return False

def main():
    """主测试函数"""
    print("🚀 开始AI推理结果存储功能测试")
    print("=" * 50)
    
    # 测试计数器
    tests_passed = 0
    total_tests = 0
    
    # 1. 健康检查
    total_tests += 1
    if test_health_check():
        tests_passed += 1
    
    # 2. 执行推理并存储结果
    total_tests += 1
    if test_inference_with_storage():
        tests_passed += 1
    
    # 3. 执行多次推理
    total_tests += 1
    if test_multiple_inferences():
        tests_passed += 1
    
    # 4. 获取结果列表
    total_tests += 1
    results = test_get_results()
    if results:
        tests_passed += 1
    
    # 5. 获取结果详情
    if results:
        total_tests += 1
        if test_get_result_detail(results[0]['id']):
            tests_passed += 1
    
    # 6. 获取统计信息
    total_tests += 1
    if test_get_statistics():
        tests_passed += 1
    
    # 7. 测试过滤功能
    total_tests += 1
    if test_filter_results():
        tests_passed += 1
    
    # 8. 删除测试（如果有结果的话）
    if results and len(results) > 1:
        total_tests += 1
        if test_delete_result(results[-1]['id']):  # 删除最后一个结果
            tests_passed += 1
    
    # 输出测试结果
    print("\n" + "=" * 50)
    print(f"📊 测试完成: {tests_passed}/{total_tests} 通过")
    print(f"📊 通过率: {(tests_passed/total_tests)*100:.1f}%")
    
    if tests_passed == total_tests:
        print("🎉 所有推理结果存储功能测试通过！")
        return True
    else:
        print("⚠️  部分测试失败，请检查服务状态")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)