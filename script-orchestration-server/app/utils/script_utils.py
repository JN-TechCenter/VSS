import os
import json
import logging
from typing import Dict, Any, List
from datetime import datetime

logger = logging.getLogger(__name__)

class ScriptValidator:
    """脚本验证器"""
    
    @staticmethod
    def validate_python_script(content: str) -> Dict[str, Any]:
        """验证Python脚本语法"""
        try:
            compile(content, '<string>', 'exec')
            return {"valid": True, "message": "脚本语法正确"}
        except SyntaxError as e:
            return {
                "valid": False, 
                "message": f"语法错误: {e.msg} (行 {e.lineno})"
            }
        except Exception as e:
            return {
                "valid": False, 
                "message": f"验证失败: {str(e)}"
            }
    
    @staticmethod
    def validate_bash_script(content: str) -> Dict[str, Any]:
        """验证Bash脚本语法"""
        try:
            # 基本的bash语法检查
            if not content.strip():
                return {"valid": False, "message": "脚本内容不能为空"}
            
            # 检查是否包含危险命令
            dangerous_commands = ['rm -rf /', 'format', 'del /f /s /q']
            for cmd in dangerous_commands:
                if cmd in content:
                    return {
                        "valid": False, 
                        "message": f"包含危险命令: {cmd}"
                    }
            
            return {"valid": True, "message": "脚本语法正确"}
        except Exception as e:
            return {
                "valid": False, 
                "message": f"验证失败: {str(e)}"
            }

class ScriptTemplateManager:
    """脚本模板管理器"""
    
    @staticmethod
    def get_builtin_templates() -> List[Dict[str, Any]]:
        """获取内置脚本模板"""
        return [
            {
                "name": "Hello World Python",
                "description": "简单的Python Hello World脚本",
                "category": "example",
                "language": "python",
                "template_content": '''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Hello World 示例脚本
"""

def main():
    print("Hello, World!")
    print("当前时间:", datetime.now())
    
    # 获取环境变量
    name = os.environ.get('NAME', 'World')
    print(f"Hello, {name}!")

if __name__ == "__main__":
    import os
    from datetime import datetime
    main()
''',
                "default_parameters": {"NAME": "VSS"},
                "required_parameters": [],
                "parameter_schema": {
                    "NAME": {
                        "type": "string",
                        "description": "要问候的名称",
                        "default": "World"
                    }
                }
            },
            {
                "name": "系统信息收集",
                "description": "收集系统基本信息的脚本",
                "category": "system",
                "language": "python",
                "template_content": '''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
系统信息收集脚本
"""

import os
import platform
import psutil
import json
from datetime import datetime

def collect_system_info():
    """收集系统信息"""
    info = {
        "timestamp": datetime.now().isoformat(),
        "system": {
            "platform": platform.platform(),
            "system": platform.system(),
            "release": platform.release(),
            "version": platform.version(),
            "machine": platform.machine(),
            "processor": platform.processor()
        },
        "cpu": {
            "count": psutil.cpu_count(),
            "usage": psutil.cpu_percent(interval=1)
        },
        "memory": {
            "total": psutil.virtual_memory().total,
            "available": psutil.virtual_memory().available,
            "percent": psutil.virtual_memory().percent
        },
        "disk": {
            "total": psutil.disk_usage('/').total,
            "used": psutil.disk_usage('/').used,
            "free": psutil.disk_usage('/').free,
            "percent": psutil.disk_usage('/').percent
        }
    }
    return info

def main():
    try:
        info = collect_system_info()
        print(json.dumps(info, indent=2, ensure_ascii=False))
    except Exception as e:
        print(f"错误: {str(e)}")
        exit(1)

if __name__ == "__main__":
    main()
''',
                "default_parameters": {},
                "required_parameters": [],
                "parameter_schema": {}
            },
            {
                "name": "文件备份脚本",
                "description": "备份指定目录的文件",
                "category": "utility",
                "language": "bash",
                "template_content": '''#!/bin/bash
# 文件备份脚本

# 设置默认值
SOURCE_DIR=${SOURCE_DIR:-"/app/data"}
BACKUP_DIR=${BACKUP_DIR:-"/app/backup"}
BACKUP_NAME=${BACKUP_NAME:-"backup_$(date +%Y%m%d_%H%M%S)"}

echo "开始备份..."
echo "源目录: $SOURCE_DIR"
echo "备份目录: $BACKUP_DIR"
echo "备份名称: $BACKUP_NAME"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 执行备份
if tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"; then
    echo "备份成功: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
    
    # 显示备份文件信息
    ls -lh "$BACKUP_DIR/$BACKUP_NAME.tar.gz"
else
    echo "备份失败"
    exit 1
fi

echo "备份完成"
''',
                "default_parameters": {
                    "SOURCE_DIR": "/app/data",
                    "BACKUP_DIR": "/app/backup"
                },
                "required_parameters": ["SOURCE_DIR"],
                "parameter_schema": {
                    "SOURCE_DIR": {
                        "type": "string",
                        "description": "要备份的源目录路径"
                    },
                    "BACKUP_DIR": {
                        "type": "string",
                        "description": "备份文件存储目录",
                        "default": "/app/backup"
                    },
                    "BACKUP_NAME": {
                        "type": "string",
                        "description": "备份文件名前缀",
                        "default": "backup"
                    }
                }
            },
            {
                "name": "API健康检查",
                "description": "检查API服务的健康状态",
                "category": "monitoring",
                "language": "python",
                "template_content": '''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
API健康检查脚本
"""

import requests
import json
import os
from datetime import datetime

def check_api_health(url, timeout=10):
    """检查API健康状态"""
    try:
        response = requests.get(url, timeout=timeout)
        return {
            "url": url,
            "status_code": response.status_code,
            "response_time": response.elapsed.total_seconds(),
            "healthy": response.status_code == 200,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        return {
            "url": url,
            "error": str(e),
            "healthy": False,
            "timestamp": datetime.now().isoformat()
        }

def main():
    # 从环境变量获取API列表
    api_urls = os.environ.get('API_URLS', '').split(',')
    if not api_urls or api_urls == ['']:
        api_urls = [
            'http://vss-backend:3002/health',
            'http://vss-yolo-inference:8000/health',
            'http://vss-data-analysis-server:8086/health'
        ]
    
    results = []
    for url in api_urls:
        url = url.strip()
        if url:
            result = check_api_health(url)
            results.append(result)
            
            status = "✅" if result.get("healthy") else "❌"
            print(f"{status} {url}: {result.get('status_code', 'ERROR')}")
    
    # 输出详细结果
    print("\\n详细结果:")
    print(json.dumps(results, indent=2, ensure_ascii=False))
    
    # 检查是否有失败的API
    failed_apis = [r for r in results if not r.get("healthy")]
    if failed_apis:
        print(f"\\n警告: {len(failed_apis)} 个API不健康")
        exit(1)
    else:
        print(f"\\n所有 {len(results)} 个API都健康")

if __name__ == "__main__":
    main()
''',
                "default_parameters": {
                    "API_URLS": "http://vss-backend:3002/health,http://vss-yolo-inference:8000/health"
                },
                "required_parameters": [],
                "parameter_schema": {
                    "API_URLS": {
                        "type": "string",
                        "description": "要检查的API URL列表，用逗号分隔"
                    }
                }
            }
        ]

class ScriptExecutor:
    """脚本执行器工具类"""
    
    @staticmethod
    def prepare_environment(base_env: Dict[str, Any], custom_env: Dict[str, Any]) -> Dict[str, str]:
        """准备执行环境变量"""
        env = os.environ.copy()
        
        # 添加基础环境变量
        for key, value in base_env.items():
            env[key] = str(value)
        
        # 添加自定义环境变量
        for key, value in custom_env.items():
            env[key] = str(value)
        
        return env
    
    @staticmethod
    def format_output(output: str, max_length: int = 10000) -> str:
        """格式化输出内容"""
        if not output:
            return ""
        
        if len(output) > max_length:
            return output[:max_length] + f"\\n... (输出被截断，总长度: {len(output)} 字符)"
        
        return output

class LogManager:
    """日志管理器"""
    
    @staticmethod
    def setup_logging(log_level: str = "INFO", log_file: str = None):
        """设置日志配置"""
        level = getattr(logging, log_level.upper(), logging.INFO)
        
        handlers = [logging.StreamHandler()]
        if log_file:
            handlers.append(logging.FileHandler(log_file))
        
        logging.basicConfig(
            level=level,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=handlers
        )
    
    @staticmethod
    def get_logger(name: str) -> logging.Logger:
        """获取日志记录器"""
        return logging.getLogger(name)