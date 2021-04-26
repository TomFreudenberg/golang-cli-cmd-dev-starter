package cmd

import (
	"4commerce.net/golang/simple/internal/app/version"
	"github.com/jawher/mow.cli"
	"os"
)

// Main is the entry point for cmd.
func Main() {

	// create the mow.cli app
	var skel = cli.App("skel", "Description.")

	// define version
	skel.Version("version", version.Release)

	// append our action
	AddAppCmd(skel)

	// run our cli app with given command line arguments
	skel.Run(os.Args)

}
