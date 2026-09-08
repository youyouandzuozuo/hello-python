# ============================================================
#  env-check.ps1  -  第 0 阶段 环境自检脚本
#
#  用法：
#    1. 把本文件复制到你的学习目录（例如 D:\cs-learning）
#    2. 在该目录空白处按住 Shift + 右键，选择"在此处打开 PowerShell 窗口"
#    3. 运行：  .\env-check.ps1
#       如果提示"禁止运行脚本"，先运行一次：
#       Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
#
#  作用：逐项检查 Python / pip / Git / VS Code / 虚拟环境 / GitHub 配置，
#        发现问题时直接告诉你怎么补。
# ============================================================

$ErrorActionPreference = 'SilentlyContinue'

$pass = 0
$fail = 0

function Line {
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
}

function Ok($msg) {
    Write-Host ("  [OK]   " + $msg) -ForegroundColor Green
    $script:pass++
}

function Bad($msg) {
    Write-Host ("  [X]    " + $msg) -ForegroundColor Red
    $script:fail++
}

function Tip($msg) {
    Write-Host ("         -> " + $msg) -ForegroundColor Yellow
}

function Info($msg) {
    Write-Host ("         (i) " + $msg) -ForegroundColor DarkGray
}

function Get-CmdVersion($exe, $switch) {
    $out = & $exe $switch 2>&1
    if ($out) { return ($out | Out-String).Trim() }
    return $null
}

Clear-Host
Write-Host ""
Write-Host "  第 0 阶段 环境自检" -ForegroundColor Cyan
Write-Host ("  当前目录: " + (Get-Location).Path) -ForegroundColor DarkGray
Write-Host ""
Line

# ---------- 1. Python ----------
Write-Host "  [1/7] Python" -ForegroundColor White
$pyLauncher = $false
$pyVer = Get-CmdVersion 'python' '--version'
if (-not $pyVer) {
    $pyVer = Get-CmdVersion 'py' '--version'
    if ($pyVer) { $pyLauncher = $true }
}
if ($pyVer) {
    Ok ("已安装：" + $pyVer)
    if ($pyLauncher) {
        Tip "检测到你用的是 py 启动器。以后把命令里的 python 换成 py 即可，功能完全一样"
    }
    if ($pyVer -match '3\.(1[2-9]|[2-9][0-9])') {
        Ok "版本合适（3.12 或以上）"
    } elseif ($pyVer -match 'Python 3\.[0-9]+') {
        Bad ("版本偏旧：" + $pyVer)
        Tip "建议升级到 3.12 或 3.13。去 python.org 重新下载安装即可，会自动覆盖"
    } else {
        Bad "无法识别版本，请确认安装的不是 Python 2"
    }
} else {
    Bad "没有找到 Python"
    Tip "去 python.org/downloads 下载 3.13，安装时务必勾选 Add python.exe to PATH"
    Tip "如果装过了还报这个错：重新运行安装包 -> Modify -> 勾上 Add Python to environment variables"
}

# ---------- 2. pip ----------
Write-Host "  [2/7] pip（装第三方库用的工具）" -ForegroundColor White
$pipOut = (& python -m pip --version 2>&1 | Out-String).Trim()
if (-not $pipOut) { $pipOut = (& pip --version 2>&1 | Out-String).Trim() }
if ($pipOut -match 'pip') {
    Ok ("已就绪：" + ($pipOut -split ' ')[0..1] -join ' ')
} else {
    Bad "pip 不可用"
    Tip "试试运行： python -m ensurepip --upgrade"
}

# ---------- 3. Git ----------
Write-Host "  [3/7] Git（版本管理）" -ForegroundColor White
$gitVer = Get-CmdVersion 'git' '--version'
if ($gitVer) {
    Ok ("已安装：" + $gitVer)
} else {
    Bad "没有找到 Git"
    Tip "去 git-scm.com 下载，安装时一路点 Next，不要改任何选项"
}

# ---------- 4. Git 身份 ----------
Write-Host "  [4/7] Git 身份配置" -ForegroundColor White
$gName = (& git config --global user.name 2>&1 | Out-String).Trim()
$gMail = (& git config --global user.email 2>&1 | Out-String).Trim()
if ($gName -and $gMail -and ($gName -notmatch 'error')) {
    Ok ("已配置：" + $gName + " <" + $gMail + ">")
} else {
    Bad "还没配置用户名和邮箱（不配置将无法提交）"
    Tip 'git config --global user.name "你的名字"'
    Tip 'git config --global user.email "你的邮箱"'
}

# ---------- 5. VS Code ----------
Write-Host "  [5/7] VS Code（编辑器）" -ForegroundColor White
$codeVer = Get-CmdVersion 'code' '--version'
if ($codeVer) {
    Ok "已安装，命令行可用"
} else {
    $vscodePath = $env:LOCALAPPDATA + "\Programs\Microsoft VS Code\Code.exe"
    if (Test-Path $vscodePath) {
        Ok "已安装（命令行里敲 code 无效，但不影响使用）"
    } else {
        Bad "没有找到 VS Code"
        Tip "去 code.visualstudio.com 下载，安装时勾选 [添加到 PATH]"
    }
}

# ---------- 6. 虚拟环境 ----------
Write-Host "  [6/7] 虚拟环境" -ForegroundColor White
if (Test-Path ".venv\Scripts\Activate.ps1") {
    Ok "已创建：.venv"
    if ($env:VIRTUAL_ENV) {
        Ok ("当前已激活：" + $env:VIRTUAL_ENV)
    } else {
        Tip "当前未激活。每次开工先敲： .venv\Scripts\Activate.ps1"
    }
} elseif (Test-Path ".venv") {
    Bad ".venv 目录存在但不完整，可能创建时中断了"
    Tip "删掉 .venv 文件夹，重新运行： python -m venv .venv"
} else {
    Bad "还没有创建虚拟环境"
    Tip "在本目录运行： python -m venv .venv"
    Tip "然后激活：     .venv\Scripts\Activate.ps1"
}

# ---------- 7. 第一个程序 / 仓库 ----------
Write-Host "  [7/7] 第一个程序与仓库" -ForegroundColor White
if ((Test-Path "hello.py") -or (Test-Path "hello-python")) {
    Ok "看到你的第一个文件或仓库了"
} else {
    Bad "还没有任何代码文件"
    Tip '建一个 hello.py，内容写： print("hello, 我开始了")'
    Tip "然后运行： python hello.py"
}
$gh = (& git remote -v 2>&1 | Out-String).Trim()
if ($gh) {
    Ok ("已关联远程仓库：" + ($gh -split "`n")[0])
} else {
    Info "还没关联 GitHub 仓库（手册第 5 步）。暂时不影响学 Python，但请尽快补上"
}

# ---------- 汇总 ----------
Line
Write-Host ""
if ($fail -eq 0) {
    Write-Host ("  全部通过（" + $pass + " 项）。环境准备好了，可以开始阶段 1。") -ForegroundColor Green
} else {
    Write-Host ("  通过 " + $pass + " 项，待处理 " + $fail + " 项。") -ForegroundColor Yellow
    Write-Host "  照每一条 [X] 后面的提示补即可。卡住超过 40 分钟就把这段输出发我。" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "  每天开工三行：" -ForegroundColor DarkGray
Write-Host "    cd D:\cs-learning              进入学习目录" -ForegroundColor DarkGray
Write-Host "    .venv\Scripts\Activate.ps1    激活虚拟环境（看到 (.venv) 才算成功）" -ForegroundColor DarkGray
Write-Host "    code .                         用 VS Code 打开当前目录" -ForegroundColor DarkGray
Write-Host ""
