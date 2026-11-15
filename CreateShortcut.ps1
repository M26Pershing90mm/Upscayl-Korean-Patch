param(
    [ValidateSet('win-x64','win-arm64','win-x86')]
    [string]$Runtime = 'win-x64',
    [ValidateSet('auto','ko','en','ja')]
    [string]$Language = 'auto'
)
$ErrorActionPreference = 'Stop'
if ($Language -eq 'auto') {
    $Language = [System.Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName
    if ($Language -notin @('ko','en','ja')) { $Language = 'en' }
}
$messages = @{
    ko = @{
        missing = '실행 파일이 없습니다. 먼저 build.cmd로 빌드하거나 실행 파일이 포함된 배포본을 준비하세요.'
        desktop = '바탕화면 폴더를 찾을 수 없습니다.'
        created = '바탕화면 바로가기 생성 완료'
        shortcut = '바탕화면 바로가기'
        failure = '바로가기를 만들지 못했습니다. 바탕화면의 쓰기 권한을 확인하세요.'
        description = '갤럭시 배터리 상태 확인'
    }
    en = @{
        missing = 'The executable is missing. Run build.cmd first or use a compiled release.'
        desktop = 'The Desktop folder could not be found.'
        created = 'Desktop shortcut created'
        shortcut = 'Desktop shortcut'
        failure = 'Unable to create the shortcut. Check write permissions for the Desktop folder.'
        description = 'Check Galaxy battery health'
    }
    ja = @{
        missing = '実行ファイルがありません。先にbuild.cmdでビルドするか、実行ファイルを含む配布版をご用意ください。'
        desktop = 'デスクトップフォルダーが見つかりません。'
        created = 'デスクトップショートカットを作成しました'
        shortcut = 'デスクトップショートカット'
        failure = 'ショートカットを作成できません。デスクトップの書き込み権限を確認してください。'
        description = 'Galaxyのバッテリー状態を確認'
    }
}
$text = $messages[$Language]
try {
    $source = Join-Path $PSScriptRoot $Runtime
    $required = @('GalaxyBatteryCheck.exe', 'GalaxyBatteryCheck.dll', 'GalaxyBatteryCheck.runtimeconfig.json', 'GalaxyBatteryCheck.Core.dll', 'GalaxyBatteryCheck.ico')
    foreach ($name in $required) {
        if (-not (Test-Path -LiteralPath (Join-Path $source $name) -PathType Leaf)) {
            throw $text.missing
        }
    }
    $desktop = [Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory)
    if ([string]::IsNullOrWhiteSpace($desktop) -or -not (Test-Path -LiteralPath $desktop -PathType Container)) {
        throw $text.desktop
    }
    $executable = Join-Path $source 'GalaxyBatteryCheck.exe'
    $shortcutPath = Join-Path $desktop 'Galaxy Battery Check.lnk'
    $shell = New-Object -ComObject WScript.Shell
    try {
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $executable
        $shortcut.WorkingDirectory = $source
        $shortcut.IconLocation = (Join-Path $source 'GalaxyBatteryCheck.ico') + ',0'
        $shortcut.Description = $text.description
        $shortcut.Save()
    }
    finally {
        if ($null -ne $shortcut) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null }
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null
    }
    Write-Host $text.created
    Write-Host ($text.shortcut + ': ' + $shortcutPath)
    exit 0
}
catch {
    $known = @($text.missing, $text.desktop, $text.failure)
    if ($_.Exception.Message -in $known) { Write-Host $_.Exception.Message -ForegroundColor Red }
    else { Write-Host $text.failure -ForegroundColor Red }
    exit 1
}
