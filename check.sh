#!/bin/bash
# プッシュ前の手動チェック用スクリプト（Git Bash用）
dart format .
flutter analyze
flutter test
