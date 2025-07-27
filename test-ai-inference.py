#!/usr/bin/env python3
"""
VSS AI推理服务 - 功能测试脚本
测试AI推理服务的各项功能
"""

import requests
import json
import time
import base64
from pathlib import Path
from typing import Dict, Any

class AIInferenceTest:
    """AI推理服务测试类"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.session = requests.Session()
        self.test_results = {}
    
    def test_health_check(self) -> bool:
        """测试健康检查API"""
        try:
            print("🔍 测试健康检查API...")
            response = self.session.get(f"{self.base_url}/health")
            
            if response.status_code == 200:
                data = response.json()
                print(f"✅ 健康检查通过: {data['status']}")
                print(f"   服务运行时间: {data.get('uptime', 0):.1f}秒")
                return True
            else:
                print(f"❌ 健康检查失败: HTTP {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ 健康检查异常: {e}")
            return False
    
    def test_models_list(self) -> bool:
        """测试模型列表API"""
        try:
            print("🔍 测试模型列表API...")
            response = self.session.get(f"{self.base_url}/models")
            
            if response.status_code == 200:
                models = response.json()  # 直接是列表
                print(f"✅ 模型列表获取成功: 共{len(models)}个模型")
                for model in models:
                    print(f"   - {model.get('name', 'Unknown')}: {model.get('description', 'No description')}")
                return True
            else:
                print(f"❌ 模型列表获取失败: HTTP {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ 模型列表获取异常: {e}")
            return False
    
    def test_inference_with_url(self) -> bool:
        """测试URL图片推理"""
        try:
            print("🔍 测试URL图片推理...")
            
            # 使用一个公开的测试图片URL
            test_url = "https://ultralytics.com/images/bus.jpg"
            
            payload = {
                "task": "detect",
                "model_name": "yolov5s",
                "image_url": test_url,
                "confidence_threshold": 0.5,
                "iou_threshold": 0.45
            }
            
            response = self.session.post(
                f"{self.base_url}/infer",
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                detections = data.get('detection_results', [])
                print(f"✅ URL图片推理成功: 检测到{len(detections)}个目标")
                
                for i, det in enumerate(detections[:3]):  # 只显示前3个
                    print(f"   {i+1}. {det.get('class_name', 'Unknown')} (置信度: {det.get('confidence', 0):.2f})")
                
                return True
            else:
                print(f"❌ URL图片推理失败: HTTP {response.status_code}")
                if response.text:
                    print(f"   错误信息: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ URL图片推理异常: {e}")
            return False
    
    def test_inference_with_base64(self) -> bool:
        """测试Base64图片推理"""
        try:
            print("🔍 测试Base64图片推理...")
            
            # 创建一个简单的测试图片（1x1像素的PNG）
            test_image_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
            
            payload = {
                "task": "detect",
                "model_name": "yolov5s",
                "image_data": test_image_base64,
                "confidence_threshold": 0.5,
                "iou_threshold": 0.45
            }
            
            response = self.session.post(
                f"{self.base_url}/infer",
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                detections = data.get('detection_results', [])
                print(f"✅ Base64图片推理成功: 检测到{len(detections)}个目标")
                return True
            else:
                print(f"❌ Base64图片推理失败: HTTP {response.status_code}")
                if response.text:
                    print(f"   错误信息: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Base64图片推理异常: {e}")
            return False
    
    def test_model_info(self) -> bool:
        """测试模型信息API"""
        try:
            print("🔍 测试模型信息API...")
            response = self.session.get(f"{self.base_url}/models/yolov5s")
            
            if response.status_code == 200:
                data = response.json()
                print(f"✅ 模型信息获取成功:")
                print(f"   模型名称: {data.get('name', 'Unknown')}")
                print(f"   模型描述: {data.get('description', 'No description')}")
                print(f"   类别数量: {data.get('num_classes', 0)}")
                return True
            else:
                print(f"❌ 模型信息获取失败: HTTP {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ 模型信息获取异常: {e}")
            return False
    
    def run_all_tests(self) -> Dict[str, bool]:
        """运行所有测试"""
        print("🚀 开始AI推理服务功能测试")
        print("=" * 50)
        
        tests = [
            ("健康检查", self.test_health_check),
            ("模型列表", self.test_models_list),
            ("模型信息", self.test_model_info),
            ("URL图片推理", self.test_inference_with_url),
            ("Base64图片推理", self.test_inference_with_base64),
        ]
        
        results = {}
        
        for test_name, test_func in tests:
            print(f"\n📋 执行测试: {test_name}")
            try:
                results[test_name] = test_func()
            except Exception as e:
                print(f"❌ 测试异常: {e}")
                results[test_name] = False
            
            time.sleep(1)  # 避免请求过快
        
        # 输出测试结果汇总
        print("\n" + "=" * 50)
        print("📊 测试结果汇总:")
        
        passed = 0
        total = len(results)
        
        for test_name, success in results.items():
            status = "✅ 通过" if success else "❌ 失败"
            print(f"  {test_name}: {status}")
            if success:
                passed += 1
        
        print(f"\n🎯 总体结果: {passed}/{total} 测试通过 ({passed/total*100:.1f}%)")
        
        if passed == total:
            print("🎉 所有测试通过！AI推理服务运行正常。")
        else:
            print("⚠️ 部分测试失败，请检查服务配置。")
        
        return results

def main():
    """主函数"""
    tester = AIInferenceTest()
    results = tester.run_all_tests()
    
    # 返回退出码
    all_passed = all(results.values())
    exit(0 if all_passed else 1)

if __name__ == "__main__":
    main()