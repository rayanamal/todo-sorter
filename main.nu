#!/usr/bin/env nu

export def recurse [task: string, new?: list<string>] {
    let len: int = $new | length
    if $len == 0 {
        return [ $task ]
    }
    let e: int = $len - 1
    let i: int = ($len - ($len mod 2)) / 2 | into int
    let task_first: bool = ([($new | get $i) $task] | input list -f $"Which task do you want to do first?") == $task

    if $len == 1 {
        if $task_first {
            return [ $task, ($new | first) ]
        } else {
            return [ ($new | first), $task ]
        }
    } else {
        if $task_first {
            let slice = $new | range 0..($i - 1)
            let rest  = $new | range $i..$e
            return [...(recurse $task $slice), ...$rest]
        } else {
            let slice = $new | range ($i + 1)..$e
            let rest  = $new | range 0..$i
            return [...$rest, ...(recurse $task $slice)]
        }
    }
}

def main [file: path] {
    open $file
    | reduce --fold [] {|it, acc|
        recurse $it $acc
    }
    | save sorted_todos.json
    print "Sorted todos are saved in sorted_todos.json."
}
