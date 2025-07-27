from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.jobstores.redis import RedisJobStore
from apscheduler.executors.pool import ThreadPoolExecutor
from .config import settings
import logging

logger = logging.getLogger(__name__)

# 配置作业存储
jobstores = {
    'default': RedisJobStore(
        host='vss-redis',
        port=6379,
        db=2,
        password=None
    )
}

# 配置执行器
executors = {
    'default': ThreadPoolExecutor(max_workers=settings.MAX_CONCURRENT_SCRIPTS)
}

# 作业默认配置
job_defaults = {
    'coalesce': False,
    'max_instances': 3,
    'misfire_grace_time': 30
}

# 创建调度器实例
scheduler = AsyncIOScheduler(
    jobstores=jobstores,
    executors=executors,
    job_defaults=job_defaults,
    timezone='Asia/Shanghai'
)

def get_scheduler():
    """获取调度器实例"""
    return scheduler