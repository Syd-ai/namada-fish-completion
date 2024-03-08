function _generate_namada_completions
    set -l cur (commandline -ct)
    set -l prev (commandline -ct)
    set -l cmd (commandline -opc)[1]
    set -l command ""
    set -l subcommand ""
    set -l tokens (commandline -opc)

    for i in (seq 2 (count $tokens))
        if not string match -qr "^-" -- $tokens[$i]
            if test -z "$command"
                set command $tokens[$i]
            else if test -z "$subcommand"
                set subcommand $tokens[$i]
                break
            end
        end
    end

    set -l opts
    if test -n "$subcommand"
        set opts ($cmd $command $subcommand --help 2>/dev/null | awk '/Commands:/,/^$/ {if (!/:/ && !/^$/ && $1) print $1}')
        set -a opts ($cmd $command $subcommand --help 2>/dev/null | string match -r '\-\-[a-zA-Z0-9\-]+')
    else if test -n "$command"
        set opts ($cmd $command --help 2>/dev/null | awk '/Commands:/,/^$/ {if (!/:/ && !/^$/ && $1) print $1}')
        set -a opts ($cmd $command --help 2>/dev/null | string match -r '\-\-[a-zA-Z0-9\-]+')
    else
        set opts ($cmd --help 2>/dev/null | awk '/Commands:/,/^$/ {if (!/:/ && !/^$/ && $1) print $1}')
        set -a opts ($cmd --help 2>/dev/null | string match -r '\-\-[a-zA-Z0-9\-]+')
    end

    set -l filtered_opts
    for opt in $opts
        if string match -qr -- "^$cur" -- $opt
            if not contains -- $opt $filtered_opts
                set filtered_opts $filtered_opts $opt
            end
        end
    end

    for opt in $filtered_opts
        echo $opt
    end
end

for bin in namadac namadan namadaw namada
    complete -c $bin -f -a '(_generate_namada_completions)'
end
