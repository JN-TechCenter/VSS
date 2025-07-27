from fastapi import APIRouter, Depends, HTTPException, Query, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
import logging

from app.core.database import get_db
from app.services.script_service import ScriptService
from app.schemas.script import (
    ScriptCreate, ScriptUpdate, ScriptResponse,
    ScriptExecutionCreate, ScriptExecutionResponse,
    ScriptTemplateCreate, ScriptTemplateUpdate, ScriptTemplateResponse,
    MessageResponse, PaginatedResponse, ScriptStatistics,
    ScriptStatus, ExecutionStatus
)

logger = logging.getLogger(__name__)

router = APIRouter()

# 依赖注入
def get_script_service(db: Session = Depends(get_db)) -> ScriptService:
    """获取脚本服务实例"""
    return ScriptService(db)

# 脚本管理接口
@router.post("/", response_model=ScriptResponse)
async def create_script(
    script_data: ScriptCreate,
    script_service: ScriptService = Depends(get_script_service)
):
    """创建脚本"""
    try:
        script = script_service.create_script(script_data, created_by="system")
        return script
    except Exception as e:
        logger.error(f"创建脚本失败: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=PaginatedResponse[ScriptResponse])
async def get_scripts(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    status: Optional[ScriptStatus] = None,
    category: Optional[str] = None,
    search: Optional[str] = None,
    script_service: ScriptService = Depends(get_script_service)
):
    """获取脚本列表"""
    try:
        scripts = script_service.get_scripts(
            skip=skip, 
            limit=limit, 
            status=status, 
            category=category, 
            search=search
        )
        
        # 获取总数
        total = script_service.get_scripts_count(
            status=status,
            category=category,
            search=search
        )
        
        # 计算分页信息
        page = (skip // limit) + 1
        pages = (total + limit - 1) // limit
        
        return PaginatedResponse[ScriptResponse](
            items=scripts,
            total=total,
            page=page,
            size=limit,
            pages=pages
        )
    except Exception as e:
        logger.error(f"获取脚本列表失败: {str(e)}")
        raise HTTPException(status_code=500, detail="获取脚本列表失败")

@router.get("/{script_id}", response_model=ScriptResponse)
async def get_script(
    script_id: int,
    script_service: ScriptService = Depends(get_script_service)
):
    """获取脚本详情"""
    script = script_service.get_script(script_id)
    if not script:
        raise HTTPException(status_code=404, detail="脚本不存在")
    return script

@router.put("/{script_id}", response_model=ScriptResponse)
async def update_script(
    script_id: int,
    script_data: ScriptUpdate,
    script_service: ScriptService = Depends(get_script_service)
):
    """更新脚本"""
    try:
        script = script_service.update_script(script_id, script_data)
        if not script:
            raise HTTPException(status_code=404, detail="脚本不存在")
        return script
    except Exception as e:
        logger.error(f"更新脚本失败: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{script_id}", response_model=MessageResponse)
async def delete_script(
    script_id: int,
    script_service: ScriptService = Depends(get_script_service)
):
    """删除脚本"""
    try:
        success = script_service.delete_script(script_id)
        if not success:
            raise HTTPException(status_code=404, detail="脚本不存在")
        return MessageResponse(message="脚本删除成功")
    except Exception as e:
        logger.error(f"删除脚本失败: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

# 脚本执行接口
@router.post("/{script_id}/execute", response_model=ScriptExecutionResponse)
async def execute_script(
    script_id: int,
    execution_data: Optional[dict] = None,
    script_service: ScriptService = Depends(get_script_service)
):
    """执行脚本"""
    try:
        if execution_data is None:
            execution_data = {}
        
        exec_request = ScriptExecutionCreate(
            script_id=script_id,
            input_parameters=execution_data.get("input_parameters", {}),
            environment_vars=execution_data.get("environment_vars", {}),
            triggered_by=execution_data.get("triggered_by", "api"),
            trigger_source="api"
        )
        
        execution = await script_service.execute_script(exec_request, triggered_by="api")
        return execution
    except Exception as e:
        logger.error(f"执行脚本失败: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{script_id}/executions", response_model=List[ScriptExecutionResponse])
async def get_script_executions(
    script_id: int,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    status: Optional[ExecutionStatus] = None,
    script_service: ScriptService = Depends(get_script_service)
):
    """获取脚本执行记录"""
    try:
        executions = script_service.get_executions(
            script_id=script_id,
            status=status,
            skip=skip,
            limit=limit
        )
        return executions
    except Exception as e:
        logger.error(f"获取执行记录失败: {str(e)}")
        raise HTTPException(status_code=500, detail="获取执行记录失败")

# 执行管理接口
@router.get("/executions/", response_model=List[ScriptExecutionResponse])
async def get_all_executions(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    status: Optional[ExecutionStatus] = None,
    script_service: ScriptService = Depends(get_script_service)
):
    """获取所有执行记录"""
    try:
        executions = script_service.get_executions(
            status=status,
            skip=skip,
            limit=limit
        )
        return executions
    except Exception as e:
        logger.error(f"获取执行记录失败: {str(e)}")
        raise HTTPException(status_code=500, detail="获取执行记录失败")

@router.get("/executions/{execution_id}", response_model=ScriptExecutionResponse)
async def get_execution(
    execution_id: str,
    script_service: ScriptService = Depends(get_script_service)
):
    """获取执行记录详情"""
    execution = script_service.get_execution(execution_id)
    if not execution:
        raise HTTPException(status_code=404, detail="执行记录不存在")
    return execution

@router.post("/executions/{execution_id}/cancel", response_model=MessageResponse)
async def cancel_execution(
    execution_id: str,
    script_service: ScriptService = Depends(get_script_service)
):
    """取消脚本执行"""
    try:
        success = script_service.cancel_execution(execution_id)
        if not success:
            raise HTTPException(status_code=404, detail="执行记录不存在或无法取消")
        return MessageResponse(message="执行已取消")
    except Exception as e:
        logger.error(f"取消执行失败: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

# 脚本模板接口
@router.post("/templates/", response_model=ScriptTemplateResponse)
async def create_template(
    template_data: ScriptTemplateCreate,
    script_service: ScriptService = Depends(get_script_service)
):
    """创建脚本模板"""
    try:
        template = script_service.create_template(template_data, created_by="system")
        return template
    except Exception as e:
        logger.error(f"创建脚本模板失败: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/templates/", response_model=PaginatedResponse[ScriptTemplateResponse])
async def get_templates(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    category: Optional[str] = None,
    is_public: bool = True,
    search: Optional[str] = None,
    script_service: ScriptService = Depends(get_script_service)
):
    """获取脚本模板列表"""
    try:
        templates = script_service.get_templates(
            skip=skip,
            limit=limit,
            category=category,
            is_public=is_public,
            search=search
        )
        
        # 获取总数
        total = script_service.get_templates_count(
            category=category,
            is_public=is_public,
            search=search
        )
        
        # 计算分页信息
        pages = (total + limit - 1) // limit if limit > 0 else 1
        current_page = (skip // limit) + 1 if limit > 0 else 1
        
        return PaginatedResponse[ScriptTemplateResponse](
            items=templates,
            total=total,
            page=current_page,
            size=limit,
            pages=pages
        )
    except Exception as e:
        logger.error(f"获取脚本模板失败: {str(e)}")
        raise HTTPException(status_code=500, detail="获取脚本模板失败")

# 统计接口
@router.get("/statistics/overview")
async def get_statistics(
    script_service: ScriptService = Depends(get_script_service)
):
    """获取脚本统计信息"""
    try:
        stats = script_service.get_statistics()
        return stats
    except Exception as e:
        logger.error(f"获取统计信息失败: {str(e)}")
        raise HTTPException(status_code=500, detail="获取统计信息失败")

# 健康检查接口
@router.get("/health")
async def health_check():
    """健康检查"""
    return {
        "status": "healthy",
        "service": "script-orchestration",
        "version": "1.0.0"
    }