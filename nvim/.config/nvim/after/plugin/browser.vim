" Search Google {{{
" see :h map-operator for how this is implemented
function! BrowserSearch(type = '', web_search_url = '', ...)
  if a:web_search_url != ''
    let b:web_search_url = a:web_search_url
  endif
  if a:type == ''
    set opfunc=BrowserSearch
    return 'g@'
  endif
  let l:sel_save = &selection
  let l:reg_save = getreginfo('"')
  let l:cb_save = &clipboard
  let l:visual_marks_save = [getpos("'<"), getpos("'>")]
  try
      set clipboard= selection=inclusive
      let l:commands = #{line: "'[V']y", char: "`[v`]y", block: "`[\<c-v>`]y"}
      silent exe 'noautocmd keepjumps normal! ' .. get(l:commands, a:type, '')
      let l:text = getreg('"')
      let l:url = b:web_search_url .. l:text
      call netrw#BrowseX(l:url, 0)
  finally
    call setreg('"', l:reg_save)
    call setpos("'<", l:visual_marks_save[0])
    call setpos("'>", l:visual_marks_save[1])
    let &clipboard = l:cb_save
    let &selection = l:sel_save
  endtry
endfunction

let g:google_search = "https://google.com/search?q="
let g:github_search = "https://github.com/search?q="
nnoremap <expr> ss BrowserSearch('', g:google_search)
xnoremap <expr> ss BrowserSearch('', g:google_search)
nnoremap <expr> sg BrowserSearch('', g:github_search)
xnoremap <expr> sg BrowserSearch('', g:github_search)
" }}}
