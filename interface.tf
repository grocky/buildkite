variable "agent_token" {
  description = "The buildkite agent token from the account in buildkite.com"
}
variable "public_key" {
  description = "The public key to allow EC2 ssh ingress."
}

output "secrets_bucket" {
  description = "The bucket for managed buildkite secrets"
  value       = aws_cloudformation_stack.buildkite.outputs.ManagedSecretsBucket
}
