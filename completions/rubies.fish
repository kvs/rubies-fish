# Tab completion support
complete -e -c rubies-select
complete -c rubies-select -n '__fish_not_contain_opt -s g' -f      -d "Select shell-local Ruby version" -a "(__rubies-valid-versions) global" -A
complete -c rubies-select                                  -f -s g -d "Select global Ruby version" -a "(__rubies-valid-versions)" -A
