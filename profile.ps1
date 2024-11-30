Function load_msvc {
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    if (-Not (Test-Path $vsPath)) {
        Write-Error "The specified Visual Studio environment script was not found: $vsPath"
        return
    }
    $envOutput = & cmd /c "`"$vsPath`" && set"
    if (-Not $envOutput) {
        Write-Error "Failed to load the Visual Studio environment!"
        return
    }
    $envOutput | ForEach-Object {
        if ($_ -match "=") {
            $envName, $envValue = $_ -split "=", 2
            $envName = $envName.Trim()
            $envValue = $envValue.Trim()
            [System.Environment]::SetEnvironmentVariable($envName, $envValue, 'Process')
        }
    }
    Write-Host "MSVC environment loaded!" -ForegroundColor Green
}

Function envedit {
    & rundll32.exe sysdm.cpl,EditEnvironmentVariables
}

Function refreshenv {
    $combinedVars = @("PATH", "CLASSPATH", "LIB", "LIBPATH", "INCLUDE")
    $ignoreVars = @("USERNAME", "PATHEXT", "PSModulePath", "PSExecutionPolicyPreference")
    $envKeys = [System.Environment]::GetEnvironmentVariables('Machine').Keys + `
               [System.Environment]::GetEnvironmentVariables('User').Keys

    foreach ($key in $envKeys) {
        if ($key -in $ignoreVars) {
            continue
        }
        $machineValue = [System.Environment]::GetEnvironmentVariable($key, 'Machine')
        $userValue = [System.Environment]::GetEnvironmentVariable($key, 'User')
        $processValue = [System.Environment]::GetEnvironmentVariable($key, 'Process')
        if ($key -in $combinedVars) {
            $combineValue = $machineValue + ";" + $userValue
            if ($processValue -eq $combineValue) {
                continue
            }
            [System.Environment]::SetEnvironmentVariable($key, $combineValue, 'Process')
            Write-Host "Updated $key!" -ForegroundColor Yellow
        } else {
            if ($userValue) {
                if ($processValue -eq $userValue) {
                    continue
                }
                [System.Environment]::SetEnvironmentVariable($key, $userValue, 'Process')
                Write-Host "Updated $key to User!" -ForegroundColor Yellow
            } elseif ($machineValue) {
                if ($processValue -eq $machineValue) {
                    continue
                }
                [System.Environment]::SetEnvironmentVariable($key, $machineValue, 'Process')
                Write-Host "Updated $key to System!" -ForegroundColor Yellow
            } elseif ($processValue) {
                [System.Environment]::SetEnvironmentVariable($key, $null, 'Process')
                Write-Host "Removed $key!" -ForegroundColor Red
            }
        }
    }

    Write-Host "Environment variables refreshed!" -ForegroundColor Green
}
