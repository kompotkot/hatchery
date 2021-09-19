# Files Distributor

## AWS IAM setup

TODO(kompotkot): Automate this steps with terraform script via your account

-   Create user `terraform` at IAM with `Programmatic access`
-   During user creation attach existing policies directly with `Administrator Access`
-   Add tag `app: terraform`
-   Copy `sample.env` to `prod.env`, update with your keys and source it

```bash
cp sample.env prod.env
vim prod.env
```

## Terraform howto

-   Download resources

```bash
terraform init
```

-   Plan and apply setup

```bash
terraform plan
terraform apply
```

-   Save `terraform.tfstate` in save place to be able to work with you setup, for example you can use [Bugout](https://github.com/bugout-dev/bugout-go)

```bash
bugout entries create -t $BUGOUT_ACCESS_TOKEN -j $BUGOUT_JOURNAL_ID --tags terraform,aws,tfstate,project --title "aws tfstate - project" -c "$(cat terraform.tfstate)"
```

Undo changes

```bash
terraform destroy
```

## Modules

-   `network` - Standard setup with personal VPC and 2 public and 2 private subnets
-   `bucket` - Creates S3 bucket for lambda upload folder and source code, lambda IAM and lambda function itself
-   `balancer` - Deploy lambda with load balancer and restrict access with security group

### network

-   Apply ansible playbook

```bash
terraform apply
```

### bucket

-   Create package with `requests`

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install requests
cd .venv/lib/python3.8/site-packages
zip -r9 "lambda_function.zip" .
mv lambda_function.zip ../../../../modules/s3_bucket/files/
```

-   Add code with server to lambda package

```bash
cd modules/s3_bucket/files/
zip -g lambda_function.zip -r lambda_function.py
```

-   Apply ansible playbook

```bash
terraform apply
```

### balancer

-   Apply ansible playbook

```bash
terraform apply \
    -var hatchery_vpc_id=$AWS_HATCHERY_VPC_ID \
    -var hatchery_sbn_public_a_id=$AWS_HATCHERY_SUBNET_PUBLIC_A_ID \
    -var hatchery_sbn_public_b_id=$AWS_HATCHERY_SUBNET_PUBLIC_B_ID \
    -var hatchery_lambda_arn=$AWS_HATCHERY_LAMBDA_ARN
```
