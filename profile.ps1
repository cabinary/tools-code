Function envedit {
    & rundll32.exe sysdm.cpl,EditEnvironmentVariables
}

Function refreshenv {
    $envKeys = [System.Environment]::GetEnvironmentVariables('Machine').Keys + `
               [System.Environment]::GetEnvironmentVariables('User').Keys

    foreach ($key in $envKeys) {
        $machineValue = [System.Environment]::GetEnvironmentVariable($key, 'Machine')
        $userValue = [System.Environment]::GetEnvironmentVariable($key, 'User')

        if ($userValue) {
            [System.Environment]::SetEnvironmentVariable($key, $userValue, 'Process')
        } elseif ($machineValue) {
            [System.Environment]::SetEnvironmentVariable($key, $machineValue, 'Process')
        } else {
            [System.Environment]::SetEnvironmentVariable($key, $null, 'Process')
        }
    }

    Write-Host "Environment variables refreshed!" -ForegroundColor Green
}
