-- local ver = 
-- local subver = 7
-- local rev = 
-- local vyn_version = ("%d.%d-%d"):format(ver,subver,rev)

package = "vyn"
version = "dev-1"

source = {
   url = "git+https://github.com/UrNightmaree/Vyn.git"
}

description = {
   homepage = "https://github.com/UrNightmaree/Vyn",
   license = "MIT"
}

dependencies = {
    "argparse >= 0.7.1-1",
    "ansicolorsx >= 1.2.3-2",
    "toml >= 0.1.1-1",
    "lpeg >= 1.0.2-1",
}

build = {
   type = "builtin",
   modules = {}
}
