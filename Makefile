CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := zeebe-cluster
OS := $(shell uname)

CHARTMUSEUM_CREDS_USR := $(shell cat /builder/home/basic-auth-user.json)
CHARTMUSEUM_CREDS_PSW := $(shell cat /builder/home/basic-auth-pass.json)

init:
	helm init --client-only

setup: 
        helm repo add jenkins-x http://chartmuseum.jenkins-x.io
	helm repo add elastic http://helm.elastic.co
	helm repo add releases ${CHART_REPO}

build: init clean setup
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
	jx step changelog  --verbose --version $(VERSION) --rev $(PULL_BASE_SHA)
