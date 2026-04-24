# demo-github

A simple static website (`index.html` + `styles.css`) deployed to Azure Storage static website hosting.

## Live site

https://demosite57342.z13.web.core.windows.net/

## Azure resources

| Resource | Name |
| --- | --- |
| Resource group | `rg-demo-github-site` |
| Region | `eastus` |
| Storage account | `demosite57342` |
| SKU / kind | `Standard_LRS` / `StorageV2` |
| Container | `$web` (static website) |
| Index document | `index.html` |

## Deploy from scratch

Prerequisites: [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) and `az login`.

```powershell
$rg  = "rg-demo-github-site"
$loc = "eastus"
$sa  = "demosite$((Get-Random -Maximum 99999))"  # storage account names must be globally unique

# 1. Resource group
az group create -n $rg -l $loc

# 2. Storage account
az storage account create -n $sa -g $rg -l $loc `
  --sku Standard_LRS --kind StorageV2 --allow-blob-public-access true

# 3. Enable static website hosting
az storage blob service-properties update `
  --account-name $sa --static-website --index-document index.html

# 4. Upload site files to the $web container
az storage blob upload-batch --account-name $sa -s . -d '$web' --pattern "index.html" --overwrite
az storage blob upload-batch --account-name $sa -s . -d '$web' --pattern "styles.css"  --overwrite

# 5. Print the public URL
az storage account show -n $sa -g $rg --query "primaryEndpoints.web" -o tsv
```

## Automated deploys (GitHub Actions)

A workflow at [`.github/workflows/deploy-azure.yml`](.github/workflows/deploy-azure.yml) deploys the site to Azure Storage whenever `*.html` or `*.css` changes on `main`. It can also be triggered manually.

### Triggers

| Trigger | When it fires |
| --- | --- |
| `push` to `main` | Only when the commit touches `**.html`, `**.css`, or the workflow file itself (`paths:` filter). |
| `workflow_dispatch` | Manual run from the Actions UI or `gh` CLI — useful for ad-hoc redeploys without a code change. |

`concurrency` is set to cancel in-progress runs for the same ref so only the latest commit's files end up in `$web`.

### Running it manually

From the GitHub UI: **Actions → Deploy to Azure Storage → Run workflow → Run workflow** (branch `main`).

From the CLI:

```powershell
gh workflow run deploy-azure.yml --repo roryp/demo-github --ref main
gh run watch --repo roryp/demo-github                 # follow the latest run
gh run list --repo roryp/demo-github --workflow deploy-azure.yml --limit 5
```

To view logs for a specific run:

```powershell
gh run view <run-id> --repo roryp/demo-github --log
```

### Required secret

| Secret | Value |
| --- | --- |
| `AZURE_STORAGE_CONNECTION_STRING` | Connection string for the `demosite57342` storage account |

Set or rotate it with:

```powershell
$key  = az storage account keys list -n demosite57342 -g rg-demo-github-site --query "[0].value" -o tsv
$conn = "DefaultEndpointsProtocol=https;AccountName=demosite57342;AccountKey=$key;EndpointSuffix=core.windows.net"
$conn | gh secret set AZURE_STORAGE_CONNECTION_STRING --repo roryp/demo-github
```

### What the workflow does

1. `actions/checkout@v4` checks out the repository.
2. Uses the Azure CLI pre-installed on `ubuntu-latest` to run `az storage blob upload-batch` with `--connection-string` (read from the secret) — once for `*.html`, once for `*.css` — targeting the `$web` container with `--overwrite`.
3. Prints the public site URL at the end.

### Typical end-to-end flow

```text
edit index.html / styles.css
        │
        ▼
 commit + PR to main
        │
        ▼
  merge to main ──► push event ──► workflow runs ──► $web updated
        │
        ▼
https://demosite57342.z13.web.core.windows.net/  (changes live within seconds)
```

## Redeploy manually from your laptop

```powershell
az storage blob upload-batch --account-name demosite57342 -s . -d '$web' --pattern "*.html" --overwrite
az storage blob upload-batch --account-name demosite57342 -s . -d '$web' --pattern "*.css"  --overwrite
```

## Tear down

```powershell
az group delete -n rg-demo-github-site --yes --no-wait
```