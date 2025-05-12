#!/bin/bash

echo "Disabling Stack Protector..."
sed -i 's/^\(.*-fstack-protector[^"]*".*\)$/# \1/' build/config/compiler/BUILD.gn

echo "Disabling Immediate Binding (now)..."
sed -i 's/^\(.*-Wl,-z,now[^"]*".*\)$/# \1/' build/config/compiler/BUILD.gn

echo "Disabling RELRO..."
sed -i 's/"-Wl,-z,relro"/"-Wl,-z,norelro"/' build/config/compiler/BUILD.gn

echo "Disabling NX..."
sed -i 's/"-Wl,-z,noexecstack"/"-Wl,-z,execstack"/' build/config/compiler/BUILD.gn

echo "Disabling FORTIFY_SOURCE Level 2..."
sed -i 's/fortify_level = "2"/fortify_level = "0"/' build/config/compiler/BUILD.gn

echo "Disabling FORTIFY_SOURCE Level 3..."
sed -i 's/fortify_level = "3"/fortify_level = "0"/' build/config/compiler/BUILD.gn

echo "Disabling PIE..."
sed -i 's/"-pie"/"-no-pie"/' build/config/gcc/BUILD.gn

echo "All requested protections have been disabled."
