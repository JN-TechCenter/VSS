#!/usr/bin/env node
/**
 * VSS 配置管理工具
 * 用于读取、验证和生成环境配置
 */

const fs = require('fs');
const path = require('path');

class ConfigManager {
    constructor() {
        this.baseConfigFile = '.env';
        this.devConfigFile = '.env.development';
        this.prodConfigFile = '.env.production';
        this.dockerConfigFile = '.env.docker';
        
        this.config = {};
        this.requiredVars = [
            'APP_NAME',
            'FRONTEND_PORT',
            'BACKEND_PORT',
            'DB_TYPE',
            'NODE_ENV'
        ];
    }

    /**
     * 解析 .env 文件
     */
    parseEnvFile(filePath) {
        if (!fs.existsSync(filePath)) {
            console.warn(`⚠️  配置文件不存在: ${filePath}`);
            return {};
        }

        const content = fs.readFileSync(filePath, 'utf8');
        const config = {};

        content.split('\n').forEach(line => {
            line = line.trim();
            
            // 跳过注释和空行
            if (!line || line.startsWith('#')) return;
            
            const [key, ...valueParts] = line.split('=');
            if (key && valueParts.length > 0) {
                let value = valueParts.join('=');
                
                // 处理引号
                if ((value.startsWith('"') && value.endsWith('"')) ||
                    (value.startsWith("'") && value.endsWith("'"))) {
                    value = value.slice(1, -1);
                }
                
                // 处理变量替换 ${VAR_NAME}
                value = this.resolveVariables(value, config);
                
                config[key.trim()] = value;
            }
        });

        return config;
    }

    /**
     * 解析变量引用
     */
    resolveVariables(value, config) {
        return value.replace(/\$\{([^}]+)\}/g, (match, varName) => {
            const [name, defaultValue] = varName.split(':-');
            return config[name] || process.env[name] || defaultValue || match;
        });
    }

    /**
     * 加载指定环境的配置
     */
    loadConfig(environment = 'development') {
        console.log(`📥 加载 ${environment} 环境配置...`);

        // 加载基础配置
        const baseConfig = this.parseEnvFile(this.baseConfigFile);
        this.config = { ...baseConfig };

        // 加载环境特定配置
        let envConfigFile;
        switch (environment) {
            case 'development':
            case 'dev':
                envConfigFile = this.devConfigFile;
                break;
            case 'production':
            case 'prod':
                envConfigFile = this.prodConfigFile;
                break;
            default:
                console.warn(`⚠️  未知环境: ${environment}，使用开发环境配置`);
                envConfigFile = this.devConfigFile;
        }

        if (envConfigFile) {
            const envConfig = this.parseEnvFile(envConfigFile);
            this.config = { ...this.config, ...envConfig };
        }

        // 解析所有变量引用
        this.resolveAllVariables();

        console.log(`✅ 配置加载完成`);
        return this.config;
    }

    /**
     * 解析所有变量引用
     */
    resolveAllVariables() {
        let changed = true;
        let iterations = 0;
        const maxIterations = 10;

        while (changed && iterations < maxIterations) {
            changed = false;
            iterations++;

            for (const [key, value] of Object.entries(this.config)) {
                if (typeof value === 'string' && value.includes('${')) {
                    const newValue = this.resolveVariables(value, this.config);
                    if (newValue !== value) {
                        this.config[key] = newValue;
                        changed = true;
                    }
                }
            }
        }

        if (iterations >= maxIterations) {
            console.warn(`⚠️  变量解析可能存在循环引用`);
        }
    }

    /**
     * 验证配置
     */
    validateConfig() {
        console.log(`🔍 验证配置...`);
        
        const errors = [];
        const warnings = [];

        // 检查必需变量
        this.requiredVars.forEach(varName => {
            if (!this.config[varName]) {
                errors.push(`缺少必需变量: ${varName}`);
            }
        });

        // 检查端口冲突
        const ports = [
            this.config.FRONTEND_PORT,
            this.config.BACKEND_PORT,
            this.config.NGINX_PORT
        ].filter(port => port && !isNaN(port));

        const uniquePorts = [...new Set(ports)];
        if (ports.length !== uniquePorts.length) {
            warnings.push(`端口配置可能存在冲突: ${ports.join(', ')}`);
        }

        // 检查数据库配置
        if (this.config.DB_TYPE && !this.config.DB_HOST) {
            errors.push(`数据库类型为 ${this.config.DB_TYPE} 但缺少 DB_HOST`);
        }

        // 输出结果
        if (errors.length > 0) {
            console.error(`❌ 配置验证失败:`);
            errors.forEach(error => console.error(`   ${error}`));
            return false;
        }

        if (warnings.length > 0) {
            console.warn(`⚠️  配置警告:`);
            warnings.forEach(warning => console.warn(`   ${warning}`));
        }

        console.log(`✅ 配置验证通过`);
        return true;
    }

    /**
     * 生成 Docker 环境文件
     */
    generateDockerEnv(environment = 'development') {
        console.log(`🐳 生成 ${environment} 环境的 Docker 配置文件...`);

        this.loadConfig(environment);
        
        if (!this.validateConfig()) {
            console.error(`❌ 配置验证失败，无法生成 Docker 配置`);
            process.exit(1);
        }

        const dockerConfig = Object.entries(this.config)
            .filter(([key, value]) => value !== undefined && value !== '')
            .map(([key, value]) => `${key}=${value}`)
            .join('\n');

        const header = `# VSS Docker 环境配置 - ${environment.toUpperCase()}
# 由配置管理工具自动生成
# 生成时间: ${new Date().toISOString()}
# ==========================================

`;

        fs.writeFileSync(this.dockerConfigFile, header + dockerConfig);
        console.log(`✅ Docker 配置文件已生成: ${this.dockerConfigFile}`);
    }

    /**
     * 显示当前配置
     */
    showConfig(environment = 'development') {
        this.loadConfig(environment);
        
        console.log(`\n📋 ${environment.toUpperCase()} 环境配置:`);
        console.log(`${'='.repeat(50)}`);
        
        // 按类别显示配置
        const categories = {
            '应用信息': ['APP_NAME', 'APP_VERSION', 'APP_DESCRIPTION'],
            '端口配置': ['FRONTEND_PORT', 'BACKEND_PORT', 'NGINX_PORT', 'MAILHOG_WEB_PORT'],
            '数据库配置': ['DB_TYPE', 'DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USERNAME'],
            'API 配置': ['API_BASE_URL', 'API_PREFIX', 'API_TIMEOUT'],
            '环境变量': ['NODE_ENV', 'SPRING_PROFILES_ACTIVE', 'LOG_LEVEL']
        };

        Object.entries(categories).forEach(([category, vars]) => {
            console.log(`\n[${category}]`);
            vars.forEach(varName => {
                const value = this.config[varName];
                if (value !== undefined) {
                    // 隐藏敏感信息
                    const displayValue = varName.includes('PASSWORD') || varName.includes('SECRET') 
                        ? '*'.repeat(8) 
                        : value;
                    console.log(`  ${varName}=${displayValue}`);
                }
            });
        });

        console.log(`\n${'='.repeat(50)}`);
    }

    /**
     * 列出所有可用端口
     */
    listPorts(environment = 'development') {
        this.loadConfig(environment);
        
        console.log(`\n🔌 ${environment.toUpperCase()} 环境端口配置:`);
        console.log(`${'='.repeat(40)}`);
        
        const portVars = Object.entries(this.config)
            .filter(([key, value]) => key.includes('PORT') && !isNaN(value))
            .sort(([, a], [, b]) => parseInt(a) - parseInt(b));

        portVars.forEach(([key, port]) => {
            const service = key.replace('_PORT', '').toLowerCase();
            console.log(`  ${service.padEnd(15)} : ${port}`);
        });
        
        console.log(`${'='.repeat(40)}`);
    }
}

// CLI 接口
if (require.main === module) {
    const config = new ConfigManager();
    const command = process.argv[2];
    const environment = process.argv[3] || 'development';

    switch (command) {
        case 'load':
            config.loadConfig(environment);
            break;
        case 'validate':
            config.loadConfig(environment);
            config.validateConfig();
            break;
        case 'show':
            config.showConfig(environment);
            break;
        case 'docker':
            config.generateDockerEnv(environment);
            break;
        case 'ports':
            config.listPorts(environment);
            break;
        case 'help':
        default:
            console.log(`
🔧 VSS 配置管理工具

用法: node config-manager.js [命令] [环境]

命令:
  load [env]     - 加载环境配置
  validate [env] - 验证配置文件
  show [env]     - 显示配置内容
  docker [env]   - 生成 Docker 环境文件
  ports [env]    - 列出端口配置
  help          - 显示帮助

环境:
  dev, development  - 开发环境
  prod, production  - 生产环境

示例:
  node config-manager.js show dev
  node config-manager.js docker prod
  node config-manager.js ports dev
            `);
    }
}

module.exports = ConfigManager;
