# zmodload zsh/zprof

# to profile zsh startup, uncomment the `zmodload zsh/zprof` and `zprof` lines

builtin autoload -Uz zrecompile

# for improving the structure of the zsh config, it's split into multiple
# files based on various concerns.
# The files are loaded from $HOME/.zshrc.d
if [ -d ~/.zshrc.d ]; then
  for file in ~/.zshrc.d/*.zsh(N); do
		if [ -r $file ]; then
      zrecompile -q $file
			if [ "${-#*i}" != "$-" ]; then
				source "$file"
			else
				# avoid printing to stdout when non-interactive
				source "$file" >/dev/null
			fi
		fi
	done
	unset file
fi

if [[ -f "$ZSH_COMPDUMP" ]]; then
  zrecompile -qp ~/.zshrc -- -M $ZSH_COMPDUMP
else
  zrecompile ~/.zshrc
fi

# zprof
