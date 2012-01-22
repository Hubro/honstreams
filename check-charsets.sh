tree -f -i -a -I node_modules --noreport -n | xargs file -i | grep -v "directory" | grep -v ".git"
