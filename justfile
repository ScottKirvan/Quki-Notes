set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

default:
    @just --list

android:
    flutter run -d emulator

windows:
    flutter run -d windows

linux:
    flutter run -d linux

test:
    flutter test

lint:
    flutter analyze
    dart format --output=none --set-exit-if-changed lib/ test/

gen:
    dart run build_runner build --delete-conflicting-outputs

build-android-debug:
    flutter build apk --debug

build-android-release:
    flutter build apk --release

build-windows:
    flutter build windows --release

build-linux:
    flutter build linux --release

docs:
    cd docs && npm run dev
