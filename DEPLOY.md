# Deploying petit-lambda

This app is the SAM/CloudFormation stack **`petit-production`** (region **us-east-1**):

| Resource | What |
|----------|------|
| `PetitRedirectorFunction-v2` | nodejs22.x — URL redirector, behind the shared **ALB** (`edn.link`, `echodev.net`) |
| `PetitAPIFunction-v2` | ruby3.3 — CRUD API, behind **API Gateway** `450ev4137g` → `api.echocommunity.org/links` |
| `Petit-v2` | DynamoDB table (shortcodes + hit counts), `DeletionPolicy: Retain` |

## How production traffic is wired — read this first

Each function is reached through a **`live` Lambda alias**, which is the production
pointer **and** the rollback lever:

- **Redirector:** ALB target group `Petit-Url-Shortener` → `PetitRedirectorFunction-v2:live`.
  *(The ALB attachment is manual — SAM can't model an ALB event source.)*
- **API:** API Gateway integrations → `PetitAPIFunction-v2:live`
  (the `:live` qualifier is baked into `api-definitions/petit-api.yml`).

**The `live` aliases are managed by hand, not by CloudFormation, on purpose.** That is
what makes deploys safe: `sam deploy` only updates `$LATEST`; **production does not move
until you flip the alias.** A bad deploy can't take down production, and rollback is one
command.

> ⚠️ Do **not** add `AutoPublishAlias` to the template and `sam deploy` without first
> reconciling these pre-existing manual aliases — CloudFormation would try to *create* a
> `live` alias that already exists and the stack update would fail. The `live` alias must
> always exist (the ALB and API Gateway reference it); never delete it.

## Prerequisites

- AWS credentials with deploy permissions (Lambda, CloudFormation, IAM, DynamoDB, API
  Gateway, S3). Use the profile that has them (e.g. `export AWS_PROFILE=nflood`).
- **Docker** (required for `sam build --use-container`).
- AWS **SAM CLI**.

## Deploy procedure

```bash
# 1. Build. --use-container is REQUIRED so the ruby3.3 native gems (json, etc.)
#    compile for the Lambda runtime (Amazon Linux, x86_64). (Set in samconfig.toml.)
sam build --use-container

# 2. Upload the API definition. The template pulls it from S3 via AWS::Include
#    (Fn::Transform), so SAM does NOT package it automatically.
aws s3 cp api-definitions/petit-api.yml s3://serverless.echocommunity.org/petit-api.yml

# 3. Deploy. Updates $LATEST + infrastructure only. Production keeps serving the
#    current `live` alias versions, so this step is NON-disruptive. Review the changeset.
sam deploy            # stack name + parameters come from samconfig.toml
```

## Release to production (per changed function) — with rollback

`sam deploy` updates `$LATEST`; it does **not** change what production serves. To release:

```bash
FN=PetitAPIFunction-v2          # or PetitRedirectorFunction-v2
VER=$(aws lambda publish-version --function-name "$FN" --query Version --output text)

# Smoke-test version $VER off the traffic path before flipping
#   - API:        aws lambda invoke --function-name "$FN:$VER" --payload <api-gw event> out.json
#   - Redirector: aws lambda invoke --function-name "$FN:$VER" --payload '{"path":"/<code>"}' out.json

# Flip production to the new version:
aws lambda update-alias --function-name "$FN" --name live --function-version "$VER"
```

**Rollback (instant, not gated by runtime deprecation):**

```bash
aws lambda update-alias --function-name "$FN" --name live --function-version <previous>
```

Published versions are immutable, so the previous version is always a valid rollback
target. Current known-good versions: redirector `live → 2` (nodejs22), API `live → 3`
(ruby3.3).

## Invariants / gotchas

- **Build must be containerized** (`--use-container`) for the ruby function — building on
  macOS/arm produces incompatible native gems.
- **`Petit-v2` is `Retain`-protected** — a stack delete/replace will not drop the data.
- The redirector needs **`dynamodb:UpdateItem`** for its hit counter (in the template).
- Step 2's S3 copy is manual drift surface — keep `api-definitions/petit-api.yml` in the
  bucket in sync with this repo on every deploy.
