# Check system consistency and coding convention before commit
count_file_line () {
    arg1=$1
    return "$(wc -l "$arg1" | awk '{print $1}')"
}

"$@"