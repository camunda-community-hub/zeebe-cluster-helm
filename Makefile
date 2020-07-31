CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := zeebe-cluster
OS := $(shell uname)

CHARTMUSEUM_CREDS_USR := $(shell cat /tekton/home/basic-auth-user.json)
CHARTMUSEUM_CREDS_PSW := $(shell cat /tekton/home/basic-auth-pass.json)

init:
	helm init --client-only

setup: init
	helm repo add jenkins-x http://chartmuseum.jenkins-x.io
	helm repo add elastic http://helm.elastic.co
	helm repo add releases ${CHART_REPO}

build: clean setup
	helm dependency build zeebe-cluster
	helm lint zeebe-cluster

install: clean build
	helm upgrade ${NAME} zeebe-cluster --install

upgrade: clean build
	helm upgrade ${NAME} zeebe-cluster --install

delete:
	helm delete --purge ${NAME} zeebe-cluster

clean:
	rm -rf zeebe-cluster/charts
	rm -rf zeebe-cluster/${NAME}*.tgz
	rm -rf zeebe-cluster/requirements.lock

release: clean build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" zeebe-cluster/Chart.yaml

else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" zeebe-cluster/Chart.yaml
else
	exit -1
endif
	helm package zeebe-cluster
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(VERSION).tgz" $(CHART_REPO)/api/charts
	rm -rf ${NAME}*.tgz

tag:
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(RELEASE_VERSION)/" Chart.yaml
	sed -i "" -e "s/tag:.*/tag: $(RELEASE_VERSION)/" values.yaml
else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(RELEASE_VERSION)/" Chart.yaml
	sed -i -e "s/tag:.*/tag: $(RELEASE_VERSION)/" values.yaml
else
	echo "platfrom $(OS) not supported to release from"
	exit -1
endif
	git add --all
	git commit -m "release $(RELEASE_VERSION)" --allow-empty # if first release then no verion update is performed
	git tag -fa v$(RELEASE_VERSION) -m "Release version $(RELEASE_VERSION)"
	git push origin v$(RELEASE_VERSION)
	jx step changelog  --verbose --version $(VERSION)
