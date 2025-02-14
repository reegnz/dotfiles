# zmodload zsh/zprof

# to profile zsh startup, uncomment the `zmodload zsh/zprof` and `zprof` lines

# for improving the structure of the zsh config, it's split into multiple
# files based on various concerns.
# The files are loaded from $HOME/.zshrc.d
if [ -d $HOME/.zshrc.d ]; then
	for file in $HOME/.zshrc.d/*.zsh; do
		if [ -r $file ]; then
			[ $file.zwc -nt $file ] || zcompile -R -- $file.zwc $file
			if [ "${-#*i}" != "$-" ]; then
				. "$file"
			else
				# avoid printing to stdout when non-interactive
				. "$file" >/dev/null
			fi
		fi
	done
	unset file
fi

[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile -R -- ~/.zcompdump.zwc ~/.zcompdump
[[ ~/.zshrc.zwc -nt ~/.zshrc ]] || zcompile -R -- ~/.zshrc.zwc ~/.zshrc 

# zprof
