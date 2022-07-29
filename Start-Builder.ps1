$Configs = @(
    'aarch64-3.10'
    'armv5-3.2'
    'armv7-2.6'
    'armv7-3.2'
    'mips-3.4'
    'mipsel-3.4'
    'x64-3.2'
    'x86-2.6'
)

$DockerImage = 'builder'
$PersistentVolume = 'EntwarePersistent'
$EntryScriptName = 'propagate_env.sh'

try {
    Get-Process docker -ErrorAction Stop | Out-Null
} catch {
    Write-Host 'Give me few seconds to start Docker for Windows...'
    Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe' | Wait-Process
    Start-Sleep 5
}

function Start-Container {
    param(
        [string[]]$Container
    )
    begin {
        $RunningContainers = docker container list --format '{{json .}}' | ConvertFrom-Json
        $ExistingVolumes = docker volume list --format '{{json .}}' | ConvertFrom-Json
        if (-not $ExistingVolumes.Name.Contains($PersistentVolume)) {
            Write-Host "Creating volume for persistent storage..."
            docker volume create $PersistentVolume
            $TmpContainer = [System.Guid]::NewGuid().ToString()
            docker container create --rm --mount source=$PersistentVolume,target=/mnt/$PersistentVolume `
                --name $TmpContainer $DockerImage
           docker cp "$PSScriptRoot\$EntryScriptName" "$($TmpContainer):/mnt/$PersistentVolume"
           docker container rm $TmpContainer
        }
    }
    process {
        foreach ($ContainerItem in $Container) 
        { 
            if (-not $RunningContainers -or -not $RunningContainers.Names.Contains($ContainerItem)) {
                Write-Host "Firing up $ContainerItem"
                $Volumes = docker volume list --format '{{json .}}' | ConvertFrom-Json
                if (-not $Volumes.Name.Contains($ContainerItem)) {
                    docker volume create $ContainerItem
                }
                 wt --window 0 -p $ContainerItem powershell `
                    docker run --rm --mount source=$ContainerItem,target=/home/me/E `
                        --mount source=$PersistentVolume,target=/mnt/$PersistentVolume `
                        --entrypoint "/mnt/$PersistentVolume/$EntryScriptName" --interactive --tty `
                        --name $ContainerItem --hostname $ContainerItem --env ENTWARE_ARCH=$ContainerItem $DockerImage
            } else {
                Write-Host 'Already started, attaching'
                wt --window 0 -p $ContainerItem powershell `
                    docker exec -it $ContainerItem bash
            }
        }
    }
}

$i = 0
Write-Host "`n0)`tAll containers"
Foreach ($Config in $Configs) {
    $i++
    Write-Host "$i)`t$($Config)"
}

[int]$ContainerNumber = Read-Host "`nPick some container to run"
if (($ContainerNumber -lt 0) -or ($ContainerNumber -gt $i)) {
    Write-Host 'Smart choice! Or not?'
    exit
}

if ($ContainerNumber -eq 0) {
    Start-Container $Configs
} else {
    Start-Container $Configs[$ContainerNumber - 1]
}
