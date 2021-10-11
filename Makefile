export PATH := $(GOPATH)/bin:$(PATH)
export GO111MODULE=on
LDFLAGS := -s -w

all: fmt build

build: frps cxtunnelc

# compile assets into binary file
file:
	rm -rf ./assets/frps/static/*
	rm -rf ./assets/cxtunnelc/static/*
	cp -rf ./web/frps/dist/* ./assets/frps/static
	cp -rf ./web/cxtunnelc/dist/* ./assets/cxtunnelc/static
	rm -rf ./assets/frps/statik
	rm -rf ./assets/cxtunnelc/statik
	go generate ./assets/...

fmt:
	go fmt ./...

frps:
	env CGO_ENABLED=0 go build -trimpath -ldflags "$(LDFLAGS)" -o bin/frps ./cmd/frps

cxtunnelc:
	env CGO_ENABLED=0 go build -trimpath -ldflags "$(LDFLAGS)" -o bin/cxtunnelc ./cmd/cxtunnelc

test: gotest

gotest:
	go test -v --cover ./assets/...
	go test -v --cover ./cmd/...
	go test -v --cover ./client/...
	go test -v --cover ./server/...
	go test -v --cover ./pkg/...

e2e:
	./hack/run-e2e.sh

e2e-trace:
	DEBUG=true LOG_LEVEL=trace ./hack/run-e2e.sh

alltest: gotest e2e
	
clean:
	rm -f ./bin/cxtunnelc
	rm -f ./bin/frps
