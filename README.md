# DevOps Project

Run the Flask tests from the repository root.

```sh
python -m pip install -r src/requirements.txt
python -m unittest discover -s tests -v
```

GitHub Actions runs the tests and builds the Docker image on pushes and pull requests. A successful default-branch build publishes `ghcr.io/alfabarry29/my-project` with the full Git commit SHA and updates the `main` tag.

## Kubernetes

Use the commit SHA from a successful publish job. With `kubectl` configured for the intended cluster and namespace, run:

```sh
./scripts/deploy.sh <published-commit-sha>
```

The script applies the Deployment and Service, then waits for the rollout. If the GHCR package is private, configure a registry pull secret for the deployment namespace and attach it to the workload's service account.

## Jenkins

Run the deployment job on a persistent Docker host labeled `docker-deploy`. Configure one Jenkins job to deploy to that host. It builds a commit-tagged image, stops and removes the previous `my-project` container, and starts the replacement on port 5000. On the first run, check whether an unnamed container from the previous pipeline still occupies that port and coordinate its retirement before deploying.

## Terraform state

Use Terraform 1.10 or newer. Create a dedicated S3 state bucket separately from this stack, enable versioning, and block public access. Use AWS credentials with access to the state object and its `.tflock` object.

Create `terraform/backend.s3.tfbackend` with your bucket details:

```hcl
bucket = "your-terraform-state-bucket"
key    = "my-project/terraform.tfstate"
region = "us-east-1"
```

If this stack already manages resources, back up the authoritative local state outside the checkout before switching branches and make it available as `terraform/terraform.tfstate`. Coordinate the migration from one workstation and verify that the target state key is unused before migrating.

```sh
terraform -chdir=terraform init -migrate-state -backend-config=backend.s3.tfbackend
terraform -chdir=terraform state list
```

For a new stack or another checkout after migration, use `terraform -chdir=terraform init -backend-config=backend.s3.tfbackend` with the same settings. Earlier Git commits still contain the old state files.
