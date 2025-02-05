param(
    [string]$platform = "windows",
    [string]$target = "template_debug"
)

scons platform=$platform target=$target compiledb=yes