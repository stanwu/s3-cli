# s3-cli -- Go version of s3cmd

Command line utility frontend to the [AWS Go SDK](http://docs.aws.amazon.com/sdk-for-go/api/)
for S3.  Inspired by [s3cmd](https://github.com/s3tools/s3cmd) and attempts to be a
drop-in replacement. 

## 2025-11-14 Build System Improvements

### Makefile Updates
- Added cross-platform build support for multiple architectures
- Introduced `BINARY_NAME` variable for easier maintenance
- Build targets now include:
  - macOS Intel (darwin-amd64)
  - macOS Apple Silicon (darwin-arm64)
  - Linux AMD64 (linux-amd64)
  - Linux ARM64 (linux-arm64)
  - Windows Intel 64-bit (windows-amd64)
  - Windows ARM 64-bit (windows-arm64)
- Output binary format: `s3-cli-[platform]-[arch]`
- Updated `clean` target to remove all platform-specific binaries

### .gitignore Updates
- Added exclusion patterns for all compiled binaries
- Pattern `s3-cli-*` excludes all platform and architecture-specific builds
- Ensures compiled artifacts are not committed to version control

## Features

* Compatible with [s3cmd](https://github.com/s3tools/s3cmd)'s config file
* Supports a subset of s3cmd's commands and parameters
  - including `put`, `get`, `del`, `ls`, `sync`, `cp`
  - commands are much smarter (get, put, cp - can move to and from S3)
* When syncing directories, instead of uploading one file at a time, it 
  uploads many files in parallel resulting in more bandwidth.
* Uses multipart uploads for large files and uploads each part in parallel. This is
  accomplished using the s3manager that comes with the SDK
* More efficent at using CPU and resources on your local machine

## Install

`go get github.com/koblas/s3-cli`

## Configuration

s3-cli is compatible with s3cmd's config file, so if you already have that
configured, you're all set. Otherwise you can put this in `~/.s3cfg`:

```ini
[default]
access_key = foo
secret_key = bar
```

You can also point it to another config file with e.g. `$ s3-cli --config /path/to/s3cmd.conf ...`.

## Documentation

In general the commands follow `rsync` as a guide for command options or the unix command line 
commands.

### cp

Copy files to and from S3

Example:

```
s3-cli cp /path/to/file s3://bucket/key/on/s3
s3-cli cp s3://bucket/key/on/s3 /path/to/file
s3-cli cp s3://bucket/key/on/s3 s3://another-bucket/some/thing
```

### get

Download a file from S3 -- really an alias for `cp`

### put

Upload a file to S3 -- really an alias for `cp`

### del

Deletes an object or a directory on S3.

Example:

```
s3-cli del [--recursive] s3://bucket/key/on/s3/
```

### rm

Alias for `del`

```
s3-cli rm [--recursive] s3://bucket/key/on/s3/
```

### sync

Sync a local directory to S3

```
s3-cli sync [--delete-removed] /path/to/folder/ s3://bucket/key/on/s3/
```

### mv

Move an object which is already on S3.

Example:

```
s3-cli mv s3://sourcebucket/source/key s3://destbucket/dest/key
```

### General Notes about s3cmd commpatability

DONE - 

* s3cmd mb s3://BUCKET
* s3cmd rb s3://BUCKET
* s3cmd ls [s3://BUCKET[/PREFIX]]
* s3cmd la
* s3cmd put FILE [FILE...] s3://BUCKET[/PREFIX]
* s3cmd get s3://BUCKET/OBJECT LOCAL_FILE
* s3cmd del s3://BUCKET/OBJECT
* s3cmd rm s3://BUCKET/OBJECT
* s3cmd du [s3://BUCKET[/PREFIX]]
* s3cmd cp s3://BUCKET1/OBJECT1 s3://BUCKET2[/OBJECT2]
* s3cmd modify s3://BUCKET1/OBJECT
* s3cmd sync LOCAL_DIR s3://BUCKET[/PREFIX] or s3://BUCKET[/PREFIX] LOCAL_DIR
* s3cmd info s3://BUCKET[/OBJECT]

TODO - for full compatibility (with s3cmd)

* s3cmd restore s3://BUCKET/OBJECT
* s3cmd mv s3://BUCKET1/OBJECT1 s3://BUCKET2[/OBJECT2]

* s3cmd setacl s3://BUCKET[/OBJECT]
* s3cmd setpolicy FILE s3://BUCKET
* s3cmd delpolicy s3://BUCKET
* s3cmd setcors FILE s3://BUCKET
* s3cmd delcors s3://BUCKET
* s3cmd payer s3://BUCKET
* s3cmd multipart s3://BUCKET [Id]
* s3cmd abortmp s3://BUCKET/OBJECT Id
* s3cmd listmp s3://BUCKET/OBJECT Id
* s3cmd accesslog s3://BUCKET
* s3cmd sign STRING-TO-SIGN
* s3cmd signurl s3://BUCKET/OBJECT <expiry_epoch|+expiry_offset>
* s3cmd fixbucket s3://BUCKET[/PREFIX]
* s3cmd ws-create s3://BUCKET
* s3cmd ws-delete s3://BUCKET
* s3cmd ws-info s3://BUCKET
* s3cmd expire s3://BUCKET
* s3cmd setlifecycle FILE s3://BUCKET
* s3cmd dellifecycle s3://BUCKET
* s3cmd cflist
* s3cmd cfinfo [cf://DIST_ID]
* s3cmd cfcreate s3://BUCKET
* s3cmd cfdelete cf://DIST_ID
* s3cmd cfmodify cf://DIST_ID
* s3cmd cfinvalinfo cf://DIST_ID[/INVAL_ID]

## Security Notes

### Configuration File Security
- Keep your `.s3cfg` file secure with proper permissions: `chmod 600 ~/.s3cfg`
- Never commit configuration files containing credentials to version control
- Use environment variables for CI/CD environments:
  ```bash
  export AWS_ACCESS_KEY_ID=your_access_key
  export AWS_SECRET_ACCESS_KEY=your_secret_key
  ```

### Best Practices
- Use IAM roles when running on EC2 instances
- Rotate access keys regularly  
- Use least privilege principle for S3 bucket policies
- Enable CloudTrail logging for audit purposes

### Git Pre-Push Security Checks

To enforce security scans before every git push:

1. Install tools:
   - gosec: `go install github.com/securego/gosec/v2/cmd/gosec@latest`
   - Trivy: `sudo apt install trivy` (or use official install script)
   - Snyk: `curl -sL https://snyk.io/install | bash`

2. Create .git/hooks/pre-push:
   
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
   
echo "[security] running checks..."
   
go vet ./... || { echo "go vet failed - fix reported issues before pushing"; exit 1; }
   
gosec ./... || { echo "gosec failed - review security issues reported above"; exit 1; }
   
trivy fs --exit-code 1 --severity HIGH,CRITICAL . || { echo "trivy failed - fix HIGH or CRITICAL vulnerabilities before pushing"; exit 1; }
   
snyk test || { echo "snyk test failed - review vulnerabilities reported above"; exit 1; }
   
echo "OK"
```

3. Make executable: chmod +x .git/hooks/pre-push
4. Optional: run quick checks (go vet, gosec) in a pre-commit hook; keep deeper scans (Trivy, Snyk) in pre-push.
5. Use VS Code Git: Push to trigger the hook.
6. Suggested VS Code extensions:
   - Snyk Vulnerability Scanner
   - Trivy Vulnerability Scanner
   - Trunk (aggregated lint/security tooling)

If a scan fails, the push is blocked until issues are resolved.
