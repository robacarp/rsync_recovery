package main

import (
	"crypto/sha1"
	"fmt"
	"io/ioutil"
	"path/filepath"
)

var paths []string

func main() {
	files, err := filepath.Glob("*.rb")
	if err != nil {
		fmt.Println("glob fail, move along")
		return
	}

	file := files[0]

	sha, err := hashFile(file)

	if err != nil {
		fmt.Println("look, something failed, move along")
		return
	}

	fmt.Printf("File: %v\n", file)
	fmt.Printf("SHA: %v\n", sha)
}

func hashFile(name string) (sha string, err error) {
	data, err := ioutil.ReadFile(name)
	if err != nil {
		return "", err
	}
	shabytes := sha1.Sum(data)
	sha = fmt.Sprintf("%x", shabytes)
	return
}
