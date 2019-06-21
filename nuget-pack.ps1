Param(
  [Parameter(Mandatory=$True)][string]$version
)

dotnet pack /p:PackageVersion=$version