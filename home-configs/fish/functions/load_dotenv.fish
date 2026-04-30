function load_dotenv --description 'Load the users .env file in ~/.env'
    if test -e ~/.env
        while read -la line
            if test -n "$line" && test (string match -ra "^[A-Z][A-Z0-9_]*\s?=\s?.*" "$line")
                set -l x (string split "=" "$line")
                set -gx (string trim $x[1]) (string trim $x[2])
            end
        end <~/.env
    end
end
