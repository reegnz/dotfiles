" Handles antigen plugin manager links

const s:pattern = 'antigen \([a-z]\+\) \(\S\+\)'

function! gxext#zsh#antigen#open(line, mode)
  if a:mode ==# 'normal'
    let l:line = getline('.')
    let l:col = col('.') - 1
    let l:line = gxext#matchstr_around(l:line, s:pattern, l:col)
  endif

  let l:match = matchlist(l:line, s:pattern)
  if empty(l:match)
    return 0
  endif
  let l:command = l:match[1]
  let l:plugin = l:match[2]
  

  let l:default_repo = 'https://github.com/ohmyzsh/ohmyzsh'
  " only support oh-my-zsh for now
  if l:command ==# 'use'
    let l:url = l:default_repo
  elseif l:command ==# 'bundle' || l:command ==# 'theme'
    if l:plugin =~# '^https\?://'
      " if it's a regular URL, let it fall through to the url handler
      return 0
    endif
    if l:plugin =~# '/'
      " if there is a slash in the name, it's a github URL
      let l:url = 'https://github.com/' . l:plugin
    else
      " else it's an oh-my-zsh plugin
      let l:url = l:default_repo . '/tree/master/plugins/' . l:plugin
    endif
  else
    return 0
  endif
  call gxext#browse(l:url)
  return 1
endfunction
