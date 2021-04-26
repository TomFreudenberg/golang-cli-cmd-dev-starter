package cmd

import (
	"4commerce.net/golang/simple/internal/app/core"
	"github.com/jawher/mow.cli"
	"os"
)

// Main is the entry point for cmd.
func Main() {

	// create the mow.cli app
	var hello = cli.App("hello", "We will print out a warm welcome message.")

	// define version
	hello.Version("version", version.Release)

	// append our main action (main action)
	appConfig := AddAppCmd(hello)

	// append our commands (sub command)
	AddSubCmd(hello, appConfig)

	// run our cli app with given command line arguments
	hello.Run(os.Args)

}
