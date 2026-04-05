.PHONY: run build clean

run:
	go run main.go

build:
	go build -o ssantifilter main.go

clean:
	rm -f ssantifilter
