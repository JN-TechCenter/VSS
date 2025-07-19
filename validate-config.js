#!/usr/bin/env node
/**
 * VSS 配置验证脚本
 * 验证前后端配置的一致性和正确性
 */

const fs = require('fs');
const path = require('path');

class ConfigValidator {
    constructor() {
        this.errors = [];
        this.warnings = [];
        this.projectRoot = process.cwd();
    }

    /**
     * 验证后端配置文件
     */
    validateBackendConfig() {
        console.log('🔍 验证后端配置文件...');
        
        const backendConfigDir = path.join(this.projectRoot, 'VSS-backend', 'src', 'main', 'resources');
        const requiredFiles = [
            'application.properties',
            'application-dev.properties', 
            'application-prod.properties',
            'application-docker.properties'
        ];

        requiredFiles.forEach(file => {
            const filePath = path.join(backendConfigDir, file);
            if (!fs.existsSync(filePath)) {
                this.errors.push(`缺少后端配置文件: ${file}`);
                return;
            }

            // 检查配置文件内容
            const content = fs.readFileSync(filePath, 'utf8');
            this.validateBackendProperties(content, file);
        });
    }

    /**
     * 验证后端配置属性
     */
    validateBackendProperties(content, filename) {
        // 检查是否还有硬编码的端口
        const hardcodedPorts = content.match(/server\.port=\d+(?!\$)/g);
        if (hardcodedPorts) {
            this.warnings.push(`${filename} 中发现硬编码端口: ${hardcodedPorts.join(', ')}`);
        }

        // 检查是否使用了环境变量
        const envVarPattern = /\$\{[^}]+\}/g;
        const envVars = content.match(envVarPattern) || [];
        if (envVars.length === 0 && filename !== 'application.properties') {
            this.warnings.push(`${filename} 中没有使用环境变量`);
        }

        // 检查必需的配置项
        const requiredConfigs = [
            'server.port',
            'spring.datasource.url',
            'spring.jpa.hibernate.ddl-auto'
        ];

        requiredConfigs.forEach(config => {
            if (!content.includes(config)) {
                this.warnings.push(`${filename} 中缺少配置: ${config}`);
            }
        });
    }

    /**
     * 验证前端配置文件
     */
    validateFrontendConfig() {
        console.log('🔍 验证前端配置文件...');
        
        const frontendDir = path.join(this.projectRoot, 'VSS-frontend');
        const requiredFiles = [
            '.env.development',
            '.env.production',
            'vite.config.ts'
        ];

        requiredFiles.forEach(file => {
            const filePath = path.join(frontendDir, file);
            if (!fs.existsSync(filePath)) {
                this.errors.push(`缺少前端配置文件: ${file}`);
                return;
            }

            if (file.startsWith('.env')) {
                const content = fs.readFileSync(filePath, 'utf8');
                this.validateFrontendEnv(content, file);
            }
        });

        // 检查 vite.config.ts
        this.validateViteConfig();
    }

    /**
     * 验证前端环境变量
     */
    validateFrontendEnv(content, filename) {
        // 检查是否有硬编码的 URL
        const hardcodedUrls = content.match(/VITE_API_BASE_URL=http:\/\/localhost:\d+(?!\$)/g);
        if (hardcodedUrls) {
            this.warnings.push(`${filename} 中发现硬编码 URL: ${hardcodedUrls.join(', ')}`);
        }

        // 检查必需的环境变量
        const requiredVars = [
            'VITE_API_BASE_URL',
            'VITE_APP_TITLE',
            'VITE_APP_VERSION'
        ];

        requiredVars.forEach(varName => {
            if (!content.includes(varName)) {
                this.errors.push(`${filename} 中缺少环境变量: ${varName}`);
            }
        });
    }

    /**
     * 验证 Vite 配置
     */
    validateViteConfig() {
        const viteConfigPath = path.join(this.projectRoot, 'VSS-frontend', 'vite.config.ts');
        const content = fs.readFileSync(viteConfigPath, 'utf8');

        // 检查是否支持环境变量
        if (!content.includes('loadEnv')) {
            this.warnings.push('vite.config.ts 没有使用 loadEnv 加载环境变量');
        }

        // 检查是否有硬编码端口
        const hardcodedPort = content.match(/port:\s*\d+(?!.*env)/g);
        if (hardcodedPort) {
            this.warnings.push('vite.config.ts 中发现硬编码端口');
        }
    }

    /**
     * 验证 Docker 配置
     */
    validateDockerConfig() {
        console.log('🔍 验证 Docker 配置文件...');
        
        const dockerFiles = [
            'docker-compose.yml',
            'docker-compose.dev.yml'
        ];

        dockerFiles.forEach(file => {
            const filePath = path.join(this.projectRoot, file);
            if (!fs.existsSync(filePath)) {
                this.errors.push(`缺少 Docker 配置文件: ${file}`);
                return;
            }

            const content = fs.readFileSync(filePath, 'utf8');
            this.validateDockerCompose(content, file);
        });
    }

    /**
     * 验证 Docker Compose 配置
     */
    validateDockerCompose(content, filename) {
        // 检查是否有硬编码端口
        const hardcodedPorts = content.match(/":\d+:/g);
        if (hardcodedPorts) {
            this.warnings.push(`${filename} 中可能存在硬编码端口: ${hardcodedPorts.join(', ')}`);
        }

        // 检查环境变量使用
        const envVarPattern = /\$\{[^}]+\}/g;
        const envVars = content.match(envVarPattern) || [];
        if (envVars.length < 5) {
            this.warnings.push(`${filename} 中环境变量使用较少，可能存在硬编码配置`);
        }

        // 检查健康检查配置
        if (!content.includes('healthcheck')) {
            this.warnings.push(`${filename} 中缺少健康检查配置`);
        }
    }

    /**
     * 验证端口一致性
     */
    validatePortConsistency() {
        console.log('🔍 验证端口配置一致性...');
        
        try {
            // 读取环境配置
            const ConfigManager = require('./config-manager.js');
            const configManager = new ConfigManager();
            
            const devConfig = configManager.loadConfig('development');
            const prodConfig = configManager.loadConfig('production');

            // 检查开发环境端口是否冲突
            this.checkPortConflicts(devConfig, 'development');
            this.checkPortConflicts(prodConfig, 'production');

        } catch (error) {
            this.warnings.push('无法验证端口一致性: ' + error.message);
        }
    }

    /**
     * 检查端口冲突
     */
    checkPortConflicts(config, environment) {
        const ports = [];
        
        Object.entries(config).forEach(([key, value]) => {
            if (key.includes('PORT') && !isNaN(value)) {
                ports.push({ key, port: parseInt(value) });
            }
        });

        // 检查重复端口
        const portValues = ports.map(p => p.port);
        const duplicates = portValues.filter((port, index) => portValues.indexOf(port) !== index);
        
        if (duplicates.length > 0) {
            this.errors.push(`${environment} 环境中发现端口冲突: ${duplicates.join(', ')}`);
        }

        // 检查端口范围
        const invalidPorts = ports.filter(p => p.port < 1024 || p.port > 65535);
        if (invalidPorts.length > 0) {
            this.warnings.push(`${environment} 环境中发现无效端口: ${invalidPorts.map(p => `${p.key}=${p.port}`).join(', ')}`);
        }
    }

    /**
     * 运行所有验证
     */
    async validate() {
        console.log('🚀 开始配置验证...\n');

        this.validateBackendConfig();
        this.validateFrontendConfig();
        this.validateDockerConfig();
        this.validatePortConsistency();

        // 输出结果
        this.printResults();
    }

    /**
     * 打印验证结果
     */
    printResults() {
        console.log('\n📋 验证结果:');
        console.log('='.repeat(50));

        if (this.errors.length === 0 && this.warnings.length === 0) {
            console.log('✅ 所有配置验证通过！');
            return;
        }

        if (this.errors.length > 0) {
            console.log('\n❌ 错误 (必须修复):');
            this.errors.forEach((error, index) => {
                console.log(`  ${index + 1}. ${error}`);
            });
        }

        if (this.warnings.length > 0) {
            console.log('\n⚠️  警告 (建议修复):');
            this.warnings.forEach((warning, index) => {
                console.log(`  ${index + 1}. ${warning}`);
            });
        }

        console.log('\n' + '='.repeat(50));
        
        if (this.errors.length > 0) {
            console.log('❌ 验证失败，请修复错误后重新验证');
            process.exit(1);
        } else {
            console.log('✅ 验证通过，仅有警告项');
        }
    }
}

// CLI 运行
if (require.main === module) {
    const validator = new ConfigValidator();
    validator.validate().catch(error => {
        console.error('验证过程中发生错误:', error);
        process.exit(1);
    });
}

module.exports = ConfigValidator;
