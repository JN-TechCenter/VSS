from pydantic_settings import BaseSettings
from typing import Optional
import os

class Settings(BaseSettings):
    """应用配置类"""
    
    # 基础配置
    APP_NAME: str = "VSS Script Orchestration Service"
    VERSION: str = "1.0.0"
    DEBUG: bool = False
    PORT: int = 8087
    
    # 数据库配置 - 从环境变量获取
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        f"postgresql://{os.getenv('DB_USERNAME', 'prod_user')}:{os.getenv('DB_PASSWORD', 'VSSProd2025!')}@database:5432/{os.getenv('DB_NAME', 'vss_production_db')}"
    )
    DB_POOL_SIZE: int = 2
    DB_MAX_OVERFLOW: int = 3
    DB_POOL_TIMEOUT: int = 30
    DB_POOL_RECYCLE: int = 1800
    
    # Redis配置 - 从环境变量获取
    REDIS_URL: str = os.getenv(
        "REDIS_URL",
        f"redis://:{os.getenv('REDIS_PASSWORD', 'VSSRedis2025!')}@redis:6379/2"
    )
    
    # JWT配置 - 从环境变量获取
    SECRET_KEY: str = os.getenv("JWT_SECRET", "vss-script-orchestration-secret-key-2025")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # 脚本执行配置
    SCRIPT_TIMEOUT: int = int(os.getenv("SCRIPT_TIMEOUT", "300"))  # 5分钟
    MAX_CONCURRENT_SCRIPTS: int = int(os.getenv("MAX_CONCURRENT_SCRIPTS", "10"))
    SCRIPT_STORAGE_PATH: str = os.getenv("SCRIPT_STORAGE_PATH", "/app/scripts")
    
    # 外部服务配置 - 从环境变量获取
    BACKEND_SERVICE_URL: str = os.getenv("BACKEND_SERVICE_URL", "http://backend:3002")
    AI_SERVICE_URL: str = os.getenv("AI_SERVICE_URL", "http://yolo-inference:8084")
    DATA_ANALYSIS_SERVICE_URL: str = os.getenv("DATA_ANALYSIS_SERVICE_URL", "http://data-analysis-server:8086")
    
    class Config:
        env_file = ".env"
        case_sensitive = True

# 创建配置实例
settings = Settings()