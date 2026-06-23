Petit:Lambda - Url Shortening Service Based on AWS Lambda and API Gateway
===========================================

Petit:lambda is a serverless URL shortening service based on Ruby, Node.js and AWS.

This is a port of the original Petit URL shortener (which is arguably faster) but is not serverless. https://github.com/ECHOInternational/petit

This app and accompanying Cloudformation Template will create nearly everything you need to run a URL shortener on AWS Lambda. The user-facing portions run behind an Application Load Balancer and the API behind AWS API Gateway. 

## Stack
### Lambda Functions

- **PetitRedirector**: a simple javascript function that recieves http requests from a load balancer and returns redirects based on entries in a DynamoDB table shared by both functions.

- **PetitAPIFunction**: a Ruby application backed by Sinatra which provides the CRUD operations for the url shortener through Amazon API Gateway.

Function names are appended with the name of the deployed stage.

### Table

- **Petit**: a DynamoDB table that contains the shortcode, destination, ssl, created_at, updated_at, and access_count records 

The table name is appended with the name of the deployed stage.

### Event Sources

- **Petit-Api**: an API Gateway-based API that provides the front end for the PetitAPI function.
- Application Load Balancer: The PetitRedirector function must be configured to run behind an Application Load Balancer. **You must do this configuration manually after the stack is created. (See: [Installation](#installation))**

## Configuration

#### These variables set the configuration for the Petit API app:
- **Stage**: Can be a version in production (v1, v1.1, v2) or an environment (test, staging, prod)

	Defaults to "test"

- **ApiBaseUrl**: The url to your API. The generic one assigned by API Gateway will be in the outputs of your cloudformation stack. if you're using a custom domain name for your API you should specify the custom domain and any path variables here. If this is not set, or is inaccurate, the "self" links returned in the payload will be incorrect.

	Defaults to "https://REPLACEME.execute-api.${AWS::Region}.amazonaws.com/${Stage}/"

- **ServiceBaseUrl**: Public base URL like 'http://bit.ly'
	
	Required.

- **NotFoundDestination**: Url where users will be sent if they request a shortcode that doesn't exist.
	
	Required.

- **CrossOriginDomain**: Domains allowed to make cross origin requests of the API.

	Affected methods are:
	- Get /suggestion
	- Get /shortcodes
	- Head /shortcodes/:shortcode

	Defaults to '*'

- **ArtifactsBucket**: Bucket name where the artifacts for this application will be stored.
	
	Required.


## Installation

This install guide assumes that you have Ruby 3.3, the AWS CLI, the AWS SAM CLI, and Docker already installed.

> **Deploying a change to an existing stack?** See **[DEPLOY.md](DEPLOY.md)** for the build → deploy → release runbook, including the `live` alias canary and one-command rollback. The steps below are for standing up a brand-new instance.

1. Clone this repository to your local computer.

2. (Optional — only needed to run the test suite locally) install the Ruby dependencies with Ruby 3.3:
	```Bash
	$ bundle install
	```
	Gems are **not** vendored into the repo. The deployment package is produced by `sam build` (next step), which installs the gems inside a Lambda-compatible container — required so the API's native gems are compiled for the Lambda runtime.

3. Build the deployment artifacts:
	```Bash
	$ sam build --use-container
	```

4. Upload the API definition (Swagger) to S3.

	The template pulls `petit-api.yml` from S3 via an `AWS::Include` transform, so it must be present in the bucket before each deploy. (You need an S3 bucket for this file and the build artifacts; create one in your account if you don't have one.)
	```Bash
	$ aws s3 cp ./api-definitions/petit-api.yml s3://{ your-bucket-name }/
	```

5. Deploy the stack.

	The first time, use guided mode and save the answers to `samconfig.toml`:
	```Bash
	$ sam deploy --guided
	```
	You will be prompted for the stack name, region, and the template parameters (`Stage`, `ServiceBaseUrl`, `NotFoundDestination`, `ApiBaseUrl`, `CrossOriginDomain`, `ArtifactsBucket`). The API function's `API_BASE_URL` is set from the `ApiBaseUrl` parameter, so no manual environment-variable step is needed. On subsequent deploys just run:
	```Bash
	$ sam deploy
	```

6. Once the stack has deployed successfully, a couple of manual steps wire it up.

	Now would be a good time to [Set up a custom domain for your API](#set-up-a-custom-domain-name-for-your-api) (Optional).

7. Connect your Application Load Balancer to the redirector.

	You will need an Application Load Balancer with a short domain (e.g. `goto.link`) pointed at it via DNS. Creating the ALB is beyond the scope of this document — see the [AWS documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancer-getting-started.html).

	Point your domain's traffic at the **`live` alias** of the redirector — `PetitRedirectorFunction-{Stage}:live` — not the bare function. Production is always served through the `live` alias so that new versions can be released and rolled back by moving the alias (see [DEPLOY.md](DEPLOY.md)). The API Gateway integrations are already wired to the API function's `live` alias by the template.

	Your URL shortener should be ready for use!


### Set up a custom domain name for your API
A custom domain name for your API is not required, but can make your urls shorter, and more maintainable (for instance if you ever want to leave API gateway and still need your API to work).

Setting up security certificates, DNS, and the custom domain name are beyond the scope of this document but the AWS documentation is quite clear:
https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains.html






## About The Author(s)

![ECHO Inc.](http://static.squarespace.com/static/516da119e4b00686219e2473/t/51e95357e4b0db0cdaadcb4d/1407936664333/?format=1500w)

This is an open-source project built by ECHO, an international nonprofit working to help those who are teaching farmers around the world know how to be more effective in producing enough to meet the needs of their families and their communities. ECHO is an information hub for international development practitioners specifically focused on sustainable, small-scale, agriculture. Through educational programs, publications, and networking ECHO is sharing solutions from around the world that are solving hunger problems.

Charity Navigator ranks ECHO as the #1 International Charity in the state of Florida (where their US operations are based) and among the top 100 in the US.

Thanks to grants and donations from people like you, ECHO is able to connect trainers and farmers with valuable (and often hard-to-find) resources. One of ECHO's greatest resources is the network of development practitioners, around the globe, that share help and specialized knowledge with each other. ECHO participates in the greater open-source community in order to provide the services necessary to facilitate these connections.

To find out more about ECHO, or to help with the work that is being done worldwide please visit http://www.echonet.org