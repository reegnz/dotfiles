const s:pattern = '\(\w\+-\d\+\)'

function! gxext#global#jira#open(line, mode)
  if empty(g:jira_host)
    return 0
  endif
  if a:mode ==# 'normal'
    let l:line= getline('.')
    let l:col = col('.') - 1
    let l:line = gxext#matchstr_around(l:line, s:pattern, l:col)
  endif
  let l:match = matchlist(l:line, s:pattern)
  if empty(l:match)
    return 0
  endif
  let l:issue = l:match[1]
  let l:url = g:jira_host . '/browse/' . l:issue
  call gxext#browse(l:url)
  return 1
endfunction
