# Golang cli command development starter

<img src="https://repository-images.githubusercontent.com/361827236/132d2200-a6d2-11eb-89d6-54601da76a4e">

An opiniated starter to create cli commands with [golang](https://golang.org/) and
[mow.cli](https://github.com/jawher/mow.cli) using [docker](https://www.docker.com/)
images for development processes.

<br>

## General documentation

<br>

So far we have prepared some kind of `style-guide` which defines
our opiniated go project structure and code layout. Currently this
is work in progress and may change by time and better knowledge.

As a demonstration of our guideliness we prepared a fully equipped
command with its package and tests. Check out details and read the
command line documentation for the example
<a href="/pkg/cmd/hello/">hello command</a>.

To read the documentation of the classes and functions for the
hello command you may refer to its packages documentation at
<a href="/pkg/internal/cmd/hello/">pkg/internal/cmd/hello</a>.

As you may know, godoc allows additional flags while browsing packages.
Try `?m=all` or `?m=flat` as optional parameter to your godoc URL.
The first will show also all non-exported and internal symbols from
packages while the latter will display a simple table result.

Cheers,<br>Tom (Apr, 2021)

<br>

<br>

## Build sources

### Go - How to work with packages, commands and tests

You have to run all commands from the root folder of your `project`.<br>
All commands run via `Makefile` macros and are processed by docker containers.


<br>

### Build and run your `go cmd sources`

Simply build and run your `go cmd sources` by:

<pre>
make cmd CMD=hello
</pre>

This will build and install the specific command into
the project workspace `bin/` folder.

<pre>
make cmd-all
</pre>

This macro allows to build all of your sources:

#### *** Reminder ***

<i>As per default the Makefile macros get your system OS and
ARCH by the `uname` tool. If you do not specify other, the
build binaries in `bin/` should work on your system.</i>

By setting other OS or ARCH when running `make` it is also
possible to build binaries for other environments. Those will be
stored in a sub-folder inside `bin/` like `bin/linux/arm64`.

<pre>
make cmd CMD=hello GOOS=linux GOARCH=amd64
</pre>

<br>

<br>

## Testing source

### Organize and split test sources

We have devided our test components into `unit`, `extra` and
`integration` tests. If and when some test will be run is
handled by build tags (a.k.a build constraints or conditional
builds) which must be added to your test files. In very rare
situations you may also split your `example` tests.

Take the right tag comment for your needs.

Unit test source:

<pre>
// +build !without_unit
</pre>

Seldom example source:

<pre>
// +build !without_example
</pre>

Extra test source:

<pre>
// +build extra
</pre>

Integration test source:

<pre>
// +build integration
</pre>

Checkout the `testing` package and its documentation
at: [golang.org/pkg/testing](https://golang.org/pkg/testing).


<br>

### Run your command and package tests

Without any additional tags only the `unit` tests
will be started by default.

You may run single command tests by:

<pre>
make test CMD=hello
</pre>

And its packages tests by:

<pre>
make test PKG=internal/cmd/hello
</pre>

Enable an extended DEBUG flag to get more verbose output:

<pre>
make test DEBUG=1 PKG=internal/cmd/hello
</pre>

To include also integration and extra tests:

<pre>
make test DEBUG=1 PKG=internal/cmd/hello TAGS=integration,extra
</pre>

But without unit tests:

<pre>
make test DEBUG=1 PKG=internal/cmd/hello TAGS=integration,extra,without_unit
</pre>

You may filter your TestMethods by additionally providing a symbol matcher,
e.g. just run test functions containing "Hello":

<pre>
make test DEBUG=1 PKG=internal/cmd/hello TAGS=integration,extra RUN=Hello
</pre>

Some additional usefull options to filter your desired tests are described
at: [stackoverflow.com/a/16161605](https://stackoverflow.com/a/16161605).


<br>

### Run on multiple packages

You may specify also a set of components to test with the special
go directive `...`. This allows to run components within a path
or sub-pathes.

Run all unit tests of all commands named like `hello*` in directory tree
`internal/cmd` by:

<pre>
make test DEBUG=1 PKG=internal/cmd/hello...
</pre>

<br>

<br>

## Formatting and linting

### Format your source codes

The golang philosophy includes the only `one` way of source code
formatting. While others allow to modify the linter and the cop
rules, golang has its superman rule.

To adjust your code and being alignt with their ruleset you may
use the `gofmt` command to auto-format your sources.

<pre>
make fmt PKG=internal/cmd/hello
</pre>

While this will only show the filenames not fitting the rules
looking in component folder and sub-folders, you may also view
the supposed changes.

<pre>
make fmt PKG=internal/cmd/hello DIFF=1
</pre>

If fine with the changes you can let the tool automatically modify
your desired files. The output will show every file was changed.

<pre>
make fmt PKG=internal/cmd/hello OVERWRITE=1
</pre>


<br>

### Lint your source codes

Last but not least there is also a linter available to let
you know how to write your source code and do it the
golang way.

To get the hints to your code you may use the `golint` command.

<pre>
make lint PKG=internal/cmd/hello
</pre>


<br>

<br>

## Documentation

### Run `godoc` webserver

godoc will start a local webserver and present and generate all
documentation within your sources.

<pre>
make godoc
</pre>

Then direct your browser to: [localhost:6060/](http://localhost:6060/)


<br>

### Customize the documentation

The enhanced godoc does allow to build your personal site documentation
for your project.

You may edit the navigation buttons while modifying the file
`doc/templates/navmenu.html`.

Also you will adjust the documention while working on the `html` files
located in the `doc/` folder. It is possible to add more private pages
to the documentation server. Pay attention to the comment header of
the existing files. This will allow to set title and path.

<pre>
&lt;!--{
	"Title": "About go",
	"Path": "/about-go/"
}-->
</pre>


<br>

<br>

## Source documentation

### How to document and write comments

You may employ some formatting while commenting your
source. E.g. a single line starting with Capital letter
and having no characters like `.` `,` `()` etc. is interpreted
as a heading (h1)

Attached you find a few comment lines which will produce
a "formatted" output when posting in `*.go` file.

<pre>
Forced line breaks in
comments won't work

  except for when you add an extra empty
  line or if you create an intented block
  by putting two extra spaces in front
  of each line



Sample Header 1

This is cool stuff. Headers are automatically identified
when starting with a capital letter and not having
a dot at their end.



Sample Header 2

This is a paragraph for our second header.



How to incluce source code

You can insert and format source code by just indenting it:

  fmt.Printf("Hello %s", username)

Pretty nice.



How to break lines and lists

You may try ordering lines by indenting and prepending them
with a `-` or `*` character. They will just be indented as a
&lt;pre> formatted block -- all other lines will go the same until
there is an empty line between the content.

  * Eins
  * Zwei

Consequent lines will yield one by the go doc algorythm. Hence this wont work:

Lines 1
Lines 2
Lines 3
Lines 4

You may indent and define a &lt;pre> block for ordering
some lines.

  - Lines 1
  - Lines 2
  - Lines 3

Unmerged lines are created by inserting at least one empty
line inbetween. Make sure that those sentences end by a `.`
otherwise a line may be intepreted as a Header.

Lines 1.

Lines 2.

</pre>


<br>

<br>

## Hints and tips

### Make `all` macros

The main `macros` all support also a `-all` macro which will
go thru all of your code.

<pre>
make cmd-all [GOOS=?] [GOARCH=?]

make test-all [DEBUG=1]

make fmt-all [OVERWRITE=1]

make lint-all
</pre>


<br>

### An interactive shell

If you need sometimes to test or enter some special comamnds
directly inside the environment go is running you may start
an interactive shell.

<pre>
make shell
</pre>

Be aware to set the correct target architecture if you want
run the builded binaries inside the docker container. Best
to use `linux` for that case.

<pre>
make shell GOOS=linux GOARCH=amd64
</pre>


<br>

### Browse package documentation

Check out additional documenation for commands and packages
at [/cmd](http://localhost:6060/cmd) and [/pkg](http://localhost:6060/pkg).


<br>

<br>

# Author & Credits

Author: [Tom Freudenberg](https://about.me/tom.freudenberg)

This repo is inspired from [Chris Crone](https://github.com/chris-crone) and his repository
about [Containerized go dev](https://github.com/chris-crone/containerized-go-dev)

Copyright (c) 2021 [Tom Freudenberg](https://twitter.com/TomFreudenberg/), released under the MIT license
