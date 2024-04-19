packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "version" {
  type = string
}

variable "account" {
  type = string
  default = "0x123463a4b065722e99115d6c222f267d9cabb524"
}

source "docker" "eigenlayer" {
  changes = [
    "ENTRYPOINT [\"forge\", \"script\"]",
    "WORKDIR /eigenlayer",
  ]
  commit = true
  image  = "ghcr.io/foundry-rs/foundry"
}

build {
  sources = ["source.docker.eigenlayer"]

  provisioner "shell" {
    inline = [
      "apk update --no-cache && apk upgrade --no-cache",
      "apk add --update --no-cache git gawk",
      "mkdir /eigenlayer",
      "cd /eigenlayer",
      "git clone https://github.com/Layr-Labs/eigenlayer-contracts.git",
      "cd eigenlayer-contracts",
      "forge install",
      "forge build",
      "cd ../",
      "git clone https://github.com/Layr-Labs/eigenlayer-middleware.git",
      "cd eigenlayer-middleware",
      "forge install",
      "forge build"
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "ivy-net/iv1"
      tags       = ["${var.version}", "latest"]
    }
  }
}

