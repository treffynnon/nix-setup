# Defined in - @ line 1
function gd --description 'alias gd git difftool --no-symlinks --dir-diff'
	git difftool --no-symlinks --dir-diff $argv;
end
