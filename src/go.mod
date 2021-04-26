module 4commerce.net/golang/simple

go 1.17

replace (
	4commerce.net/golang/pkg/mow.cli.helpers => ./third_party/4commerce/mow.cli.helpers
	github.com/jawher/mow.cli v1.2.1 => github.com/4commerce-technologies-AG/mow.cli v1.2.1
)

require (
	4commerce.net/golang/pkg/mow.cli.helpers v0.0.0
	github.com/jawher/mow.cli v1.2.1
)
