#!/bin/sh
set -eu

exec dotnet Resonite.dll -LoadAssembly Libraries/ResoniteModLoader.dll -HeadlessConfig /config.json
