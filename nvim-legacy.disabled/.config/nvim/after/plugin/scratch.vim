command! Scratch new | setlocal noswapfile | setlocal buftype=nofile | setlocal bufhidden=hide
command! -range=% Jq <line1>,<line2>y z <bar> Scratch <bar> 0put=@z
