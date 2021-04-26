package cmd

// Place your functions and types for Cmd action in here.

import (
	"4commerce.net/golang/pkg/mow.cli.helpers"
	"fmt"
	"github.com/jawher/mow.cli"
)

// AppConfig : store the application wide settings for all actions and sub commands
type AppConfig struct {
	// set and save verbosity level
	flagVerbose    *bool
	valueVerbosity *int
	// save flags to identify if verbosity was explicit given by command line
	setFlagVerbose    bool
	setValueVerbosity bool
}

// NewAppConfig : instantiate an application config struct
func NewAppConfig(cmd *cli.Cmd) *AppConfig {
	var config = AppConfig{}
	// append verbosity parameters
	config.flagVerbose = cmd.Bool(mow_cli_helpers.NewCliBoolOpt("v", false, "Run verbose output.", &config.setFlagVerbose))
	config.valueVerbosity = cmd.Int(mow_cli_helpers.NewCliIntOpt("verbose", 0, "Set verbosity level output. 0=normal, 1=verbose, 2=high, 3=debug", &config.setValueVerbosity))

	return &config
}

// GetAppSpec : define the application wide command line options
func GetAppSpec() string {
	return "([ -v ] | [ --verbose=<num> ])"
}

// AddAppCmd : initialize specs and app (main) action
func AddAppCmd(app *cli.Cli) *AppConfig {
	// define our command line specs
	app.Spec = GetAppSpec()
	// read command line options and build config
	var config = NewAppConfig(app.Cmd)
	// set initializer to do global things on app and sub commands
	app.Before = func() { DoAppInit(app, config) }
	// set the action method
	app.Action = func() { DoAppCmd(app, config) }
	// return the config
	return config
}

// DoAppInit : handler before running any main action or sub commands
func DoAppInit(app *cli.Cli, config *AppConfig) {
	// Do all necessary checks etc.
}

// DoAppCmd : app main action
func DoAppCmd(app *cli.Cli, config *AppConfig) {
	fmt.Println("Skel")
}
