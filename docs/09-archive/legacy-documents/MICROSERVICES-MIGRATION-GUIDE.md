# 🚀 VSS 微服务迁移实施指南

## 📋 当前状态分析

基于现有的 VSS 单体应用，制定渐进式微服务迁移策略。

### 现有架构
```
VSS (单体应用)
├── VSS-frontend (React + TypeScript)
├── VSS-backend (Spring Boot)
│   ├── controller/
│   ├── service/
│   ├── repository/
│   └── model/
└── 基础设施 (Docker + Nginx)
```

## 🎯 迁移策略：绞杀者模式 (Strangler Fig Pattern)

### 第一步：准备阶段 (1周)

#### 1.1 创建新的微服务工作空间
```bash
# 创建微服务根目录
mkdir VSS-microservices
cd VSS-microservices

# 创建各服务目录结构
mkdir -p services/{user,auth,vision,data,analytics,file,notification,config}
mkdir -p gateway
mkdir -p infrastructure/{docker,k8s,monitoring}
mkdir -p shared/{libraries,contracts}
```

#### 1.2 设置服务注册中心
```yaml
# infrastructure/docker/consul.yml
version: '3.8'
services:
  consul:
    image: consul:1.9
    ports:
      - "8500:8500"
    environment:
      - CONSUL_BIND_INTERFACE=eth0
    command: agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0
```

#### 1.3 API Gateway 配置
```nginx
# gateway/nginx.conf
upstream vss-legacy {
    server vss-backend:8080;
}

upstream vss-user-service {
    server user-service:8080;
}

server {
    listen 80;
    
    # 新的用户服务路由
    location /api/v2/users {
        proxy_pass http://vss-user-service;
    }
    
    # 所有其他请求路由到原系统
    location / {
        proxy_pass http://vss-legacy;
    }
}
```

### 第二步：提取用户服务 (2周)

#### 2.1 创建用户微服务项目
```bash
cd services/user
spring init --dependencies=web,jpa,postgresql,redis,consul-discovery \
    --package-name=com.vss.user \
    --name=vss-user-service \
    vss-user-service
```

#### 2.2 数据库迁移策略
```sql
-- 创建独立的用户数据库
CREATE DATABASE vss_user;

-- 从主数据库复制用户相关表
CREATE TABLE users AS SELECT * FROM main_db.users;
CREATE TABLE user_profiles AS SELECT * FROM main_db.user_profiles;
CREATE TABLE user_settings AS SELECT * FROM main_db.user_settings;

-- 设置数据同步（双写模式）
-- 在迁移期间保持数据一致性
```

#### 2.3 用户服务核心代码
```java
// services/user/src/main/java/com/vss/user/controller/UserController.java
@RestController
@RequestMapping("/api/v2/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
        UserDto user = userService.findById(id);
        return ResponseEntity.ok(user);
    }
    
    @PostMapping
    public ResponseEntity<UserDto> createUser(@RequestBody CreateUserRequest request) {
        UserDto user = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<UserDto> updateUser(
            @PathVariable Long id, 
            @RequestBody UpdateUserRequest request) {
        UserDto user = userService.updateUser(id, request);
        return ResponseEntity.ok(user);
    }
}
```

#### 2.4 Docker 配置
```dockerfile
# services/user/Dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/vss-user-service-*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### 2.5 部署配置
```yaml
# services/user/docker-compose.yml
version: '3.8'
services:
  vss-user-service:
    build: .
    ports:
      - "8081:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres-user:5432/vss_user
      - SPRING_REDIS_HOST=redis
      - SPRING_CLOUD_CONSUL_HOST=consul
    depends_on:
      - postgres-user
      - redis
      - consul
  
  postgres-user:
    image: postgres:13
    environment:
      POSTGRES_DB: vss_user
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - user_db_data:/var/lib/postgresql/data

volumes:
  user_db_data:
```

### 第三步：提取认证服务 (2周)

#### 3.1 认证服务核心功能
```java
// services/auth/src/main/java/com/vss/auth/service/AuthService.java
@Service
public class AuthService {
    
    @Autowired
    private JwtTokenProvider tokenProvider;
    
    @Autowired
    private UserServiceClient userServiceClient;
    
    public AuthResponse login(LoginRequest request) {
        // 调用用户服务验证用户
        UserDto user = userServiceClient.validateUser(request.getUsername(), request.getPassword());
        
        if (user != null) {
            String token = tokenProvider.generateToken(user);
            return new AuthResponse(token, user);
        }
        
        throw new InvalidCredentialsException("Invalid username or password");
    }
    
    public boolean validateToken(String token) {
        return tokenProvider.validateToken(token);
    }
}
```

#### 3.2 服务间通信配置
```java
// shared/libraries/src/main/java/com/vss/shared/client/UserServiceClient.java
@FeignClient(name = "vss-user-service", url = "${services.user.url}")
public interface UserServiceClient {
    
    @GetMapping("/api/v2/users/{id}")
    UserDto getUser(@PathVariable("id") Long id);
    
    @PostMapping("/api/v2/users/validate")
    UserDto validateUser(@RequestParam String username, @RequestParam String password);
}
```

### 第四步：视觉算法服务 (3周)

#### 4.1 视觉服务架构
```java
// services/vision/src/main/java/com/vss/vision/service/VisionAnalysisService.java
@Service
public class VisionAnalysisService {
    
    @Autowired
    private ImageProcessingEngine imageProcessor;
    
    @Autowired
    private ModelRepository modelRepository;
    
    @Autowired
    private FileServiceClient fileServiceClient;
    
    public AnalysisResult analyzeImage(String imageId, String modelId) {
        // 从文件服务获取图像
        byte[] imageData = fileServiceClient.downloadFile(imageId);
        
        // 加载分析模型
        VisionModel model = modelRepository.findById(modelId);
        
        // 执行图像分析
        return imageProcessor.analyze(imageData, model);
    }
    
    @Async
    public CompletableFuture<TrainingResult> trainModel(TrainingRequest request) {
        // 异步模型训练
        return CompletableFuture.supplyAsync(() -> {
            return modelTrainer.train(request);
        });
    }
}
```

#### 4.2 性能优化配置
```yaml
# services/vision/application.yml
spring:
  task:
    execution:
      pool:
        core-size: 4
        max-size: 16
        queue-capacity: 100
  
vision:
  processing:
    batch-size: 10
    timeout: 30s
  models:
    cache-size: 100
    preload: true
```

### 第五步：完整的 Docker Compose 编排

#### 5.1 完整微服务编排
```yaml
# docker-compose.microservices.yml
version: '3.8'

services:
  # API Gateway
  nginx-gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./gateway/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - vss-user-service
      - vss-auth-service
      - vss-vision-service
      - vss-legacy

  # Legacy Application (渐进式迁移)
  vss-legacy:
    build: ./VSS-backend
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=microservices
    depends_on:
      - postgres-main
      - redis

  # Microservices
  vss-user-service:
    build: ./services/user
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres-user:5432/vss_user
    depends_on:
      - postgres-user
      - consul

  vss-auth-service:
    build: ./services/auth
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SERVICES_USER_URL=http://vss-user-service:8080
    depends_on:
      - redis
      - consul

  vss-vision-service:
    build: ./services/vision
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - MINIO_ENDPOINT=http://minio:9000
    depends_on:
      - postgres-vision
      - minio
      - consul

  # Infrastructure Services
  consul:
    image: consul:1.9
    ports:
      - "8500:8500"
    command: agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0

  # Databases
  postgres-main:
    image: postgres:13
    environment:
      POSTGRES_DB: vss_main
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_main_data:/var/lib/postgresql/data

  postgres-user:
    image: postgres:13
    environment:
      POSTGRES_DB: vss_user
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_user_data:/var/lib/postgresql/data

  postgres-vision:
    image: postgres:13
    environment:
      POSTGRES_DB: vss_vision
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_vision_data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data

  minio:
    image: minio/minio
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
    command: server /data --console-address ":9001"
    volumes:
      - minio_data:/data

volumes:
  postgres_main_data:
  postgres_user_data:
  postgres_vision_data:
  redis_data:
  minio_data:
```

### 第六步：监控和可观测性

#### 6.1 Prometheus 监控配置
```yaml
# infrastructure/monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'vss-services'
    consul_sd_configs:
      - server: 'consul:8500'
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*microservice.*
        action: keep
```

#### 6.2 服务健康检查
```java
// shared/libraries/src/main/java/com/vss/shared/health/ServiceHealthIndicator.java
@Component
public class ServiceHealthIndicator implements HealthIndicator {
    
    @Override
    public Health health() {
        return Health.up()
            .withDetail("service", "vss-user-service")
            .withDetail("version", "1.0.0")
            .withDetail("timestamp", System.currentTimeMillis())
            .build();
    }
}
```

### 第七步：部署和测试

#### 7.1 分步部署脚本
```bash
#!/bin/bash
# deploy-microservices.sh

echo "🚀 开始微服务部署..."

# 1. 启动基础设施
echo "启动基础设施服务..."
docker-compose -f infrastructure/docker/consul.yml up -d
docker-compose -f infrastructure/docker/monitoring.yml up -d

# 2. 启动数据库
echo "启动数据库服务..."
docker-compose -f infrastructure/docker/databases.yml up -d

# 等待数据库启动
sleep 30

# 3. 启动微服务
echo "启动微服务..."
docker-compose -f docker-compose.microservices.yml up -d

# 4. 健康检查
echo "执行健康检查..."
./scripts/health-check.sh

echo "✅ 微服务部署完成！"
echo "🌐 访问地址: http://localhost"
echo "📊 监控面板: http://localhost:3000"
echo "🔍 服务发现: http://localhost:8500"
```

#### 7.2 健康检查脚本
```bash
#!/bin/bash
# scripts/health-check.sh

services=("vss-user-service:8081" "vss-auth-service:8082" "vss-vision-service:8083")

for service in "${services[@]}"; do
    echo "检查服务: $service"
    if curl -f http://localhost:${service#*:}/actuator/health; then
        echo "✅ $service 健康"
    else
        echo "❌ $service 不健康"
        exit 1
    fi
done

echo "🎉 所有服务健康检查通过！"
```

## 📊 迁移验证

### 功能测试清单
- [ ] 用户注册/登录功能
- [ ] 图像上传和分析
- [ ] 数据查询和展示
- [ ] 权限验证
- [ ] 性能指标

### 性能基准
- **响应时间**: < 200ms (P95)
- **吞吐量**: > 1000 QPS
- **可用性**: > 99.9%
- **错误率**: < 0.1%

### 回滚计划
```bash
# 紧急回滚到单体应用
docker-compose -f docker-compose.yml up -d
```

这个实施指南提供了完整的微服务迁移路径，确保渐进式、安全的架构演进。
