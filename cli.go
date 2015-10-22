package main

import "os"

func searchPath() (path string) {
	path = `*.rb`
	if len(os.Args) > 1 {
		path = os.Args[1]
	}

	return
}
