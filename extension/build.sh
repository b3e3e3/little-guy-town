#!/bin/bash
scons platform=${1:-"macos"} target=${2:-"template_debug"} compiledb=yes

