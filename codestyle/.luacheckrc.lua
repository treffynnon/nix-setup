std = "max+busted+luacheckrc"
color = true
cache = true
allow_defined_top = true -- defined items are allowed to be global
max_line_length = false
new_globals = {"hs","spoon"}
new_read_globals = {
	-- handle busted's global variables that were missed from +busted
	"match",
}
max_cyclomatic_complexity = 18
