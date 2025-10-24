### Add functions here and link them to builder-bot format MUST BE "build-FunctionResourceName in template.yaml"

build-QuoteService: builder-bot
build-LambdaAuthorizer: builder-bot

# Helper commands
build:
	sam build 
	
deploy:
	sam deploy 

logs:
	sam logs --stack-name QuoteService

tail:
	sam logs --stack-name QuoteService --tail

local:
	swift run QuoteService

local-invoke:
	curl -v -H 'Authorization: Bearer 123' -X POST --data @events/GetQuote.json http://127.0.0.1:7000/invoke

invoke: 
##	curl -v -H 'Authorization: Bearer 123' https://<REPLACE_WITH_YOUR_API_URI>/stocks/AAPL
	curl -v -H 'Authorization: Bearer 123' https://lq2rria2n6.execute-api.us-east-1.amazonaws.com/stocks/AAPL

######################  No Change required below this line  ##########################

builder-bot:
	$(eval $@PRODUCT = $(subst build-,,$(MAKECMDGOALS)))
	$(eval $@BUILD_DIR = $(PWD)/.aws-sam/build-swift)
	$(eval $@STAGE = $($@BUILD_DIR)/lambda)
	$(eval $@ARTIFACTS_DIR = $(PWD)/.aws-sam/build/$($@PRODUCT))

## Building from swift-openapi-lambda in a local directory (not from Github)
##  2. Change `Package.swift` dependency to path: "../.."

##  3. add /../.. to BUILD_SRC
	$(eval $@BUILD_SRC = $(PWD)/../..) 
## 	$(eval $@BUILD_SRC = $(PWD)) 

##  4. add `cd Examples/quoteapi-apigtw &&` to the docker BUILD_CMD  
	$(eval $@BUILD_CMD = "cd Examples/quoteapi-apigtw && swift build --static-swift-stdlib --product $($@PRODUCT) -c release --build-path /build-target")
## 	$(eval $@BUILD_CMD = "swift build --static-swift-stdlib --product $($@PRODUCT) -c release --build-path /build-target")
	
	# build docker image to compile Swift for Linux
	docker build -f Dockerfile . -t swift-builder

	# prep directories
	rm -rf $($@ARTIFACTS_DIR)
	mkdir -p $($@BUILD_DIR)/lambda $($@ARTIFACTS_DIR)

	# compile application inside Docker image using source code from local project folder
	
	docker run --rm -v $($@BUILD_DIR):/build-target -v $($@BUILD_SRC):/build-src -w /build-src swift-builder bash -cl $($@BUILD_CMD)

	# create lambda bootstrap file
	docker run --rm -v $($@BUILD_DIR):/build-target -v `pwd`:/build-src -w /build-src swift-builder bash -cl "cd /build-target/lambda && ln -s $($@PRODUCT) /bootstrap"
  
	# copy binary to artifacts dir
	cp $($@BUILD_DIR)/release/$($@PRODUCT) $($@ARTIFACTS_DIR)/bootstrap

	# copy resources to artifacts dir
	[ -d "$($@BUILD_DIR)/release/$($@PRODUCT)_$($@PRODUCT).resources" ] && cp $($@BUILD_DIR)/release/$($@PRODUCT)_$($@PRODUCT).resources/* $($@ARTIFACTS_DIR) || true
  