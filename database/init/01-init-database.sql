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
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    phone_number VARCHAR(20),
    department VARCHAR(100),
    role VARCHAR(20) DEFAULT 'OBSERVER',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    last_login_time TIMESTAMP WITH TIME ZONE,
    login_attempts INTEGER DEFAULT 0,
    account_locked_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
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

-- AI推理历史记录表
CREATE TABLE IF NOT EXISTS inference_history (
    id BIGSERIAL PRIMARY KEY,
    task_id VARCHAR(255) UNIQUE NOT NULL,
    inference_type VARCHAR(50) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    confidence_threshold DOUBLE PRECISION,
    original_filename VARCHAR(255),
    file_size BIGINT,
    image_path VARCHAR(500),
    inference_result TEXT,
    detected_objects_count INTEGER,
    processing_time BIGINT,
    status VARCHAR(20) NOT NULL,
    error_message TEXT,
    user_id UUID REFERENCES users(id),
    username VARCHAR(50),
    device_info VARCHAR(255),
    inference_server VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    tags VARCHAR(500),
    notes TEXT,
    is_deleted BOOLEAN DEFAULT false,
    result_rating INTEGER,
    is_favorite BOOLEAN DEFAULT false
);

-- 设备表
CREATE TABLE IF NOT EXISTS devices (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    location VARCHAR(200),
    ip_address VARCHAR(45),
    port INTEGER,
    status VARCHAR(20) DEFAULT 'offline',
    config JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 视频流表
CREATE TABLE IF NOT EXISTS video_streams (
    id SERIAL PRIMARY KEY,
    stream_id VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    type VARCHAR(20) NOT NULL CHECK (type IN ('LIVE', 'RECORDED', 'RTMP', 'HLS', 'WEBRTC')),
    status VARCHAR(20) DEFAULT 'STOPPED' CHECK (status IN ('STREAMING', 'STOPPED', 'BUFFERING', 'ERROR', 'CONNECTING')),
    source_url VARCHAR(500) NOT NULL,
    output_url VARCHAR(500),
    protocol VARCHAR(20) NOT NULL CHECK (protocol IN ('RTMP', 'RTSP', 'HLS', 'WEBRTC', 'HTTP')),
    quality VARCHAR(10) NOT NULL CHECK (quality IN ('SD', 'HD', 'FHD', 'UHD')),
    resolution VARCHAR(20) NOT NULL,
    frame_rate INTEGER NOT NULL DEFAULT 30,
    bitrate INTEGER NOT NULL DEFAULT 1000,
    device_id INTEGER REFERENCES devices(id) ON DELETE SET NULL,
    enable_recording BOOLEAN DEFAULT false,
    recording_path VARCHAR(500),
    recording_format VARCHAR(20),
    enable_transcoding BOOLEAN DEFAULT false,
    transcoding_preset VARCHAR(50),
    transcoding_formats TEXT[],
    viewer_count INTEGER DEFAULT 0,
    cpu_usage DECIMAL(5,2) DEFAULT 0.0,
    memory_usage DECIMAL(5,2) DEFAULT 0.0,
    network_bandwidth DECIMAL(10,2) DEFAULT 0.0,
    error_count INTEGER DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
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

-- 推理历史记录表索引
CREATE INDEX IF NOT EXISTS idx_inference_history_task_id ON inference_history(task_id);
CREATE INDEX IF NOT EXISTS idx_inference_history_user_id ON inference_history(user_id);
CREATE INDEX IF NOT EXISTS idx_inference_history_status ON inference_history(status);
CREATE INDEX IF NOT EXISTS idx_inference_history_created ON inference_history(created_at);
CREATE INDEX IF NOT EXISTS idx_inference_history_model ON inference_history(model_name);
CREATE INDEX IF NOT EXISTS idx_inference_history_type ON inference_history(inference_type);
CREATE INDEX IF NOT EXISTS idx_inference_history_deleted ON inference_history(is_deleted);
CREATE INDEX IF NOT EXISTS idx_inference_history_favorite ON inference_history(is_favorite);

-- 设备表索引
CREATE INDEX IF NOT EXISTS idx_devices_device_id ON devices(device_id);
CREATE INDEX IF NOT EXISTS idx_devices_status ON devices(status);
CREATE INDEX IF NOT EXISTS idx_devices_type ON devices(type);
CREATE INDEX IF NOT EXISTS idx_devices_created ON devices(created_at);

-- 视频流表索引
CREATE INDEX IF NOT EXISTS idx_video_streams_stream_id ON video_streams(stream_id);
CREATE INDEX IF NOT EXISTS idx_video_streams_status ON video_streams(status);
CREATE INDEX IF NOT EXISTS idx_video_streams_type ON video_streams(type);
CREATE INDEX IF NOT EXISTS idx_video_streams_device ON video_streams(device_id);
CREATE INDEX IF NOT EXISTS idx_video_streams_created ON video_streams(created_at);
CREATE INDEX IF NOT EXISTS idx_video_streams_quality ON video_streams(quality);
CREATE INDEX IF NOT EXISTS idx_video_streams_protocol ON video_streams(protocol);

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
CREATE TRIGGER update_inference_history_updated_at BEFORE UPDATE ON inference_history FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_devices_updated_at BEFORE UPDATE ON devices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_video_streams_updated_at BEFORE UPDATE ON video_streams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入默认管理员用户 (密码: admin123)
INSERT INTO users (id, username, email, password, full_name, role) 
VALUES (
    uuid_generate_v4(),
    'admin',
    'admin@vss.local',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdOVOXcQC.PJ.6O', -- admin123
    'System Administrator',
    'ADMIN'
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

-- 插入示例设备数据
INSERT INTO devices (device_id, name, type, location, ip_address, port, status, config) VALUES
('CAM-001', '生产线摄像头1', 'camera', '生产车间A区', '192.168.1.101', 8080, 'online', '{"resolution": "1920x1080", "fps": 30}'),
('CAM-002', '生产线摄像头2', 'camera', '生产车间B区', '192.168.1.102', 8080, 'online', '{"resolution": "1920x1080", "fps": 30}'),
('CAM-003', '质检摄像头1', 'camera', '质检区域', '192.168.1.103', 8080, 'offline', '{"resolution": "2560x1440", "fps": 60}'),
('SEN-001', '温度传感器1', 'sensor', '生产车间A区', '192.168.1.201', 9090, 'online', '{"type": "temperature", "range": "-40~85"}'),
('SEN-002', '湿度传感器1', 'sensor', '生产车间B区', '192.168.1.202', 9090, 'online', '{"type": "humidity", "range": "0~100"}')
ON CONFLICT (device_id) DO NOTHING;

-- 插入示例视频流数据
INSERT INTO video_streams (stream_id, name, description, type, status, source_url, output_url, protocol, quality, resolution, frame_rate, bitrate, device_id, enable_recording, recording_format, enable_transcoding, transcoding_preset) VALUES
('STREAM-001', '生产线实时监控1', '生产车间A区实时视频流', 'LIVE', 'STREAMING', 'rtsp://192.168.1.101:554/stream1', 'http://localhost:8080/hls/stream1.m3u8', 'RTSP', 'HD', '1920x1080', 30, 2000, 1, true, 'mp4', true, 'fast'),
('STREAM-002', '生产线实时监控2', '生产车间B区实时视频流', 'LIVE', 'STREAMING', 'rtsp://192.168.1.102:554/stream1', 'http://localhost:8080/hls/stream2.m3u8', 'RTSP', 'HD', '1920x1080', 30, 2000, 2, true, 'mp4', false, null),
('STREAM-003', '质检区域监控', '质检区域高清视频流', 'LIVE', 'STOPPED', 'rtsp://192.168.1.103:554/stream1', 'http://localhost:8080/hls/stream3.m3u8', 'RTSP', 'FHD', '2560x1440', 60, 4000, 3, true, 'mp4', true, 'medium'),
('STREAM-004', '录制回放测试', '测试录制视频回放功能', 'RECORDED', 'STOPPED', '/recordings/test_video.mp4', 'http://localhost:8080/playback/test_video.m3u8', 'HTTP', 'HD', '1920x1080', 25, 1500, null, false, null, false, null)
ON CONFLICT (stream_id) DO NOTHING;

COMMIT;
