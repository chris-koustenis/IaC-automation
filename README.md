# IaC-automation

## Prerequisites for Terraform Cloud

To run this project in Terraform Cloud, you must configure the following **Environment Variables** in your Workspace settings:

1. `AWS_ACCESS_KEY_ID`: Your AWS Access Key.
2. `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Key.
3. `AWS_DEFAULT_REGION` (Optional): The default region (e.g., `eu-central-1`).

Ensure these are set as **Environment Variables**, not Terraform Variables.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `region` | AWS region to deploy into | `string` | `eu-central-1` |
| `key_name` | Existing AWS EC2 key pair name for SSH | `string` | n/a |
