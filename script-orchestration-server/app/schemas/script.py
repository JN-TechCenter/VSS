from pydantic import BaseModel, Field, validator
from typing import Optional, Dict, List, Any, TypeVar, Generic
from datetime import datetime
from enum import Enum

T = TypeVar('T')

class ScriptStatus(str, Enum):
    """脚本状态枚举"""
    DRAFT = "draft"
    ACTIVE = "active"
    INACTIVE = "inactive"
    ARCHIVED = "archived"

class ExecutionStatus(str, Enum):
    """执行状态枚举"""
    PENDING = "pending"
    RUNNING = "running"
    SUCCESS = "success"
    FAILED = "failed"
    CANCELLED = "cancelled"
    TIMEOUT = "timeout"

class TriggerType(str, Enum):
    """触发器类型枚举"""
    MANUAL = "manual"
    CRON = "cron"
    EVENT = "event"
    API = "api"

# 脚本相关模式
class ScriptBase(BaseModel):
    """脚本基础模式"""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    category: str = Field(default="general", max_length=100)
    content: str = Field(..., min_length=1)
    language: str = Field(default="python", max_length=50)
    version: str = Field(default="1.0.0", max_length=20)
    config: Dict[str, Any] = Field(default_factory=dict)
    parameters: Dict[str, Any] = Field(default_factory=dict)
    environment: Dict[str, Any] = Field(default_factory=dict)
    timeout: int = Field(default=300, ge=1, le=3600)
    max_retries: int = Field(default=3, ge=0, le=10)
    retry_delay: int = Field(default=60, ge=0, le=3600)
    trigger_type: TriggerType = TriggerType.MANUAL
    trigger_config: Dict[str, Any] = Field(default_factory=dict)

class ScriptCreate(ScriptBase):
    """创建脚本模式"""
    pass

class ScriptUpdate(BaseModel):
    """更新脚本模式"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    category: Optional[str] = Field(None, max_length=100)
    content: Optional[str] = Field(None, min_length=1)
    language: Optional[str] = Field(None, max_length=50)
    version: Optional[str] = Field(None, max_length=20)
    config: Optional[Dict[str, Any]] = None
    parameters: Optional[Dict[str, Any]] = None
    environment: Optional[Dict[str, Any]] = None
    status: Optional[ScriptStatus] = None
    timeout: Optional[int] = Field(None, ge=1, le=3600)
    max_retries: Optional[int] = Field(None, ge=0, le=10)
    retry_delay: Optional[int] = Field(None, ge=0, le=3600)
    trigger_type: Optional[TriggerType] = None
    trigger_config: Optional[Dict[str, Any]] = None

class ScriptResponse(ScriptBase):
    """脚本响应模式"""
    id: int
    status: ScriptStatus
    is_template: bool
    created_at: datetime
    updated_at: Optional[datetime]
    created_by: Optional[str]
    
    class Config:
        from_attributes = True

# 脚本执行相关模式
class ScriptExecutionCreate(BaseModel):
    """创建脚本执行模式"""
    script_id: int
    input_parameters: Dict[str, Any] = Field(default_factory=dict)
    environment_vars: Dict[str, Any] = Field(default_factory=dict)
    triggered_by: Optional[str] = None
    trigger_source: str = "manual"

class ScriptExecutionResponse(BaseModel):
    """脚本执行响应模式"""
    id: int
    script_id: int
    execution_id: str
    status: ExecutionStatus
    input_parameters: Dict[str, Any]
    environment_vars: Dict[str, Any]
    output: Optional[str]
    error_message: Optional[str]
    exit_code: Optional[int]
    start_time: Optional[datetime]
    end_time: Optional[datetime]
    duration: Optional[int]
    triggered_by: Optional[str]
    trigger_source: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# 脚本模板相关模式
class ScriptTemplateBase(BaseModel):
    """脚本模板基础模式"""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    category: str = Field(default="general", max_length=100)
    template_content: str = Field(..., min_length=1)
    language: str = Field(default="python", max_length=50)
    default_parameters: Dict[str, Any] = Field(default_factory=dict)
    required_parameters: List[str] = Field(default_factory=list)
    parameter_schema: Dict[str, Any] = Field(default_factory=dict)
    is_public: bool = True
    is_featured: bool = False

class ScriptTemplateCreate(ScriptTemplateBase):
    """创建脚本模板模式"""
    pass

class ScriptTemplateUpdate(BaseModel):
    """更新脚本模板模式"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    category: Optional[str] = Field(None, max_length=100)
    template_content: Optional[str] = Field(None, min_length=1)
    language: Optional[str] = Field(None, max_length=50)
    default_parameters: Optional[Dict[str, Any]] = None
    required_parameters: Optional[List[str]] = None
    parameter_schema: Optional[Dict[str, Any]] = None
    is_public: Optional[bool] = None
    is_featured: Optional[bool] = None

class ScriptTemplateResponse(ScriptTemplateBase):
    """脚本模板响应模式"""
    id: int
    usage_count: int
    created_at: datetime
    updated_at: Optional[datetime]
    created_by: Optional[str]
    
    class Config:
        from_attributes = True

# 工作流相关模式
class WorkflowNodeBase(BaseModel):
    """工作流节点基础模式"""
    node_id: str = Field(..., min_length=1, max_length=100)
    node_type: str = Field(..., min_length=1, max_length=50)
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    config: Dict[str, Any] = Field(default_factory=dict)
    position: Dict[str, Any] = Field(default_factory=dict)
    script_id: Optional[int] = None

class WorkflowNodeCreate(WorkflowNodeBase):
    """创建工作流节点模式"""
    workflow_id: str = Field(..., min_length=1, max_length=100)

class WorkflowNodeResponse(WorkflowNodeBase):
    """工作流节点响应模式"""
    id: int
    workflow_id: str
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True

class WorkflowEdgeBase(BaseModel):
    """工作流连接基础模式"""
    source_node_id: str = Field(..., min_length=1, max_length=100)
    target_node_id: str = Field(..., min_length=1, max_length=100)
    condition: Dict[str, Any] = Field(default_factory=dict)

class WorkflowEdgeCreate(WorkflowEdgeBase):
    """创建工作流连接模式"""
    workflow_id: str = Field(..., min_length=1, max_length=100)

class WorkflowEdgeResponse(WorkflowEdgeBase):
    """工作流连接响应模式"""
    id: int
    workflow_id: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# 通用响应模式
class MessageResponse(BaseModel):
    """消息响应模式"""
    message: str
    success: bool = True
    data: Optional[Any] = None

class PaginatedResponse(BaseModel, Generic[T]):
    """分页响应模式"""
    items: List[T]
    total: int
    page: int
    size: int
    pages: int

# 统计相关模式
class ScriptStatistics(BaseModel):
    """脚本统计模式"""
    total_scripts: int
    active_scripts: int
    total_executions: int
    success_rate: float
    avg_execution_time: float
    recent_executions: List[ScriptExecutionResponse]