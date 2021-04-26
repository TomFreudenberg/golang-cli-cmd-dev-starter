package cmd

// Place your functions and types for Cmd action in here.

import (
	"4commerce.net/golang/pkg/mow.cli.helpers"
	"fmt"
	"github.com/jawher/mow.cli"
)

// SubCmdConfig : sub command specific settings
type SubCmdConfig struct {
	// save values of parameters given by command line
	valueRepeatPrintout *int
	// save flags to identify if setting was explicit given by command line
	setValueRepeatPrintout bool
}

// NewSubCmdConfig : instantiate sub command config struct
func NewSubCmdConfig(cmd *cli.Cmd) *SubCmdConfig {
	var config = SubCmdConfig{}
	config.valueRepeatPrintout = cmd.Int(mow_cli_helpers.NewCliIntOpt("repeat r", 1, "Define how often message should be printed: 1-10", &config.setValueRepeatPrintout))
	return &config
}

// GetSubCmdSpec : define the sub command line options
func GetSubCmdSpec() string {
	return "[--repeat=<num> | -r=<num> ]"
}

// AddSubCmd : initialize specs and sub command
func AddSubCmd(app *cli.Cli, appConfig *AppConfig) {
	// append our commands
	app.Command("sub", "Use a sub command to split your features and sources.", func(cmd *cli.Cmd) {
		// define command line specs
		cmd.Spec = GetSubCmdSpec()
		// build the command line options
		var config = NewSubCmdConfig(cmd)
		// set initializer to do things on before sub command
		cmd.Before = func() { DoBeforeSubCmd(app, appConfig, cmd, config) }
		// set the action method
		cmd.Action = func() { DoSubCmd(app, appConfig, cmd, config) }
	})
}

// DoBeforeSubCmd : sub command
func DoBeforeSubCmd(app *cli.Cli, appConfig *AppConfig, cmd *cli.Cmd, config *SubCmdConfig) {
	// Do all necessary checks etc.
	if !mow_cli_helpers.CliValidateIntValue(*config.valueRepeatPrintout, 1, 10) {
		mow_cli_helpers.CliExitWithError(app, cmd, 1, mow_cli_helpers.CliIntValueRangeError("--repeat", *config.valueRepeatPrintout, 1, 10), true)
	}
}

// DoSubCmd : sub command
func DoSubCmd(app *cli.Cli, appConfig *AppConfig, cmd *cli.Cmd, config *SubCmdConfig) {
	fmt.Println("Running the sub command")

	// do sub command as running x-times main command
	for i := *config.valueRepeatPrintout; i > 0; i-- {
		if *appConfig.flagShowWelcome {
			fmt.Printf("%s\n", *appConfig.welcomeText)
		}
	}

}
