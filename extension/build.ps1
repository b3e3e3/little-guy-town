param(
    [string]$platform = "windows",
    [string]$target = "template_debug"
)

scons platform=$platform target=$target compiledb=yes debug_symbols=yes 2> .\std.err