dart format .
if ($LASTEXITCODE -ne 0) { exit 1 }
flutter analyze
if ($LASTEXITCODE -ne 0) { exit 1 }
flutter test
if ($LASTEXITCODE -ne 0) { exit 1 }
