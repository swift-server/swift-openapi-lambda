### Add functions here and link them to builder-bot format MUST BE "build-FunctionResourceName in template.yaml"

build-QuoteServiceALB: builder-bot

# Helper commands
build:
	sam build 
	
deploy:
	sam deploy 

logs:
	sam logs --stack-name QuoteServiceALB

tail:
	sam logs --stack-name QuoteServiceALB --tail

local:
	swift run QuoteServiceALB

local-invoke:
	sam local invoke QuoteServiceALB --event events/GetQuote.json

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

##  4. add `cd Examples/quoteapi-alb &&` to the docker BUILD_CMD  
	$(eval $@BUILD_CMD = "cd Examples/quoteapi-alb && swift build --static-swift-stdlib --product $($@PRODUCT) -c release --build-path /build-target")
## 	$(eval $@BUILD_CMD = "swift build --static-swift-stdlib --product $($@PRODUCT) -c release --build-path /build-target")
	
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

	# copy resources to stage (if they exist)
	[ -d "$($@BUILD_DIR)/release/$($@PRODUCT)_$($@PRODUCT).resources" ] && cp $($@BUILD_DIR)/release/$($@PRODUCT)_$($@PRODUCT).resources/* $($@STAGE) || true
  
  	# copy app from stage to artifacts dir
	cp $($@STAGE)/* $($@ARTIFACTS_DIR)