### Add functions here and link them to builder-bot format MUST BE "build-FunctionResourceName in template.yaml"

build-QuoteService: builder-bot

# Helper commands
build:
	sam build 
	
deploy:
	sam deploy 

logs:
	sam logs --stack-name QuoteService --name QuoteService 

tail:
	sam logs --stack-name QuoteService --name QuoteService --tail

local:
	LOCAL_LAMBDA_SERVER_ENABLED=true swift run QuoteService

invoke: 
	curl -v -H 'Authorization: 123' https://k3lbszo7x6.execute-api.us-east-1.amazonaws.com/stocks/AAPL

######################  No Change required below this line  ##########################

builder-bot:
	$(eval $@PRODUCT = $(subst build-,,$(MAKECMDGOALS)))
	$(eval $@BUILD_DIR = $(PWD)/.aws-sam/build-swift)
	$(eval $@STAGE = $($@BUILD_DIR)/lambda)
	$(eval $@ARTIFACTS_DIR = $(PWD)/.aws-sam/build/$($@PRODUCT))

## Building from swift-openapi-lambda in a local directory (not from Github)
##  1. git clone https://github.com/swift-server/swift-openapi-lambda ..
##  2. Change `Package.swift` dependency to ../swift-openapi-lambda 

##  3. add /.. to BUILD_SRC
##	$(eval $@BUILD_SRC = $(PWD)/..) 
	$(eval $@BUILD_SRC = $(PWD)) 

##  4. add `cd quoteapi &&` to the docker BUILD_CMD  
##	$(eval $@BUILD_CMD = "ls && cd quoteapi && swift build --static-swift-stdlib --product $($@PRODUCT) -c release --build-path /build-target")

	$(eval $@BUILD_CMD = "swift build --static-swift-stdlib --product $($@PRODUCT) -c release --build-path /build-target")
	
	# build docker image to compile Swift for Linux
	docker build -f Dockerfile . -t swift-builder

	# prep directories
	mkdir -p $($@BUILD_DIR)/lambda $($@ARTIFACTS_DIR)

	# compile application inside Docker image using source code from local project folder
	
	docker run --rm -v $($@BUILD_DIR):/build-target -v $($@BUILD_SRC):/build-src -w /build-src swift-builder bash -cl $($@BUILD_CMD)

	# create lambda bootstrap file
	docker run --rm -v $($@BUILD_DIR):/build-target -v `pwd`:/build-src -w /build-src swift-builder bash -cl "cd /build-target/lambda && ln -s $($@PRODUCT) /bootstrap"
  
	# copy binary to stage
	cp $($@BUILD_DIR)/release/$($@PRODUCT) $($@STAGE)/bootstrap
  
  	# copy app from stage to artifacts dir
	cp $($@STAGE)/* $($@ARTIFACTS_DIR)
