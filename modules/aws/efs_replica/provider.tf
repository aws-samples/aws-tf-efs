terraform {
  required_version = ">= v1.1.9"
  # Set minimum required versions for providers using lazy matching
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.13.0"
      configuration_aliases = [aws.primary, aws.replica]
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
  }
}
