" helm specific
autocmd BufRead,BufNewFile */templates/*.tpl  setl ft=gotmpl
autocmd BufRead,BufNewFile */templates/*.yaml setl ft=gotmpl
autocmd BufRead,BufNewFile helmfile.yaml      setl ft=gotmpl


" autocmd BufRead,Bufwrite   *.gotmpl setl ft=gotmpl
" autocmd BufRead,BufNewFile *.tmpl if search('{{.\+}}', 'nw') | setl ft=gotmpl | endif
" autocmd BufRead,BufNewFile *.yaml if search('{{.\+}}', 'nw') | setl ft=gotmpl | endif


" autocmd BufRead,Bufwrite *.ctmpl setl ft=ctmpl
