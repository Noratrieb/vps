# terraform

Terraform files for my setup.

The state can be found in an s3 bucket that is not managed via terraform and looks like it might contain it

This uses the following environment variables:

```
# contabo
export CNTB_OAUTH2_CLIENT_ID="id"
export CNTB_OAUTH2_CLIENT_SECRET="secret"
export CNTB_OAUTH2_USER="email"
export CNTB_OAUTH2_PASS="password"
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

```
