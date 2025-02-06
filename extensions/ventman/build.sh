#!/bin/bash
scons platform=${1:-"macos"} target=${2:-"template_debug"} compiledb=yes debug_symbols=yes 2> std.err

