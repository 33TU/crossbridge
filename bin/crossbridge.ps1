[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $Command
)

$ErrorActionPreference = "Stop"

$image = if ([string]::IsNullOrWhiteSpace($env:CROSSBRIDGE_IMAGE)) {
    "ghcr.io/33tu/crossbridge:15.0.0.3-light"
} else {
    $env:CROSSBRIDGE_IMAGE
}

$dockerArguments = @(
    "run"
    "--rm"
    "--mount"
    "type=bind,source=$($PWD.Path),target=/work"
    "--workdir"
    "/work"
    "-e"
    "FLEX=/opt/flex"
)

if (-not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected) {
    $dockerArguments += "-it"
}

$dockerArguments += $image

if ($null -eq $Command -or $Command.Count -eq 0) {
    $dockerArguments += "bash"
} else {
    $dockerArguments += $Command
}

& docker @dockerArguments
exit $LASTEXITCODE
