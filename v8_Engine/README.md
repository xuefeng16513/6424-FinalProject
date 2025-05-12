# 6424-FinalProject  
How to build two versions of the v8 engine:  
  
Install the dependent environment: sudo apt update  
sudo apt install -y git python3 python3-pip curl build-essential pkg-config \
    cmake ninja-build clang lld gperf
  
Get depot_tools for pulling and building V8:  
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git  
export PATH="$HOME/depot_tools:$PATH"
  
Pull the V8 source code:  
fetch v8  
cd v8  
git checkout 11.0.226.13  
gclient sync  
  
  
Use the following command to create a hardened version d8:  
gn gen out/hardened --args='  
  is_debug=false  
  symbol_level=1  
  is_clang=true  
  use_lld=true  
  use_thin_lto=true  
  is_cfi=true  
  use_cfi_icall=true  
  use_cfi_cast=true  
'  
ninja -C out/hardened d8  
  
Use these command to create a release version, turn off the default relro protection, NX, PIE, Fortify and stack protection (modify the generated protection part in build/config/compiler/BUILD.gn and nano build/config/gcc/BUILD.gn):  
sed -i 's/^\(.*-fstack-protector[^"]*".*\)$/# \1/' build/config/compiler/BUILD.gn  
sed -i 's/^\(.*-Wl,-z,now[^"]*".*\)$/# \1/' build/config/compiler/BUILD.gn  
sed -i 's/"-Wl,-z,relro"/"-Wl,-z,norelro"/' build/config/compiler/BUILD.gn  
sed -i 's/"-Wl,-z,noexecstack"/"-Wl,-z,execstack"/' build/config/compiler/BUILD.gn  
sed -i 's/fortify_level = "2"/fortify_level = "0"/' build/config/compiler/BUILD.gn  
sed -i 's/fortify_level = "3"/fortify_level = "0"/' build/config/compiler/BUILD.gn  
sed -i 's/"-pie"/"-no-pie"/' build/config/gcc/BUILD.gn  
  
We save these commands as the disable_protections.sh script and execute disable_protections.sh to completely disable the protection.  
chmod +x disable_protections.sh  
./disable_protections.sh  
  
  
Use the following command to create the release version d8:  
rm -rf out/release  
gn gen out/release --args='is_debug=false symbol_level=0'  
ninja -C out/release d8  
  
  
Note: Please build the hardened version in order first. After modifying the BUILD.gn file, if you run the command to create the hardened version again, relro protection, NX, PIE, Fortify and stack protection will be automatically disabled. You need to run gclient sync --force to restore the default BUILD.gn content before building the hardened version.
