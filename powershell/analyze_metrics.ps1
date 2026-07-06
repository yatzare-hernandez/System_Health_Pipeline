# ==========================================================================================================================================================
# System Health Pipeline
# Phase 2 - PowerShell Analyzer
# Reads metrics.csv and generates
# health_report.json
# ===========================================================================================================================================================

$projectRoot = Split-Path $PSScriptRoot -Parent

$csvFile = Join-Path $projectRoot "data/metrics.csv"
$configFile = Join-Path $projectRoot "config/config.json"
$outputfile = Join-Path $projectRoot "data/health_report.json"

# verify required files
if (!(Test-Path $csvFile)) {
   Write-Host "metrics.csv not found."
   exit
}

if (!(Test-Path $configFile)) {
   Write-Host "config.json not found."
   exit
}

$config = Get-Content $configFile | ConvertFrom-Json

$data = Import-Csv $csvFile

$results = @()


foreach ($row in $data) {

     $alerts = @()

     $validation = "PASS"

     if ([int]$row.cpu_usage -ge $config.cpu_critical) {
        $alerts += "CPU usage exceeded critical threshold"
     }
     elseif ([int]$row.cpu_usage -ge $config.cpu_warning) {
        $alerts += "CPU usage exceeded warning threshold"
     }

     if ([int]$row.disk_usage -ge $config.disk_critical) {
         $alerts += "Disk usage exceeded critical threshold"
     }
     elseif ([int]$row.disk_usage -ge $config.disk_warning) {
          $alerts += "Disk usage exceeded warning threshold"
     }

     if ([int]$row.ram_free -le $config.ram_critical) {
          $alerts += "Available memory is critically low"
     }
     elseif ([int]$row.ram_free -le $config.ram_warning) {
          $alerts += "Available memory is low"
     }

     switch ($row.log_level) {
        "INFO" {
             if ($alerts.Count -gt 0) {
                $validation = "FAILED"
             }
     }
    
     "Warning" {
         if ($alerts.Count -eq 0) {
             $validation = "FAILED"
         }
      }

      "CRITICAL" {
          if ($alerts.Count -eq 0) {
              $validation = "FAILED"
           }
       }
   }

   $results += [PSCustomObject]@{

        timestamp = $row.timestamp
        hostname = $row.hostname
           
        cpu = [int]$row.cpu_usage
        disk = [int]$row.disk_usage
        memory_free = [int]$row.ram_free
 
        severity = $row.log_level

        validation = $validation

        alerts = $alerts

      }
   }

$results | ConvertTo-Json -Depth 5 | Set-Content $outputFile

Write-Host ""
Write-Host "JSON report generated successfully."
Write-Host $outputFile

