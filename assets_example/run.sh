#!/usr/bin/env bash
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner watch --delete-conflicting-outputs
echo "Generation completed"
exit