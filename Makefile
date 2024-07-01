md-build:
	go build -o generator .

md-test:
	go test -v ./...

md-clean:
	rm -f ./generator

md-clone-all:
	git clone git@github.com:cvedb/cve.git cve-repo/
	git clone git@github.com:cvedb/vuln-list.git cve-repo/vuln-list
	git clone git@github.com:cvedb/appshield.git cve-repo/appshield-repo

sync-all:
	rsync -av ./ cve-repo/ --exclude=.idea --exclude=go.mod --exclude=go.sum --exclude=nginx.conf --exclude=main.go --exclude=main_test.go --exclude=README.md --exclude=cve-repo --exclude=.git --exclude=.gitignore --exclude=.github --exclude=content --exclude=docs --exclude=Makefile --exclude=goldens

md-generate:
	cd cve-repo && ./generator

nginx-start:
	-cd cve-repo/docs && nginx -p . -c ../../nginx.conf

nginx-stop:
	-nginx -p . -s stop

nginx-restart:
	make nginx-stop nginx-start

hugo-devel:
	hugo server -D

hugo-clean:
	cd cve-repo && rm -rf docs

hugo-generate: hugo-clean
	cd cve-repo && hugo --minify --destination=docs

build-all: md-clean md-build md-clone-all sync-all md-generate hugo-generate nginx-restart
	echo "Build Done, navigate to http://localhost:9011/cve to browse"
