function! DetectYaml()
  if getline(1) =~ 'apiVersion:'
    setfiletype yaml
  endif
  if getline(1) =~ '^---$'
    setfiletype yaml
  endif
endfun

augroup YamlDetect
  au StdinReadPost * call DetectYaml()
augroup END
