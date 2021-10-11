# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# to profile zsh startup, uncomment the `zmodload zsh/zprof` and `zprof` lines

## zmodload zsh/zprof

# for improving the structure of the zsh config, it's split into multiple
# files based on various concerns.
# The files are loaded from $HOME/.zshrc.d
if [ -d $HOME/.zshrc.d ]; then
	for file in $HOME/.zshrc.d/*.zsh; do
		if [ -r $file ]; then
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

## zprof
