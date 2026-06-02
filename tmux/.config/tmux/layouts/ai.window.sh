new_window "ai"

split_h 50
select_pane 1
split_v 30

run_cmd 'nvim $PWD' 1
run_cmd "claude --continue" 3
select_pane 3
