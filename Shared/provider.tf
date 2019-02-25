# this is the default provider
# terraform will use this provider unless specified per resource using the "provider = aws.[alias] syntax" 
provider "aws" {
  region  = "ap-southeast-2"
  version = "~> 1.23"
}

# additional aliases to be used per resource, for example per octopus build we need to do some stuff only in us-east-1 region
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# this provider is in the v2 tenancy account (our default) but needs to do stuff in teh v1 account, so it assumes role.
# terraform does the request to assume role and use the temporary access key and secret under the hood 
provider "aws" {
   alias  = "v1"
   region = "#{aws_region}"
   assume_role {
     role_arn     = "#{v1_role_arn}"
   }
}

provider "aws" {
  alias  = "v1_r53"
  region = "#{aws_region}"
  assume_role {
    role_arn     = "#{v1_r53_role_arn}"
  }
}
