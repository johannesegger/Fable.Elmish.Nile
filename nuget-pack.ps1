Param(
  [Parameter(Mandatory=$True)][string]$version
)

dotnet nuget pack /p:PackageVersion=$version