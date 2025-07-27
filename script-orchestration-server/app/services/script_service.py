from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc, func
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import uuid
import subprocess
import asyncio
import json
import logging

from app.models.script import Script, ScriptExecution, ScriptTemplate, ScriptStatus, ExecutionStatus
from app.schemas.script import (
    ScriptCreate, ScriptUpdate, ScriptExecutionCreate,
    ScriptTemplateCreate, ScriptTemplateUpdate
)
from app.core.scheduler import get_scheduler

logger = logging.getLogger(__name__)

class ScriptService:
    """脚本服务类"""
    
    def __init__(self, db: Session):
        self.db = db
        self.scheduler = get_scheduler()
    
    # 脚本管理
    def create_script(self, script_data: ScriptCreate, created_by: str = None) -> Script:
        """创建脚本"""
        try:
            # 转换数据，确保枚举值为字符串
            script_dict = script_data.dict()
            
            # 处理枚举字段
            if 'status' in script_dict and hasattr(script_dict['status'], 'value'):
                script_dict['status'] = script_dict['status'].value
            if 'trigger_type' in script_dict and hasattr(script_dict['trigger_type'], 'value'):
                script_dict['trigger_type'] = script_dict['trigger_type'].value
            
            script = Script(
                **script_dict,
                created_by=created_by
            )
            self.db.add(script)
            self.db.commit()
            self.db.refresh(script)
            
            logger.info(f"创建脚本成功: {script.name} (ID: {script.id})")
            return script
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"创建脚本失败: {str(e)}")
            raise
    
    def get_script(self, script_id: int) -> Optional[Script]:
        """获取脚本"""
        return self.db.query(Script).filter(Script.id == script_id).first()
    
    def get_scripts(
        self, 
        skip: int = 0, 
        limit: int = 100,
        status: Optional[ScriptStatus] = None,
        category: Optional[str] = None,
        search: Optional[str] = None
    ) -> List[Script]:
        """获取脚本列表"""
        query = self.db.query(Script)
        
        if status:
            query = query.filter(Script.status == status)
        
        if category:
            query = query.filter(Script.category == category)
        
        if search:
            query = query.filter(
                or_(
                    Script.name.ilike(f"%{search}%"),
                    Script.description.ilike(f"%{search}%")
                )
            )
        
        return query.order_by(desc(Script.created_at)).offset(skip).limit(limit).all()
    
    def get_scripts_count(
        self,
        status: Optional[ScriptStatus] = None,
        category: Optional[str] = None,
        search: Optional[str] = None
    ) -> int:
        """获取脚本总数"""
        query = self.db.query(Script)
        
        if status:
            query = query.filter(Script.status == status)
        
        if category:
            query = query.filter(Script.category == category)
        
        if search:
            query = query.filter(
                or_(
                    Script.name.ilike(f"%{search}%"),
                    Script.description.ilike(f"%{search}%")
                )
            )
        
        return query.count()
    
    def update_script(self, script_id: int, script_data: ScriptUpdate) -> Optional[Script]:
        """更新脚本"""
        try:
            script = self.get_script(script_id)
            if not script:
                return None
            
            update_data = script_data.dict(exclude_unset=True)
            for field, value in update_data.items():
                setattr(script, field, value)
            
            script.updated_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(script)
            
            logger.info(f"更新脚本成功: {script.name} (ID: {script.id})")
            return script
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"更新脚本失败: {str(e)}")
            raise
    
    def delete_script(self, script_id: int) -> bool:
        """删除脚本"""
        try:
            script = self.get_script(script_id)
            if not script:
                return False
            
            # 取消相关的定时任务
            if script.trigger_type.value == "cron":
                try:
                    self.scheduler.remove_job(f"script_{script_id}")
                except:
                    pass
            
            self.db.delete(script)
            self.db.commit()
            
            logger.info(f"删除脚本成功: {script.name} (ID: {script.id})")
            return True
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"删除脚本失败: {str(e)}")
            raise
    
    # 脚本执行
    async def execute_script(
        self, 
        execution_data: ScriptExecutionCreate,
        triggered_by: str = None
    ) -> ScriptExecution:
        """执行脚本"""
        try:
            script = self.get_script(execution_data.script_id)
            if not script:
                raise ValueError(f"脚本不存在: {execution_data.script_id}")
            
            if script.status != ScriptStatus.ACTIVE:
                raise ValueError(f"脚本状态不允许执行: {script.status}")
            
            # 创建执行记录
            execution = ScriptExecution(
                script_id=script.id,
                execution_id=str(uuid.uuid4()),
                input_parameters=execution_data.input_parameters,
                environment_vars=execution_data.environment_vars,
                triggered_by=triggered_by or execution_data.triggered_by,
                trigger_source=execution_data.trigger_source,
                status=ExecutionStatus.PENDING
            )
            
            self.db.add(execution)
            self.db.commit()
            self.db.refresh(execution)
            
            # 异步执行脚本
            asyncio.create_task(self._run_script_async(execution.id, script))
            
            logger.info(f"开始执行脚本: {script.name} (执行ID: {execution.execution_id})")
            return execution
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"执行脚本失败: {str(e)}")
            raise
    
    async def _run_script_async(self, execution_id: int, script: Script):
        """异步运行脚本"""
        execution = self.db.query(ScriptExecution).filter(
            ScriptExecution.id == execution_id
        ).first()
        
        if not execution:
            return
        
        try:
            # 更新状态为运行中
            execution.status = ExecutionStatus.RUNNING
            execution.start_time = datetime.utcnow()
            self.db.commit()
            
            # 准备执行环境
            env_vars = {**script.environment, **execution.environment_vars}
            
            # 根据脚本语言执行
            if script.language == "python":
                result = await self._execute_python_script(script, execution, env_vars)
            elif script.language == "bash":
                result = await self._execute_bash_script(script, execution, env_vars)
            else:
                raise ValueError(f"不支持的脚本语言: {script.language}")
            
            # 更新执行结果
            execution.status = ExecutionStatus.SUCCESS if result["exit_code"] == 0 else ExecutionStatus.FAILED
            execution.output = result["output"]
            execution.error_message = result["error"]
            execution.exit_code = result["exit_code"]
            execution.end_time = datetime.utcnow()
            execution.duration = int((execution.end_time - execution.start_time).total_seconds())
            
            self.db.commit()
            
            logger.info(f"脚本执行完成: {script.name} (状态: {execution.status.value})")
            
        except Exception as e:
            # 更新状态为失败
            execution.status = ExecutionStatus.FAILED
            execution.error_message = str(e)
            execution.end_time = datetime.utcnow()
            if execution.start_time:
                execution.duration = int((execution.end_time - execution.start_time).total_seconds())
            
            self.db.commit()
            logger.error(f"脚本执行异常: {script.name} - {str(e)}")
    
    async def _execute_python_script(
        self, 
        script: Script, 
        execution: ScriptExecution, 
        env_vars: Dict[str, Any]
    ) -> Dict[str, Any]:
        """执行Python脚本"""
        try:
            # 创建临时脚本文件
            script_file = f"/tmp/script_{execution.execution_id}.py"
            with open(script_file, 'w', encoding='utf-8') as f:
                f.write(script.content)
            
            # 执行脚本
            process = await asyncio.create_subprocess_exec(
                'python', script_file,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                env=env_vars
            )
            
            try:
                stdout, stderr = await asyncio.wait_for(
                    process.communicate(), 
                    timeout=script.timeout
                )
                
                return {
                    "output": stdout.decode('utf-8'),
                    "error": stderr.decode('utf-8'),
                    "exit_code": process.returncode
                }
                
            except asyncio.TimeoutError:
                process.kill()
                await process.wait()
                raise Exception("脚本执行超时")
                
        except Exception as e:
            return {
                "output": "",
                "error": str(e),
                "exit_code": 1
            }
    
    async def _execute_bash_script(
        self, 
        script: Script, 
        execution: ScriptExecution, 
        env_vars: Dict[str, Any]
    ) -> Dict[str, Any]:
        """执行Bash脚本"""
        try:
            # 创建临时脚本文件
            script_file = f"/tmp/script_{execution.execution_id}.sh"
            with open(script_file, 'w', encoding='utf-8') as f:
                f.write(script.content)
            
            # 设置执行权限
            subprocess.run(['chmod', '+x', script_file])
            
            # 执行脚本
            process = await asyncio.create_subprocess_exec(
                'bash', script_file,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                env=env_vars
            )
            
            try:
                stdout, stderr = await asyncio.wait_for(
                    process.communicate(), 
                    timeout=script.timeout
                )
                
                return {
                    "output": stdout.decode('utf-8'),
                    "error": stderr.decode('utf-8'),
                    "exit_code": process.returncode
                }
                
            except asyncio.TimeoutError:
                process.kill()
                await process.wait()
                raise Exception("脚本执行超时")
                
        except Exception as e:
            return {
                "output": "",
                "error": str(e),
                "exit_code": 1
            }
    
    def get_execution(self, execution_id: str) -> Optional[ScriptExecution]:
        """获取执行记录"""
        return self.db.query(ScriptExecution).filter(
            ScriptExecution.execution_id == execution_id
        ).first()
    
    def get_executions(
        self, 
        script_id: Optional[int] = None,
        status: Optional[ExecutionStatus] = None,
        skip: int = 0, 
        limit: int = 100
    ) -> List[ScriptExecution]:
        """获取执行记录列表"""
        query = self.db.query(ScriptExecution)
        
        if script_id:
            query = query.filter(ScriptExecution.script_id == script_id)
        
        if status:
            query = query.filter(ScriptExecution.status == status)
        
        return query.order_by(desc(ScriptExecution.created_at)).offset(skip).limit(limit).all()
    
    def cancel_execution(self, execution_id: str) -> bool:
        """取消执行"""
        try:
            execution = self.get_execution(execution_id)
            if not execution or execution.status not in [ExecutionStatus.PENDING, ExecutionStatus.RUNNING]:
                return False
            
            execution.status = ExecutionStatus.CANCELLED
            execution.end_time = datetime.utcnow()
            if execution.start_time:
                execution.duration = int((execution.end_time - execution.start_time).total_seconds())
            
            self.db.commit()
            
            logger.info(f"取消脚本执行: {execution_id}")
            return True
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"取消执行失败: {str(e)}")
            raise
    
    # 脚本模板管理
    def create_template(self, template_data: ScriptTemplateCreate, created_by: str = None) -> ScriptTemplate:
        """创建脚本模板"""
        try:
            template = ScriptTemplate(
                **template_data.dict(),
                created_by=created_by
            )
            self.db.add(template)
            self.db.commit()
            self.db.refresh(template)
            
            logger.info(f"创建脚本模板成功: {template.name} (ID: {template.id})")
            return template
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"创建脚本模板失败: {str(e)}")
            raise
    
    def get_templates(
        self, 
        skip: int = 0, 
        limit: int = 100,
        category: Optional[str] = None,
        is_public: bool = True,
        search: Optional[str] = None
    ) -> List[ScriptTemplate]:
        """获取脚本模板列表"""
        query = self.db.query(ScriptTemplate)
        
        if is_public is not None:
            query = query.filter(ScriptTemplate.is_public == is_public)
        
        if category:
            query = query.filter(ScriptTemplate.category == category)
        
        if search:
            query = query.filter(
                or_(
                    ScriptTemplate.name.ilike(f"%{search}%"),
                    ScriptTemplate.description.ilike(f"%{search}%")
                )
            )
        
        return query.order_by(desc(ScriptTemplate.created_at)).offset(skip).limit(limit).all()
    
    def get_templates_count(
        self,
        category: Optional[str] = None,
        is_public: bool = True,
        search: Optional[str] = None
    ) -> int:
        """获取脚本模板总数"""
        query = self.db.query(ScriptTemplate)
        
        if is_public is not None:
            query = query.filter(ScriptTemplate.is_public == is_public)
        
        if category:
            query = query.filter(ScriptTemplate.category == category)
        
        if search:
            query = query.filter(
                or_(
                    ScriptTemplate.name.ilike(f"%{search}%"),
                    ScriptTemplate.description.ilike(f"%{search}%")
                )
            )
        
        return query.count()
    
    def get_statistics(self) -> Dict[str, Any]:
        """获取脚本统计信息"""
        try:
            # 脚本统计
            total_scripts = self.db.query(Script).count()
            active_scripts = self.db.query(Script).filter(Script.status == ScriptStatus.ACTIVE).count()
            
            # 执行统计
            total_executions = self.db.query(ScriptExecution).count()
            success_executions = self.db.query(ScriptExecution).filter(
                ScriptExecution.status == ExecutionStatus.SUCCESS
            ).count()
            
            success_rate = (success_executions / total_executions * 100) if total_executions > 0 else 0
            
            # 平均执行时间
            avg_duration = self.db.query(func.avg(ScriptExecution.duration)).filter(
                ScriptExecution.status == ExecutionStatus.SUCCESS,
                ScriptExecution.duration.isnot(None)
            ).scalar() or 0
            
            # 最近执行记录
            recent_executions = self.get_executions(limit=10)
            
            return {
                "total_scripts": total_scripts,
                "active_scripts": active_scripts,
                "total_executions": total_executions,
                "success_rate": round(success_rate, 2),
                "avg_execution_time": round(avg_duration, 2),
                "recent_executions": recent_executions
            }
            
        except Exception as e:
            logger.error(f"获取统计信息失败: {str(e)}")
            raise