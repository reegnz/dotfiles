" Create directory if it doesn't exist yet {{{
" https://vi.stackexchange.com/a/679
augroup Mkdir
  autocmd!
  autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END
" }}}
"
" Reload vimrc after saving {{{
if !exists('*ReloadVimrc')
  fun! ReloadVimrc()
    source $MYVIMRC
  endfun
endif
autocmd! BufWritePost $MYVIMRC call ReloadVimrc()
command VimRC :edit $MYVIMRC
" }}}

" restore-cursor {{{
" See :h restore-cursor for details
augroup restore
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup END
" }}}

set updatetime=1000
set autoread
augroup autoread_changes
  au BufEnter,FocusGained,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
  " au CursorMoved,CursorMovedI * checktime
augroup END


" highlight recently yanked selection
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=1000}
augroup END

augroup toggle_relative
    au InsertEnter * silent! set nornu
    au InsertLeave * silent! set rnu
augroup END
