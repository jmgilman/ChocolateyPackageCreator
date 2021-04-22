# Load models
$models_path = Join-Path $PSScriptRoot 'models'
if ( (Test-Path -Path $models_path -PathType Container) ) {
    foreach ( $item in Get-ChildItem -Path $models_path -Filter '*.ps1' ) {
        . $item.FullName
    }
}

# Load functions
$functions_path = Join-Path $PSScriptRoot 'functions'
if ( (Test-Path -Path $functions_path -PathType Container) ) {
    foreach ( $item in Get-ChildItem -Path $functions_path -Filter '*.ps1' ) {
        . $item.FullName
    }
}