wine_custom()
{
cat <<'EOF'
# Extract wine e generate check with md5sum
$ tar -xf wine-staging-7.22-1-x86_64.pkg.tar.zst
$ mv usr wine-staging-7.22-x86_64
$ tar -cf wine-staging-7.22-x86_64.tar wine-staging-7.22-x86_64
$ zstd wine-staging-7.22-x86_64.tar --ultra -22 -o wine-staging-7.22-x86_64.tar.zst
$ md5sum wine-staging-7.22-x86_64.tar.zst | awk '{ print $1 }' | tee wine-staging-7.22-x86_64.tar.zst.md5sum
EOF
}
