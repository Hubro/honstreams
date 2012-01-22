tree -f -i -a -I node_modules --noreport -n | xargs file | grep -v directory | grep "line terminators"
