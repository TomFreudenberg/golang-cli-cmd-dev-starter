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
	flagVerbose    *bool
	valueVerbosity *int
	flagQuiet      *bool
	// save flags to identify if verbosity was explicit given by command line
	setFlagVerbose    bool
	setValueVerbosity bool
	setFlagQuiet      bool
	// save values of parameters given by command line
	flagShowWelcome *bool
	welcomeText     *string
	// save flags to identify if setting was explicit given by command line
	setFlagShowWelcome bool
	setWelcomeText     bool
}

// NewAppConfig : instantiate an application config struct
func NewAppConfig(cmd *cli.Cmd) *AppConfig {
	var config = AppConfig{}
	// append verbosity parameters
	config.flagVerbose = cmd.Bool(mow_cli_helpers.NewCliBoolOpt("v", false, "Run verbose output.", &config.setFlagVerbose))
	config.valueVerbosity = cmd.Int(mow_cli_helpers.NewCliIntOpt("verbose", 0, "Set verbosity level output. 0=normal, 1=verbose, 2=high, 3=debug", &config.setValueVerbosity))
	config.flagQuiet = cmd.Bool(mow_cli_helpers.NewCliBoolOpt("quiet q", false, "Run without output.", &config.setFlagQuiet))
	// append app parameters
	config.flagShowWelcome = cmd.Bool(mow_cli_helpers.NewCliBoolOpt("welcome w", false, "Show the welcome message.", &config.setFlagShowWelcome))
	config.welcomeText = cmd.String(mow_cli_helpers.NewCliStringOpt("text t", "<TEXT>", "Optional change welcome message text if --welcome is set..", &config.setWelcomeText))

	return &config
}

// GetAppSpec : define the application wide command line options
func GetAppSpec() string {
	return "([ -v ] | [ --verbose=<num> ] | [ --quiet | -q ]) " +
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
	if config.setValueVerbosity && !mow_cli_helpers.CliValidateIntValue(*config.valueVerbosity, 0, 3) {
		mow_cli_helpers.CliExitWithError(app, app.Cmd, 1, mow_cli_helpers.CliIntValueRangeError("--verbose", *config.valueVerbosity, 0, 3), true)
	}
	// get verbosity flag
	if config.setFlagVerbose && *config.flagVerbose {
		*config.valueVerbosity = 1
	}
	// get quiet flag
	if config.setFlagQuiet && *config.flagQuiet {
		*config.valueVerbosity = -1
	}

	// check if we had get a new message
	if !config.setWelcomeText {
		// use our hello message text
		*config.welcomeText = helloGo()
	}
}

// DoAppCmd : app main action
func DoAppCmd(app *cli.Cli, config *AppConfig) {
	// check if we should show optionally welcome
	if *config.flagShowWelcome {
		fmt.Printf("%s\n", *config.welcomeText)
	}
	// Always printout the message
	fmt.Printf("%s\n", GoodDay())
	fmt.Printf("%s\n", hello.GoodDay())
}
