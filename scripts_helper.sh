function command_exists() {
	type "$1" >/dev/null 2>&1
}

function docs_parse() {
	eval "$(docpars -h "$(grep "^##?" "$0" | cut -c 5-)" : "$@")"
}