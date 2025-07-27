#!/usr/bin/env python3
"""
VSS 推理历史功能测试脚本
测试推理历史记录的创建、查询、更新和删除功能
"""

import requests
import json
import time
from datetime import datetime

# 配置
BACKEND_URL = "http://localhost:3002"
AI_SERVICE_URL = "http://localhost:8000"

def test_inference_history_api():
    """测试推理历史API功能"""
    print("🧪 开始测试推理历史API功能...")
    
    # 1. 测试搜索推理历史（空数据）
    print("\n1. 测试搜索推理历史（初始状态）")
    try:
        response = requests.get(f"{BACKEND_URL}/api/inference-history/search")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 搜索成功，当前记录数: {data.get('totalElements', 0)}")
        else:
            print(f"❌ 搜索失败: {response.status_code}")
    except Exception as e:
        print(f"❌ 搜索请求失败: {e}")
    
    # 2. 测试获取统计信息
    print("\n2. 测试获取统计信息")
    try:
        response = requests.get(f"{BACKEND_URL}/api/inference-history/stats")
        if response.status_code == 200:
            stats = response.json()
            print(f"✅ 统计信息获取成功:")
            print(f"   总推理次数: {stats.get('totalInferences', 0)}")
            print(f"   成功次数: {stats.get('successfulInferences', 0)}")
            print(f"   失败次数: {stats.get('failedInferences', 0)}")
        else:
            print(f"❌ 统计信息获取失败: {response.status_code}")
    except Exception as e:
        print(f"❌ 统计信息请求失败: {e}")
    
    # 3. 执行一次AI推理以生成历史记录
    print("\n3. 执行AI推理生成历史记录")
    try:
        # 检查AI服务健康状态
        health_response = requests.get(f"{AI_SERVICE_URL}/health")
        if health_response.status_code == 200:
            print("✅ AI服务运行正常")
            
            # 执行推理（使用测试图片URL）
            inference_data = {
                "image_url": "https://via.placeholder.com/640x480.jpg",
                "model_name": "yolov8n",
                "confidence_threshold": 0.5
            }
            
            inference_response = requests.post(
                f"{BACKEND_URL}/api/ai-inference/infer", 
                json=inference_data
            )
            
            if inference_response.status_code == 200:
                result = inference_response.json()
                print(f"✅ 推理执行成功，任务ID: {result.get('task_id', 'N/A')}")
                
                # 等待一下让历史记录保存
                time.sleep(2)
                
                # 再次查询历史记录
                search_response = requests.get(f"{BACKEND_URL}/api/inference-history/search")
                if search_response.status_code == 200:
                    data = search_response.json()
                    print(f"✅ 推理后记录数: {data.get('totalElements', 0)}")
                    
                    if data.get('content'):
                        record = data['content'][0]
                        print(f"   最新记录ID: {record.get('id')}")
                        print(f"   任务ID: {record.get('taskId')}")
                        print(f"   状态: {record.get('status')}")
                        print(f"   推理类型: {record.get('inferenceType')}")
                        
                        # 4. 测试获取记录详情
                        print("\n4. 测试获取记录详情")
                        detail_response = requests.get(
                            f"{BACKEND_URL}/api/inference-history/{record['id']}"
                        )
                        if detail_response.status_code == 200:
                            print("✅ 记录详情获取成功")
                        else:
                            print(f"❌ 记录详情获取失败: {detail_response.status_code}")
                        
                        # 5. 测试标记收藏
                        print("\n5. 测试标记收藏")
                        favorite_response = requests.post(
                            f"{BACKEND_URL}/api/inference-history/{record['id']}/favorite"
                        )
                        if favorite_response.status_code == 200:
                            print("✅ 标记收藏成功")
                        else:
                            print(f"❌ 标记收藏失败: {favorite_response.status_code}")
                        
                        # 6. 测试评分
                        print("\n6. 测试评分")
                        rating_response = requests.post(
                            f"{BACKEND_URL}/api/inference-history/{record['id']}/rate",
                            json={"rating": 4}
                        )
                        if rating_response.status_code == 200:
                            print("✅ 评分成功")
                        else:
                            print(f"❌ 评分失败: {rating_response.status_code}")
                        
                        # 7. 测试添加备注
                        print("\n7. 测试添加备注")
                        note_response = requests.post(
                            f"{BACKEND_URL}/api/inference-history/{record['id']}/note",
                            json={"note": "测试备注内容"}
                        )
                        if note_response.status_code == 200:
                            print("✅ 添加备注成功")
                        else:
                            print(f"❌ 添加备注失败: {note_response.status_code}")
                
            else:
                print(f"❌ 推理执行失败: {inference_response.status_code}")
                print(f"   错误信息: {inference_response.text}")
        else:
            print(f"❌ AI服务不可用: {health_response.status_code}")
            
    except Exception as e:
        print(f"❌ 推理测试失败: {e}")
    
    # 8. 最终统计信息
    print("\n8. 最终统计信息")
    try:
        response = requests.get(f"{BACKEND_URL}/api/inference-history/stats")
        if response.status_code == 200:
            stats = response.json()
            print(f"✅ 最终统计:")
            print(f"   总推理次数: {stats.get('totalInferences', 0)}")
            print(f"   成功次数: {stats.get('successfulInferences', 0)}")
            print(f"   失败次数: {stats.get('failedInferences', 0)}")
            if stats.get('totalInferences', 0) > 0:
                success_rate = (stats.get('successfulInferences', 0) / stats.get('totalInferences', 1)) * 100
                print(f"   成功率: {success_rate:.1f}%")
        else:
            print(f"❌ 最终统计获取失败: {response.status_code}")
    except Exception as e:
        print(f"❌ 最终统计请求失败: {e}")

def test_service_health():
    """测试服务健康状态"""
    print("🏥 检查服务健康状态...")
    
    services = [
        ("后端服务", f"{BACKEND_URL}/actuator/health"),
        ("AI推理服务", f"{AI_SERVICE_URL}/health"),
    ]
    
    for name, url in services:
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                print(f"✅ {name}: 运行正常")
            else:
                print(f"❌ {name}: 状态异常 ({response.status_code})")
        except Exception as e:
            print(f"❌ {name}: 连接失败 - {e}")

def main():
    """主函数"""
    print("=" * 60)
    print("🚀 VSS 推理历史功能测试")
    print("=" * 60)
    print(f"⏰ 测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # 检查服务健康状态
    test_service_health()
    print()
    
    # 测试推理历史API
    test_inference_history_api()
    
    print("\n" + "=" * 60)
    print("✅ 推理历史功能测试完成")
    print("=" * 60)

if __name__ == "__main__":
    main()