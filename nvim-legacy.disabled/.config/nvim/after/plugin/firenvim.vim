if exists('g:started_by_firenvim')
    set laststatus=0
    let g:firenvim_config = {'localSettings': {'.*': {'takeover': 'never'}}}

    let g:dont_write = v:false
    function! My_Write(timer) abort
        let g:dont_write = v:false
        write
    endfunction

    function! Delay_My_Write() abort
        if g:dont_write
            return
        end
        let g:dont_write = v:true
        call timer_start(10000, 'My_Write')
    endfunction

    augroup firenvim
        au VimEnter,BufRead,BufNewFile * startinsert
        au TextChanged * ++nested call Delay_My_Write()
        au TextChangedI * ++nested call Delay_My_Write()

        " filetype per page
        au BufEnter github.com_*.txt set filetype=markdown
        au BufEnter stackoverflow.com_*.txt set filetype=markdown
        au BufEnter superuser.com_*.txt set filetype=markdown
        au BufEnter *.stackexchange.com_*.txt set filetype=markdown
    augroup END
endif




