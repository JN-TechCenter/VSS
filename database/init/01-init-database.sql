-- VSS 生产数据库初始化脚本
-- 创建时间: 2025-07-22

-- 设置时区和编码
SET timezone = 'Asia/Shanghai';
SET client_encoding = 'UTF8';

-- 创建扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- 创建应用用户（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'vss_app_user') THEN
        CREATE ROLE vss_app_user WITH LOGIN PASSWORD 'vss_app_password';
    END IF;
END
$$;

-- 授权
GRANT CONNECT ON DATABASE vss_production_db TO vss_app_user;
GRANT USAGE ON SCHEMA public TO vss_app_user;
GRANT CREATE ON SCHEMA public TO vss_app_user;

-- 创建基础表结构

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 项目表
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'active',
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 图像数据表
CREATE TABLE IF NOT EXISTS images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    width INTEGER,
    height INTEGER,
    format VARCHAR(10),
    upload_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}'
);

-- 检测结果表
CREATE TABLE IF NOT EXISTS detection_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    image_id UUID REFERENCES images(id) ON DELETE CASCADE,
    model_name VARCHAR(100),
    model_version VARCHAR(50),
    confidence_threshold FLOAT DEFAULT 0.5,
    results JSONB NOT NULL,
    processing_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 分析报告表
CREATE TABLE IF NOT EXISTS analysis_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    report_type VARCHAR(50),
    title VARCHAR(200),
    content JSONB NOT NULL,
    summary TEXT,
    generated_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 系统日志表
CREATE TABLE IF NOT EXISTS system_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level VARCHAR(10) NOT NULL,
    service VARCHAR(50),
    message TEXT NOT NULL,
    details JSONB,
    user_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_projects_owner ON projects(owner_id);
CREATE INDEX IF NOT EXISTS idx_images_project ON images(project_id);
CREATE INDEX IF NOT EXISTS idx_images_processed ON images(processed);
CREATE INDEX IF NOT EXISTS idx_detection_results_image ON detection_results(image_id);
CREATE INDEX IF NOT EXISTS idx_detection_results_created ON detection_results(created_at);
CREATE INDEX IF NOT EXISTS idx_analysis_reports_project ON analysis_reports(project_id);
CREATE INDEX IF NOT EXISTS idx_system_logs_level ON system_logs(level);
CREATE INDEX IF NOT EXISTS idx_system_logs_service ON system_logs(service);
CREATE INDEX IF NOT EXISTS idx_system_logs_created ON system_logs(created_at);

-- 授权表访问权限
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO vss_app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO vss_app_user;

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要的表添加更新时间触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入默认管理员用户 (密码: admin123)
INSERT INTO users (id, username, email, password_hash, full_name, role) 
VALUES (
    uuid_generate_v4(),
    'admin',
    'admin@vss.local',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdOVOXcQC.PJ.6O', -- admin123
    'System Administrator',
    'admin'
) ON CONFLICT (username) DO NOTHING;

-- 创建示例项目
INSERT INTO projects (id, name, description, owner_id) 
SELECT 
    uuid_generate_v4(),
    'VSS 示例项目',
    '这是一个用于演示VSS平台功能的示例项目',
    u.id
FROM users u WHERE u.username = 'admin'
ON CONFLICT DO NOTHING;

COMMIT;
