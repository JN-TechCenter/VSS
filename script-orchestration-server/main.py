from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import logging
from datetime import datetime
import os

# 导入应用模块
from app.api.v1 import scripts
from app.core.config import settings
from app.core.database import engine, Base
from app.core.scheduler import scheduler

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/script-orchestration.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# 创建FastAPI应用
app = FastAPI(
    title="VSS Script Orchestration Service",
    description="VSS视觉监控平台脚本编排服务",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 创建数据库表
@app.on_event("startup")
async def startup_event():
    """应用启动时的初始化操作"""
    try:
        # 创建数据库表
        Base.metadata.create_all(bind=engine)
        
        # 启动调度器
        scheduler.start()
        
        logger.info("脚本编排服务启动成功")
        logger.info(f"服务运行在端口: {settings.PORT}")
        
    except Exception as e:
        logger.error(f"服务启动失败: {str(e)}")
        raise

@app.on_event("shutdown")
async def shutdown_event():
    """应用关闭时的清理操作"""
    try:
        # 关闭调度器
        scheduler.shutdown()
        logger.info("脚本编排服务已关闭")
    except Exception as e:
        logger.error(f"服务关闭时出错: {str(e)}")

# 健康检查端点
@app.get("/health")
async def health_check():
    """健康检查接口"""
    return {
        "status": "healthy",
        "service": "script-orchestration-server",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    }

# 根路径
@app.get("/")
async def root():
    """根路径接口"""
    return {
        "message": "VSS Script Orchestration Service",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

# 注册API路由
app.include_router(
    scripts.router,
    prefix="/api/v1/scripts",
    tags=["scripts"]
)

# 全局异常处理
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """全局异常处理器"""
    logger.error(f"未处理的异常: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "内部服务器错误",
            "message": "服务暂时不可用，请稍后重试",
            "timestamp": datetime.now().isoformat()
        }
    )

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=settings.PORT,
        reload=True,
        log_level="info"
    )