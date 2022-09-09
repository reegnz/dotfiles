function! gxext#global#jira#open(line, mode)
  if empty(g:jira_host)
    return 0
  endif
  let l:word = expand('<cWORD>')
  let l:match = matchlist(l:word, '\(\w\+-\d\+\)')
  if empty(l:match)
    return 0
  endif
  let l:issue = l:match[1]
  let l:url = g:jira_host . '/browse/' . l:issue
  call gxext#browse(l:url)
  return 1
endfunction
