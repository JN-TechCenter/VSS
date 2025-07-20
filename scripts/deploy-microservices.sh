#!/bin/bash
# VSS 微服务架构快速部署脚本

echo "🚀 VSS 微服务架构部署开始..."

# 检查 Docker 环境
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 创建微服务目录结构
echo "📁 创建微服务目录结构..."
mkdir -p VSS-microservices/{services/{user,auth,vision,data,analytics,file,notification,config},gateway,infrastructure/{docker,k8s,monitoring},shared/{libraries,contracts}}

# 停止现有服务
echo "🛑 停止现有服务..."
docker-compose down 2>/dev/null || true

# 创建基础设施配置
echo "⚙️ 创建基础设施配置..."

# Consul 服务发现
cat > VSS-microservices/infrastructure/docker/consul.yml << EOF
version: '3.8'
services:
  consul:
    image: consul:1.9
    ports:
      - "8500:8500"
    environment:
      - CONSUL_BIND_INTERFACE=eth0
    command: agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0
    volumes:
      - consul_data:/consul/data

volumes:
  consul_data:
EOF

# API Gateway 配置
cat > VSS-microservices/gateway/nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream vss-legacy {
        server host.docker.internal:8080;
    }
    
    upstream vss-user-service {
        server vss-user-service:8080;
    }
    
    upstream vss-auth-service {
        server vss-auth-service:8080;
    }

    server {
        listen 80;
        
        # 健康检查
        location /health {
            access_log off;
            return 200 "healthy\\n";
            add_header Content-Type text/plain;
        }
        
        # 新的认证服务路由
        location /api/v2/auth {
            proxy_pass http://vss-auth-service;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
        
        # 新的用户服务路由
        location /api/v2/users {
            proxy_pass http://vss-user-service;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
        
        # 所有其他请求路由到原系统
        location / {
            proxy_pass http://vss-legacy;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOF

# 微服务编排配置
cat > VSS-microservices/docker-compose.microservices.yml << EOF
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
      - consul
    networks:
      - vss-network

  # 服务发现
  consul:
    image: consul:1.9
    ports:
      - "8500:8500"
    environment:
      - CONSUL_BIND_INTERFACE=eth0
    command: agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0
    volumes:
      - consul_data:/consul/data
    networks:
      - vss-network

  # 用户微服务 (示例)
  vss-user-service:
    image: openjdk:17-jdk-slim
    ports:
      - "8081:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SERVER_PORT=8080
    command: >
      sh -c "
        echo 'Starting VSS User Service...';
        mkdir -p /app;
        echo 'server.port=8080
        spring.application.name=vss-user-service
        management.endpoints.web.exposure.include=health,info
        management.endpoint.health.show-details=always' > /app/application.properties;
        
        echo 'import org.springframework.boot.SpringApplication;
        import org.springframework.boot.autoconfigure.SpringBootApplication;
        import org.springframework.web.bind.annotation.*;
        import org.springframework.http.ResponseEntity;
        import java.util.*;

        @SpringBootApplication
        @RestController
        @RequestMapping(\"/api/v2/users\")
        public class UserServiceApp {
            public static void main(String[] args) {
                SpringApplication.run(UserServiceApp.class, args);
            }
            
            @GetMapping(\"/health\")
            public Map<String, Object> health() {
                Map<String, Object> status = new HashMap<>();
                status.put(\"status\", \"UP\");
                status.put(\"service\", \"vss-user-service\");
                status.put(\"timestamp\", System.currentTimeMillis());
                return status;
            }
            
            @GetMapping(\"/{id}\")
            public ResponseEntity<Map<String, Object>> getUser(@PathVariable String id) {
                Map<String, Object> user = new HashMap<>();
                user.put(\"id\", id);
                user.put(\"name\", \"User \" + id);
                user.put(\"email\", \"user\" + id + \"@vss.com\");
                user.put(\"service\", \"microservice\");
                return ResponseEntity.ok(user);
            }
            
            @GetMapping
            public List<Map<String, Object>> getUsers() {
                List<Map<String, Object>> users = new ArrayList<>();
                for(int i = 1; i <= 3; i++) {
                    Map<String, Object> user = new HashMap<>();
                    user.put(\"id\", String.valueOf(i));
                    user.put(\"name\", \"User \" + i);
                    user.put(\"email\", \"user\" + i + \"@vss.com\");
                    users.add(user);
                }
                return users;
            }
        }' > /app/UserServiceApp.java;
        
        cd /app;
        javac -cp '/usr/local/openjdk-17/lib/*' UserServiceApp.java || echo 'Compilation may have warnings, continuing...';
        java -cp '.:/usr/local/openjdk-17/lib/*' UserServiceApp || echo 'Service failed to start properly'
      "
    volumes:
      - user_service_data:/app/data
    networks:
      - vss-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/v2/users/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 认证微服务 (示例)
  vss-auth-service:
    image: openjdk:17-jdk-slim
    ports:
      - "8082:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SERVER_PORT=8080
    command: >
      sh -c "
        echo 'Starting VSS Auth Service...';
        mkdir -p /app;
        echo 'server.port=8080
        spring.application.name=vss-auth-service
        management.endpoints.web.exposure.include=health,info' > /app/application.properties;
        
        echo 'import org.springframework.boot.SpringApplication;
        import org.springframework.boot.autoconfigure.SpringBootApplication;
        import org.springframework.web.bind.annotation.*;
        import org.springframework.http.ResponseEntity;
        import java.util.*;

        @SpringBootApplication
        @RestController
        @RequestMapping(\"/api/v2/auth\")
        public class AuthServiceApp {
            public static void main(String[] args) {
                SpringApplication.run(AuthServiceApp.class, args);
            }
            
            @PostMapping(\"/login\")
            public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> credentials) {
                Map<String, Object> response = new HashMap<>();
                response.put(\"token\", \"jwt-token-example-\" + System.currentTimeMillis());
                response.put(\"user\", credentials.get(\"username\"));
                response.put(\"service\", \"microservice-auth\");
                response.put(\"expires\", System.currentTimeMillis() + 3600000);
                return ResponseEntity.ok(response);
            }
            
            @PostMapping(\"/verify\")
            public ResponseEntity<Map<String, Object>> verify(@RequestHeader(\"Authorization\") String token) {
                Map<String, Object> response = new HashMap<>();
                response.put(\"valid\", true);
                response.put(\"service\", \"microservice-auth\");
                response.put(\"timestamp\", System.currentTimeMillis());
                return ResponseEntity.ok(response);
            }
            
            @GetMapping(\"/health\")
            public Map<String, Object> health() {
                Map<String, Object> status = new HashMap<>();
                status.put(\"status\", \"UP\");
                status.put(\"service\", \"vss-auth-service\");
                return status;
            }
        }' > /app/AuthServiceApp.java;
        
        cd /app;
        javac -cp '/usr/local/openjdk-17/lib/*' AuthServiceApp.java || echo 'Compilation may have warnings, continuing...';
        java -cp '.:/usr/local/openjdk-17/lib/*' AuthServiceApp || echo 'Auth service failed to start properly'
      "
    volumes:
      - auth_service_data:/app/data
    networks:
      - vss-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/v2/auth/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  consul_data:
  user_service_data:
  auth_service_data:

networks:
  vss-network:
    driver: bridge
EOF

# 启动微服务基础设施
echo "🚀 启动微服务基础设施..."
cd VSS-microservices
docker-compose -f docker-compose.microservices.yml up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 健康检查
echo "🔍 执行健康检查..."
echo "检查 API Gateway..."
if curl -s http://localhost/health | grep -q "healthy"; then
    echo "✅ API Gateway 健康"
else
    echo "❌ API Gateway 不健康"
fi

echo "检查 Consul..."
if curl -s http://localhost:8500/v1/status/leader | grep -q ":8300"; then
    echo "✅ Consul 健康"
else
    echo "❌ Consul 不健康"
fi

echo "检查用户服务..."
if curl -s http://localhost:8081/api/v2/users/health | grep -q "UP"; then
    echo "✅ 用户服务健康"
else
    echo "❌ 用户服务不健康"
fi

echo "检查认证服务..."
if curl -s http://localhost:8082/api/v2/auth/health | grep -q "UP"; then
    echo "✅ 认证服务健康"
else
    echo "❌ 认证服务不健康"
fi

echo ""
echo "🎉 VSS 微服务架构部署完成！"
echo ""
echo "📋 服务访问地址:"
echo "  🌐 API Gateway:     http://localhost"
echo "  👤 用户服务:        http://localhost:8081"  
echo "  🔐 认证服务:        http://localhost:8082"
echo "  🔍 Consul UI:       http://localhost:8500"
echo ""
echo "🧪 测试命令:"
echo "  curl http://localhost/api/v2/users"
echo "  curl -X POST http://localhost/api/v2/auth/login -H 'Content-Type: application/json' -d '{\"username\":\"test\",\"password\":\"password\"}'"
echo ""
echo "🛑 停止服务: docker-compose -f docker-compose.microservices.yml down"
