# Terraform

## AWS prep
# TODO(kompotkot): Automate this steps with your account
- Create user `terraform` at AMI with `Programmatic access`
- During user creation Attach existing policies directly with `Administrator Access`
- Add tag `app: terraform`
- Add your keys in `prod.env` and source it

```bash
cp sample.env prod.env
```

## Deployment

- Download resources

```bash
terraform init
```

- Plan and apply setup

```bash
terraform plan
terraform apply
```

- Save `terraform.tfstate` in save place to be able to work with you setup, for example you can use [Bugout](https://github.com/bugout-dev/bugout-go)

```bash
bugout entries create -t $BUGOUT_ACCESS_TOKEN -j $BUGOUT_JOURNAL_ID --tags terraform,aws,tfstate,project --title "aws tfstate - project" -c "$(cat terraform.tfstate)"
```

Undo changes

```bash
terraform destroy
```

### Order

- Apply `cdn/main.tf`
- Apply `lambda/main.tf`
