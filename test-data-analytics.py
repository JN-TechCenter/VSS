#!/usr/bin/env python3
"""
数据分析服务测试脚本
测试数据分析API的各个接口功能
"""

import requests
import json
import sys
from datetime import datetime, timedelta

# 配置
BASE_URL = "http://localhost:8080/analytics/api/v1/analytics"
HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
}

def test_health_check():
    """测试健康检查接口"""
    print("🔍 测试健康检查接口...")
    try:
        response = requests.get(f"{BASE_URL}/health", headers=HEADERS, timeout=10)
        print(f"状态码: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"响应: {json.dumps(data, indent=2, ensure_ascii=False)}")
            print("✅ 健康检查通过")
            return True
        else:
            print(f"❌ 健康检查失败: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 健康检查异常: {e}")
        return False

def test_inference_statistics():
    """测试推理统计接口"""
    print("\n🔍 测试推理统计接口...")
    try:
        response = requests.get(f"{BASE_URL}/inference-statistics", headers=HEADERS, timeout=10)
        print(f"状态码: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"响应: {json.dumps(data, indent=2, ensure_ascii=False)}")
            print("✅ 推理统计接口正常")
            return True
        else:
            print(f"❌ 推理统计接口失败: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 推理统计接口异常: {e}")
        return False

def test_performance_metrics():
    """测试性能指标接口"""
    print("\n🔍 测试性能指标接口...")
    try:
        response = requests.get(f"{BASE_URL}/performance-metrics", headers=HEADERS, timeout=10)
        print(f"状态码: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"响应: {json.dumps(data, indent=2, ensure_ascii=False)}")
            print("✅ 性能指标接口正常")
            return True
        else:
            print(f"❌ 性能指标接口失败: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 性能指标接口异常: {e}")
        return False

def test_trend_analysis():
    """测试趋势分析接口"""
    print("\n🔍 测试趋势分析接口...")
    try:
        # 构建查询参数
        end_time = datetime.now()
        start_time = end_time - timedelta(days=7)
        
        params = {
            'metric_type': 'inference_count',
            'start_time': start_time.isoformat(),
            'end_time': end_time.isoformat(),
            'interval': 'day'
        }
        
        response = requests.get(f"{BASE_URL}/trend-analysis", params=params, headers=HEADERS, timeout=10)
        print(f"状态码: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"响应: {json.dumps(data, indent=2, ensure_ascii=False)}")
            print("✅ 趋势分析接口正常")
            return True
        else:
            print(f"❌ 趋势分析接口失败: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 趋势分析接口异常: {e}")
        return False

def test_dashboard_data():
    """测试仪表板数据接口"""
    print("\n🔍 测试仪表板数据接口...")
    try:
        response = requests.get(f"{BASE_URL}/dashboard-data", headers=HEADERS, timeout=10)
        print(f"状态码: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"响应: {json.dumps(data, indent=2, ensure_ascii=False)}")
            print("✅ 仪表板数据接口正常")
            return True
        else:
            print(f"❌ 仪表板数据接口失败: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 仪表板数据接口异常: {e}")
        return False

def test_summary_report():
    """测试汇总报告接口"""
    print("\n🔍 测试汇总报告接口...")
    try:
        response = requests.get(f"{BASE_URL}/summary-report", headers=HEADERS, timeout=10)
        print(f"状态码: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"响应: {json.dumps(data, indent=2, ensure_ascii=False)}")
            print("✅ 汇总报告接口正常")
            return True
        else:
            print(f"❌ 汇总报告接口失败: {response.text}")
            return False
    except Exception as e:
        print(f"❌ 汇总报告接口异常: {e}")
        return False

def main():
    """主测试函数"""
    print("🚀 开始数据分析服务测试")
    print("=" * 50)
    
    # 测试结果统计
    tests = [
        ("健康检查", test_health_check),
        ("推理统计", test_inference_statistics),
        ("性能指标", test_performance_metrics),
        ("趋势分析", test_trend_analysis),
        ("仪表板数据", test_dashboard_data),
        ("汇总报告", test_summary_report)
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        try:
            if test_func():
                passed += 1
        except Exception as e:
            print(f"❌ {test_name}测试异常: {e}")
    
    print("\n" + "=" * 50)
    print(f"📊 测试结果: {passed}/{total} 通过")
    
    if passed == total:
        print("🎉 所有测试通过！数据分析服务运行正常")
        return 0
    else:
        print("⚠️  部分测试失败，请检查服务状态")
        return 1

if __name__ == "__main__":
    sys.exit(main())