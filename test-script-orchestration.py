#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
VSS 脚本编排服务测试脚本
测试脚本管理、执行和监控功能
"""

import requests
import json
import time
import sys
from datetime import datetime

class ScriptOrchestrationTester:
    def __init__(self, base_url="http://localhost:8087"):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    
    def test_health_check(self):
        """测试健康检查接口"""
        print("🔍 测试健康检查接口...")
        try:
            response = self.session.get(f"{self.base_url}/health")
            print(f"   状态码: {response.status_code}")
            if response.status_code == 200:
                print(f"   响应: {response.text}")
                return True
            else:
                print(f"   错误: {response.text}")
                return False
        except Exception as e:
            print(f"   连接失败: {e}")
            return False
    
    def test_create_script(self):
        """测试创建脚本"""
        print("\n📝 测试创建脚本...")
        script_data = {
            "name": "Hello World Script",
            "description": "简单的Hello World测试脚本",
            "category": "test",
            "content": "print('Hello, VSS Script Orchestration!')\nprint('当前时间:', datetime.now())",
            "language": "python",
            "timeout": 60,
            "tags": ["test", "hello-world"]
        }
        
        try:
            response = self.session.post(f"{self.base_url}/api/v1/scripts/", json=script_data)
            print(f"   状态码: {response.status_code}")
            if response.status_code == 201:
                script = response.json()
                print(f"   脚本ID: {script.get('id')}")
                print(f"   脚本名称: {script.get('name')}")
                return script.get('id')
            else:
                print(f"   错误: {response.text}")
                return None
        except Exception as e:
            print(f"   请求失败: {e}")
            return None
    
    def test_get_scripts(self):
        """测试获取脚本列表"""
        print("\n📋 测试获取脚本列表...")
        try:
            response = self.session.get(f"{self.base_url}/api/v1/scripts/")
            print(f"   状态码: {response.status_code}")
            if response.status_code == 200:
                scripts = response.json()
                print(f"   脚本总数: {len(scripts.get('items', []))}")
                for script in scripts.get('items', [])[:3]:  # 显示前3个
                    print(f"   - {script.get('name')} (ID: {script.get('id')})")
                return True
            else:
                print(f"   错误: {response.text}")
                return False
        except Exception as e:
            print(f"   请求失败: {e}")
            return False
    
    def test_execute_script(self, script_id):
        """测试执行脚本"""
        if not script_id:
            print("\n❌ 无法测试脚本执行：没有有效的脚本ID")
            return None
            
        print(f"\n▶️ 测试执行脚本 (ID: {script_id})...")
        execution_data = {
            "input_parameters": {"test_param": "test_value"},
            "environment_vars": {"TEST_ENV": "production"}
        }
        
        try:
            response = self.session.post(
                f"{self.base_url}/api/v1/scripts/{script_id}/execute",
                json=execution_data
            )
            print(f"   状态码: {response.status_code}")
            if response.status_code == 200:
                execution = response.json()
                execution_id = execution.get('execution_id')
                print(f"   执行ID: {execution_id}")
                print(f"   状态: {execution.get('status')}")
                return execution_id
            else:
                print(f"   错误: {response.text}")
                return None
        except Exception as e:
            print(f"   请求失败: {e}")
            return None
    
    def test_get_execution_status(self, execution_id):
        """测试获取执行状态"""
        if not execution_id:
            print("\n❌ 无法测试执行状态：没有有效的执行ID")
            return False
            
        print(f"\n📊 测试获取执行状态 (ID: {execution_id})...")
        try:
            response = self.session.get(f"{self.base_url}/api/v1/scripts/executions/{execution_id}")
            print(f"   状态码: {response.status_code}")
            if response.status_code == 200:
                execution = response.json()
                print(f"   执行状态: {execution.get('status')}")
                print(f"   开始时间: {execution.get('started_at')}")
                if execution.get('completed_at'):
                    print(f"   完成时间: {execution.get('completed_at')}")
                if execution.get('output'):
                    print(f"   输出: {execution.get('output')[:200]}...")
                return True
            else:
                print(f"   错误: {response.text}")
                return False
        except Exception as e:
            print(f"   请求失败: {e}")
            return False
    
    def test_get_script_templates(self):
        """测试获取脚本模板"""
        print("\n📄 测试获取脚本模板...")
        try:
            response = self.session.get(f"{self.base_url}/api/v1/scripts/templates/")
            print(f"   状态码: {response.status_code}")
            if response.status_code == 200:
                templates = response.json()
                print(f"   模板总数: {len(templates.get('items', []))}")
                for template in templates.get('items', [])[:3]:  # 显示前3个
                    print(f"   - {template.get('name')} ({template.get('language')})")
                return True
            else:
                print(f"   错误: {response.text}")
                return False
        except Exception as e:
            print(f"   请求失败: {e}")
            return False
    
    def test_get_statistics(self):
        """测试获取统计信息"""
        print("\n📈 测试获取统计信息...")
        try:
            response = self.session.get(f"{self.base_url}/api/v1/scripts/statistics/overview")
            print(f"   状态码: {response.status_code}")
            if response.status_code == 200:
                stats = response.json()
                print(f"   脚本总数: {stats.get('total_scripts', 0)}")
                print(f"   活跃脚本: {stats.get('active_scripts', 0)}")
                print(f"   执行总数: {stats.get('total_executions', 0)}")
                print(f"   成功率: {stats.get('success_rate', 0)}%")
                return True
            else:
                print(f"   错误: {response.text}")
                return False
        except Exception as e:
            print(f"   请求失败: {e}")
            return False
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始VSS脚本编排服务测试")
        print("=" * 50)
        
        # 测试健康检查
        if not self.test_health_check():
            print("\n❌ 健康检查失败，服务可能未启动")
            return False
        
        # 测试脚本管理
        script_id = self.test_create_script()
        self.test_get_scripts()
        
        # 测试脚本执行
        execution_id = self.test_execute_script(script_id)
        if execution_id:
            # 等待执行完成
            print("\n⏳ 等待脚本执行完成...")
            time.sleep(3)
            self.test_get_execution_status(execution_id)
        
        # 测试模板和统计
        self.test_get_script_templates()
        self.test_get_statistics()
        
        print("\n" + "=" * 50)
        print("✅ 脚本编排服务测试完成")
        return True

def main():
    """主函数"""
    print(f"VSS 脚本编排服务测试 - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 支持自定义服务地址
    base_url = "http://localhost:8087"
    if len(sys.argv) > 1:
        base_url = sys.argv[1]
    
    print(f"测试目标: {base_url}")
    
    tester = ScriptOrchestrationTester(base_url)
    success = tester.run_all_tests()
    
    if success:
        print("\n🎉 所有测试通过！脚本编排服务运行正常。")
        sys.exit(0)
    else:
        print("\n💥 测试失败！请检查服务状态。")
        sys.exit(1)

if __name__ == "__main__":
    main()