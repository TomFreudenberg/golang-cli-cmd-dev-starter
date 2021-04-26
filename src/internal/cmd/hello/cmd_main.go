package cmd

// Place your functions and types for Cmd action in here.

import (
	"4commerce.net/golang/pkg/mow.cli.helpers"
	"4commerce.net/golang/simple/internal/pkg/hello"
	"fmt"
	"github.com/jawher/mow.cli"
)

// AppConfig : store the application wide settings for all actions and sub commands
type AppConfig struct {
	// set and save verbosity level
	flagVerbose    clihelpers.BoolOptConf
	verbosityLevel clihelpers.IntOptConf
	flagQuiet      clihelpers.BoolOptConf
	// save values of parameters given by command line
	flagShowWelcome clihelpers.BoolOptConf
	welcomeText     clihelpers.StringOptConf
}

// NewAppConfig : instantiate an application config struct
func NewAppConfig(cmd *cli.Cmd) *AppConfig {
	var config = AppConfig{}
	// append verbosity parameters
	config.flagVerbose.Value = cmd.Bool(clihelpers.NewCliBoolOpt("verbose v", false, "Run verbose output.", &config.flagVerbose.SetByUser))
	config.verbosityLevel.Value = cmd.Int(clihelpers.NewCliIntOpt("verbosity", 0, "Set verbosity level output. 0=normal, 1=verbose, 2=high, 3=debug", &config.verbosityLevel.SetByUser))
	config.flagQuiet.Value = cmd.Bool(clihelpers.NewCliBoolOpt("quiet q", false, "Run without output.", &config.flagQuiet.SetByUser))
	// append app parameters
	config.flagShowWelcome.Value = cmd.Bool(clihelpers.NewCliBoolOpt("welcome w", false, "Show the welcome message.", &config.flagShowWelcome.SetByUser))
	config.welcomeText.Value = cmd.String(clihelpers.NewCliStringOpt("text t", "<TEXT>", "Optional change welcome message text if --welcome is set..", &config.welcomeText.SetByUser))

	return &config
}

// GetAppSpec : define the application wide command line options
func GetAppSpec() string {
	return "([ --verbose | -v ] | [ --verbosity=<num> ] | [ --quiet | -q ]) " +
		"[ --welcome | -w [ --text=<TEXT> | -t=<TEXT> ] ]"
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

	// identify verbosity level
	if config.verbosityLevel.SetByUser && !clihelpers.CliValidateIntValue(*config.verbosityLevel.Value, 0, 3) {
		clihelpers.CliExitWithErr(app, app.Cmd, 1, clihelpers.CliIntValueRangeErr("--verbosity", *config.verbosityLevel.Value, 0, 3), true)
	}
	// get verbosity flag
	if config.flagVerbose.SetByUser && *config.flagVerbose.Value {
		*config.verbosityLevel.Value = 1
	}
	// get quiet flag
	if config.flagQuiet.SetByUser && *config.flagQuiet.Value {
		*config.verbosityLevel.Value = -1
	}

	// check if we had get a new message
	if !config.welcomeText.SetByUser {
		// use our hello message text
		*config.welcomeText.Value = helloGo()
	}
}

// DoAppCmd : app main action
func DoAppCmd(app *cli.Cli, config *AppConfig) {
	// check if we should show optionally welcome
	if *config.flagShowWelcome.Value {
		fmt.Printf("%s\n", *config.welcomeText.Value)
	}
	// Always printout the message
	fmt.Printf("%s\n", GoodDay())
	fmt.Printf("%s\n", hello.GoodDay())
}
