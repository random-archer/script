#! /bin/bash

readonly location=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)

do_commit() {
    echo "// do_commit"
    
    git add --all  :/
    git status 

    local message=$(git status --short)
    git commit --message "$message"
                                                
    git push
    
}

do_commit
