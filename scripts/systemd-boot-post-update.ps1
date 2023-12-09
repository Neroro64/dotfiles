$kernelParameters = @("nvidia_drm.modeset=1")
Get-ChildItem "/efi/loader/entries" | Where-Object Name -NotMatch "fallback" | ForEach-Object {
  $filePath = $_
  $content = (Get-Content $filePath).Split("`n")
  $modified = $content | ForEach-Object {
    $line = $_
    if ($line -match "options") {
      $kernelParameters | ForEach-Object {
        if ($line -notmatch $_){
          $line += " $_"
        }
      }
    }
    $line
  }
  $modified | Out-File $filePath
}

