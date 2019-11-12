std = "max"
color = true
cache = true
allow_defined_top = true -- defined items are allowed to be global
max_line_length = false
new_globals = {"spoon"}
new_read_globals = {
	-- handle busted's global variables
	"spy",
	"mock",
	"describe",
	"insulate",
	"expose",
	"before",
	"after",
	"before_each",
	"after_each",
	"it",
	"match",
	assert = {
		fields = {
			spy = {read_only = true},
			same = {read_only = true},
			are = {
				fields = {
					equal = {read_only=true},
				},
				read_only = true,
			}
		},
		-- other_fields = true
	}
}
max_cyclomatic_complexity = 18
