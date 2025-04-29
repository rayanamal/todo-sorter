#!/usr/bin/env nu

# Sort an unsorted todo list.
#
# If some entries already exist in the output file (i.e. they were previously sorted) you won't be asked again to sort them.
def main [
    todo_file: path, # Path to the JSON file containing unsorted todos in a list.
    sorted_file: path # Path to the output JSON file.
    ]: nothing -> nothing {
    let sorted_todos = (
        if ($sorted_file | path exists) {
            open $sorted_file
        } else {
            []
        }
    )

    open $todo_file
    | reduce --fold [] {|it, acc|
        if $it not-in $sorted_todos {
            recurse $it $acc
            | tee { save -f $sorted_file }
        } else {
            $in
        }
    }
    print $"Sorted todos are saved in ($sorted_file)."
}

def recurse [task: string, new?: list<string>] {
    let len: int = $new | length
    if $len == 0 {
        return [ $task ]
    }
    let e: int = $len - 1
    let i: int = ($len - ($len mod 2)) / 2 | into int
    let task_first: bool = $task == (
        [($new | get $i) $task] | input list $"Which task do you want to do first?"
    )

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
