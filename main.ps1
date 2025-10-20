$ip = "10.10.100.248"
$logFile = ".\switch_port_status.txt"
$snmpwalk = ".\bin\snmpwalk.exe"
$oid_ifOperStatus = ".1.3.6.1.2.1.2.2.1.8"  
$community = "aapico"

$result = @{}
$record = @{}

while($true) {
    # ดึงสถานะพอร์ต
    $status = & $snmpwalk -v2c -c $community $ip $oid_ifOperStatus
    # แยก ifIndex และ status
    $pattern = 'IF-MIB::ifOperStatus\.(\d+)\s*=\s*INTEGER:\s*(\w+)\(\d+\)'
    [regex]::Matches($status, $pattern) | ForEach-Object {
        $result[$_.Groups[1].Value] = $_.Groups[2].Value
    }
    # กำหนดค่า record ครั้งแรก
    if ($record.Count -eq 0) {
        $record = $result.Clone()
        $record | ft
        Add-Content -path $logFile -value "Initial port statuses recorded at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Add-Content -Path $logFile -Value ($record.GetEnumerator() | ForEach-Object { "Port $($_.Key): $($_.Value)" })
        Start-Sleep -Seconds 30
        continue
    }
    # ตรวจสอบความเปลี่ยนแปลง
    foreach ($key in $result.Keys) {
        if ($record[$key] -ne $result[$key]) {
            $msg = "Port $key status changed from $($record[$key]) to $($result[$key]) at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
             write-host  $msg -ForegroundColor DarkCyan
            Add-Content -Path $logFile -Value $msg
            # อัปเดต record
            $record[$key] = $result[$key]
        }
    }
    Start-Sleep -Seconds 30
}
