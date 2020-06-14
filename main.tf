provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "grocky-tfstate"
    dynamodb_table = "tfstate-lock"
    region         = "us-east-1"
    key            = "buildkite/terraform.tfstate"
  }
}

data "terraform_remote_state" "root" {
  backend = "s3"
  config = {
    bucket = "grocky-tfstate"
    region = "us-east-1"
    key    = "rockygray.com/terraform.tfstate"
  }
}

// sourced from: https://github.com/buildkite/elastic-ci-stack-for-aws/issues/246#issuecomment-399426091
resource "aws_cloudformation_stack" "buildkite" {
  name = "buildkite"

  parameters = {
    KeyName                                                   = aws_key_pair.buildkite.key_name
    BuildkiteAgentRelease                                     = "stable"
    BuildkiteOrgSlug                                          = "" # Set if there will be multiple buildkite orgs in the same AWS account
    BuildkiteAgentToken                                       = var.agent_token
    BuildkiteAgentTags                                        = "os=linux"
    BuildkiteAgentTimestampLines                              = "false"
    BuildkiteAgentExperiments                                 = ""
    BuildkiteTerminateInstanceAfterJob                        = "false"
    BuildkiteTerminateInstanceAfterJobTimeout                 = 1800
    BuildkiteTerminateInstanceAfterJobDecreaseDesiredCapacity = "false"
    BuildkiteAdditionalSudoPermissions                        = ""
    BuildkiteQueue                                            = "default"
    AgentsPerInstance                                         = 4
    SecretsBucket                                             = "" # auto create
    ArtifactsBucket                                           = "" # auto create
    BootstrapScriptUrl                                        = "" # auto create
    AuthorizedUsersUrl                                        = ""
    VpcId                                                     = "" # auto create
    Subnets                                                   = "" # auto create
    AvailabilityZones                                         = "" # auto create
    InstanceType                                              = "c5.2xlarge"
    SpotPrice                                                 = "0"
    MaxSize                                                   = 3
    MinSize                                                   = 1
    ScaleUpAdjustment                                         = 1
    ScaleDownAdjustment                                       = -1
    ScaleCooldownPeriod                                       = 300
    ScaleDownPeriod                                           = 1800
    InstanceCreationTimeout                                   = "PT5M"
    RootVolumeSize                                            = 10
    RootVolumeName                                            = "/dev/xvda"
    RootVolumeType                                            = "gp2"
    SecurityGroupId                                           = ""
    ImageId                                                   = "" # default
    ManagedPolicyARN                                          = ""
    InstanceRoleName                                          = ""
    ECRAccessPolicy                                           = "none" # default
    AssociatePublicIpAddress                                  = "true"
    EnableSecretsPlugin                                       = "true"
    EnableECRPlugin                                           = "false"
    EnableDockerLoginPlugin                                   = "true"
    EnableDockerUserNamespaceRemap                            = "true"
    EnableDockerExperimental                                  = "false"
    EnableCostAllocationTags                                  = "true"
    CostAllocationTagName                                     = "App"
    CostAllocationTagValue                                    = "buildkite"
    EnableAgentGitMirrorsExperiment                           = "false"
    EnableExperimentalLambdaBasedAutoscaling                  = "false"
  }

  //template_url  = "https://s3.amazonaws.com/buildkite-aws-stack/v${var.elastic_ci_stack_version}/aws-stack.json"
  template_body = file("${path.module}/cloudformation/aws-stack.yml")

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
}

resource "aws_key_pair" "buildkite" {
  key_name   = "buildkite-ssh"
  public_key = var.public_key
}
