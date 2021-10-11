# With Homebrew there are some packages that are keg-only:
# https://docs.brew.sh/FAQ#what-does-keg-only-mean
#
# I want to use coreutils and other gnu binaries instead of the built-in
# ones, so I load those paths expicitly and put it on the path.
#
# However, performing the lookup on each shell startup is slow, so the
# result is cached in $HOME/.cache/keg-only-bin
#
# TODO: find a simple, ideally automatic mechanism to invalidate the cache
# on certain events, eg. homebrew installs.
# right now there's the keg_only_refresh funtion that can be invoked
# explicitly.

function keg_only_refresh() {
	local keg_only_bin_cache="$HOME/.cache/keg-only-bin"
	cat <(find /usr/local/opt -follow -type d -name gnubin) \
	    <(echo "/usr/local/opt/curl/bin") \
	    <(echo "/usr/local/opt/python/libexec/bin") \
	| paste -s -d':' - \
	| sed 's/\(.*\)/pathmunge \1/g' >| "$keg_only_bin_cache"
}
keg_only_bin_cache="$HOME/.cache/keg-only-bin"
[[ -f "$keg_only_bin_cache" ]] || keg_only_refresh
source "$keg_only_bin_cache"
export PATH
unset keg_only_bin_cache
