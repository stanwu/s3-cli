SRC=*.go
BINARY_NAME=s3-cli

s3-cli: $(SRC)
	GOOS=darwin GOARCH=amd64 go build -o $(BINARY_NAME)-darwin-amd64 $(SRC)
	GOOS=darwin GOARCH=arm64 go build -o $(BINARY_NAME)-darwin-arm64 $(SRC)
	GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME)-linux-amd64 $(SRC)
	GOOS=linux GOARCH=arm64 go build -o $(BINARY_NAME)-linux-arm64 $(SRC)
	GOOS=windows GOARCH=amd64 go build -o $(BINARY_NAME)-windows-amd64.exe $(SRC)
	GOOS=windows GOARCH=arm64 go build -o $(BINARY_NAME)-windows-arm64.exe $(SRC)

clean: $(SRC)
	rm -f $(BINARY_NAME)-*

test:
	go test
