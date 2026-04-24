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

## Redeploy after changes

```powershell
az storage blob upload-batch --account-name demosite57342 -s . -d '$web' --pattern "*.html" --overwrite
az storage blob upload-batch --account-name demosite57342 -s . -d '$web' --pattern "*.css"  --overwrite
```

## Tear down

```powershell
az group delete -n rg-demo-github-site --yes --no-wait
```