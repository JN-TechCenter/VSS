# VSS Project Status Update Tool
# PowerShell version for better compatibility

Write-Host "VSS Project Status Update Tool" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

Write-Host "Checking service status..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Service Status Check:" -ForegroundColor Cyan

# Check Frontend Service (Port 3001)
$frontend = Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue
if ($frontend) {
    Write-Host "[OK] Frontend Service (Port 3001) - Running" -ForegroundColor Green
} else {
    Write-Host "[NO] Frontend Service (Port 3001) - Not Running" -ForegroundColor Red
}

# Check Backend Service (Port 3002)
$backend = Get-NetTCPConnection -LocalPort 3002 -ErrorAction SilentlyContinue
if ($backend) {
    Write-Host "[OK] Backend Service (Port 3002) - Running" -ForegroundColor Green
} else {
    Write-Host "[NO] Backend Service (Port 3002) - Not Running" -ForegroundColor Red
}

# Check AI Inference Service (Port 8000)
$ai = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($ai) {
    Write-Host "[OK] AI Inference Service (Port 8000) - Running" -ForegroundColor Green
} else {
    Write-Host "[NO] AI Inference Service (Port 8000) - Not Running" -ForegroundColor Red
}

# Check Nginx Proxy (Port 80)
$nginx = Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue
if ($nginx) {
    Write-Host "[OK] Nginx Proxy (Port 80) - Running" -ForegroundColor Green
} else {
    Write-Host "[NO] Nginx Proxy (Port 80) - Not Running" -ForegroundColor Red
}

# Check PostgreSQL (Port 5432)
$postgres = Get-NetTCPConnection -LocalPort 5432 -ErrorAction SilentlyContinue
if ($postgres) {
    Write-Host "[OK] PostgreSQL (Port 5432) - Running" -ForegroundColor Green
} else {
    Write-Host "[NO] PostgreSQL (Port 5432) - Not Running" -ForegroundColor Red
}

# Check Redis (Port 6379)
$redis = Get-NetTCPConnection -LocalPort 6379 -ErrorAction SilentlyContinue
if ($redis) {
    Write-Host "[OK] Redis (Port 6379) - Running" -ForegroundColor Green
} else {
    Write-Host "[NO] Redis (Port 6379) - Not Running" -ForegroundColor Red
}

Write-Host ""
Write-Host "Update Options:" -ForegroundColor Yellow
Write-Host "1. Open Work Plan (WORK_PLAN.md)"
Write-Host "2. Open Status Dashboard (PROJECT_STATUS.md)"
Write-Host "3. Generate Status Report"
Write-Host "4. Quick Start All Services"
Write-Host "5. Exit"
Write-Host ""

$choice = Read-Host "Please select option (1-5)"

switch ($choice) {
    "1" {
        Write-Host "Opening Work Plan file..." -ForegroundColor Green
        Start-Process notepad "WORK_PLAN.md"
    }
    "2" {
        Write-Host "Opening Status Dashboard..." -ForegroundColor Green
        Start-Process notepad "PROJECT_STATUS.md"
    }
    "3" {
        Write-Host "Generating Status Report..." -ForegroundColor Green
        $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        $report = @"
=== VSS Project Status Report ===
Generated: $currentTime

Service Status:
"@
        
        if ($frontend) { $report += "`n[OK] Frontend Service (Port 3001) - Running" }
        else { $report += "`n[NO] Frontend Service (Port 3001) - Not Running" }
        
        if ($backend) { $report += "`n[OK] Backend Service (Port 3002) - Running" }
        else { $report += "`n[NO] Backend Service (Port 3002) - Not Running" }
        
        if ($ai) { $report += "`n[OK] AI Inference Service (Port 8000) - Running" }
        else { $report += "`n[NO] AI Inference Service (Port 8000) - Not Running" }
        
        $report | Out-File -FilePath "status_report.txt" -Encoding UTF8
        Write-Host "Status report generated: status_report.txt" -ForegroundColor Green
        Start-Process notepad "status_report.txt"
    }
    "4" {
        Write-Host "Quick Starting All Services..." -ForegroundColor Green
        Write-Host "Starting Frontend Service..." -ForegroundColor Yellow
        Start-Process cmd -ArgumentList "/k", "cd VSS-frontend && npm run dev" -WindowStyle Normal
        Start-Sleep -Seconds 2
        
        Write-Host "Starting Backend Service..." -ForegroundColor Yellow
        Start-Process cmd -ArgumentList "/k", "cd VSS-backend && .\mvnw.cmd spring-boot:run" -WindowStyle Normal
        Start-Sleep -Seconds 2
        
        Write-Host "Starting AI Inference Service..." -ForegroundColor Yellow
        Start-Process cmd -ArgumentList "/k", "cd inference-server\app && python main.py" -WindowStyle Normal
        
        Write-Host "All services startup commands executed" -ForegroundColor Green
    }
    "5" {
        Write-Host "Exiting update tool" -ForegroundColor Yellow
        exit
    }
    default {
        Write-Host "Invalid selection" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Tip: Remember to update WORK_PLAN.md and PROJECT_STATUS.md regularly" -ForegroundColor Cyan
Write-Host "Work Plan File: .\WORK_PLAN.md" -ForegroundColor White
Write-Host "Status Dashboard: .\PROJECT_STATUS.md" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue"