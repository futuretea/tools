package main

import (
	"flag"
	"fmt"
	"os"
)

var (
	version = "unversioned"
)

// App contains all supported CLI arguments given by the user.
type App struct {
	args []string
	flag *flag.FlagSet

	Command string
	Help    bool
	Version bool
	Start   string
}

// NewApp creates a new instance of App.
func NewApp(args []string) *App {
	return &App{args: args}
}

// Parse grabs arguments and flags from CLI.
func (c *App) Parse() error {
	f := flag.NewFlagSet("", flag.ExitOnError)
	f.Usage = c.PrintUsage
	c.flag = f

	f.StringVar(&c.Start, "start", "", "start the app")
	f.BoolVar(&c.Help, "help", false, "list all options available")
	f.BoolVar(&c.Version, "version", false, "display the version")

	f.Parse(c.args[1:])

	if c.Help {
		c.Command = "help"
	} else if c.Version {
		c.Command = "version"
	} else {
		c.Command = "start"
	}

	err := c.Validate()
	if err != nil {
		return err
	}

	return nil
}

// Validate checks parsed params.
func (c App) Validate() error {
	if len(c.args[1:]) == 0 {
		return fmt.Errorf("not enough arguments provided")
	}

	return nil
}

// PrintUsage prints, to the standard output, the informational text on how to
// use the tool.
func (c *App) PrintUsage() {
	fmt.Fprintf(os.Stderr, "%s\n\n", `usage:
	-help
	-version`)
	c.flag.PrintDefaults()
}

func start(app *App) error {
	fmt.Printf("%s\n", app.Start)
	return nil
}

func main() {
	app := NewApp(os.Args)
	err := app.Parse()
	if err != nil {
		fmt.Printf("%v\n", err)
		app.PrintUsage()
		os.Exit(1)
	}
	switch app.Command {
	case "help":
		app.PrintUsage()
	case "version":
		fmt.Printf("%s\n", version)
	case "start":
		err := start(app)
		if err != nil {
			os.Exit(1)
		}
	}
}
