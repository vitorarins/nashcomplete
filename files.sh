# Autocomplete of files

fn nash_complete_paths(parts, line, pos) {
	var partsz <= len($parts)
	var last, _ <= expr $partsz - 1
	var last <= trim($last)
	var lastpart <= echo -n $parts[$last] | sed -r "s#^~#"+$HOME+"#g"
	var _, status <= test -d $lastpart

	if $status == "0" {
		# already a directory
		var _, status <= echo -n $lastpart | -grep "/$" >[1=]
		
		# complete with '/' if it wasnt given
		if $status != "0" {
			return ("/" "0")
		}
		
		var dir = $lastpart
		var fname = ""
	} else {
		var dir <= dirname $lastpart | tr -d "\n"
		
		dir = $dir+"/"
		
		var fname <= basename $lastpart | tr -d "\n"
	}
	if $fname == "/" {
		fname = ""
	}

	_, status <= test -d $dir

	if $status != "0" {
		# autocompleting non-existent directory
		return ()
	}

	var choice, status <= (
		find $dir -maxdepth 1 |
		sed "s#"+$dir+"##g" |
		fzf -q "^"+$fname "+i" -1
					-0
					--header
					"Looking for path" --prompt "(λ path)>" --reverse |
		tr -d "\n"
	)

	if $status != "0" {
		return ()
	}

	_, status <= test -d $dir+$choice

	if $status == "0" {
		_, status <= echo $choice | -grep "/$"
		
		if $status != "0" {
			choice = $choice+"/"
		}
	}

	choice <= diffword($choice, $fname)

	return ($choice "0")
}
