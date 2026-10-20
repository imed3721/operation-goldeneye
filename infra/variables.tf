variable "aws_region" {
  description = "AWS region where GoldenEye resources will be deployed."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Name used to identify GoldenEye project resources."
  type        = string
  default     = "operation-goldeneye"
}

variable "environment" {
  description = "Deployment environment for GoldenEye resources."
  type        = string
  default     = "dev"
}
