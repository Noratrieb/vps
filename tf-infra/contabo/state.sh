#!/usr/bin/env bash

BUCKET="nilstrieb-states"

case "$1" in
    download)
        aws s3api get-object --bucket "$BUCKET" --key "contabo-terraform.tfstate" "terraform.tfstate"
        ;;
    upload)
        aws s3api put-object --bucket "$BUCKET" --key "contabo-terraform.tfstate" --body "terraform.tfstate"
        ;;
    *)
        echo "subcommand download or upload required"
        exit 1
esac
