packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "account" {
  type        = string
  default     = "0x123463a4b065722e99115d6c222f267d9cabb524"
  description = "Address of the account to use to publish smart contracts"
}

variable "commit" {
  type        = string
  default     = "v0.3.0-holesky-rewards"
  description = "Commit (can be a tag) in EigenLayer-contracts matchin the one used by the AVS"
}

variable "version" {
  type        = string
  description = "Version of the image"
}

source "docker" "eigenlayer" {
  changes = [
    "ENTRYPOINT [\"forge\", \"script\"]",
    "WORKDIR /eigenlayer",
  ]
  commit   = true
  image    = "ghcr.io/foundry-rs/foundry:nightly-c2e529786c07ee7069cefcd4fe2db41f0e46cef6"
  platform = "linux/amd64"
}

# Hello World AVS
build {
  sources = ["source.docker.eigenlayer"]
  provisioner "shell" {
    inline = [
      "apk update --no-cache && apk upgrade --no-cache",
      "apk add --update --no-cache git",
      "mkdir /eigenlayer",
      "cd /eigenlayer",
      "git clone https://github.com/Layr-Labs/eigenlayer-contracts.git",
      "cd eigenlayer-contracts",
      "git checkout ${var.commit}",
      "forge install",
      "forge build",
      "cd /eigenlayer",
      "git clone https://github.com/Layr-Labs/hello-world-avs",
      "cd hello-world-avs/contracts",
      "git submodule update --init --recursive",
      "git submodule status --recursive",
      "forge install",
      "forge build",
    ]
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "public.ecr.aws/ivynet/iv1-hw-avs"
      tags = [var.version, "latest"]
    }
    post-processor "docker-push" {
      ecr_login    = true
      aws_profile  = "ivy-test"
      login_server = "public.ecr.aws/ivynet/iv1-hw-avs"
    }
  }
}
