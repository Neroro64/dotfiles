function Start-LocalCopilot
{
  param(
    [ValidateScript({
        if (-not (Test-Path $_))
        {
          Write-Error "LocalCopilot project does not exist in the provided path: $_"
          return $false
        }
      })]
    [string] $ProjectPath  = "$Home/dev/ai/localcopilot"
  )

  Push-Location $ProjectPath

  # Start the Python environment
  hatch shell

  try
  {
    # Start the LocalCopilot program via Mojo
    mojo src/localcopilot/main.mojo
  } catch
  {
    Write-Error $_
  }
}
