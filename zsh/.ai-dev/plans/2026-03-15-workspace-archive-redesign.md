# Workspace Archive Redesign

## Summary

Replace `aws s3 sync`-based push/pull with a single tar.gz archive approach. Rename `.ryanquinn3` to `.ai-dev`. Separate local archival from S3 upload.

## Changes to `zsh/.codespaces-config`

### Variable updates

```shell
# before
export DEV_WORKSPACE_DIR_NAME="ryanquinn3"
export DEV_WORKSPACE_DIR=".${DEV_WORKSPACE_DIR_NAME}"

# after
export DEV_WORKSPACE_DIR=".ai-dev"
export DEV_ARCHIVE_DIR="$HOME/ai-dev-archives"
```

`DEV_WORKSPACE_DIR_NAME` is no longer needed since we're not deriving a hidden dir from it.

### New function: `dev-workspace-archive`

1. `mkdir -p $DEV_ARCHIVE_DIR`
2. `cd /workspaces/obsidian`
3. `find` all `.ai-dev` dirs (root + scattered), build file list
4. `tar czf` with timestamp into `$DEV_ARCHIVE_DIR/<timestamp>.tar.gz`
5. Update `$DEV_ARCHIVE_DIR/latest` symlink
6. Echo the archive path to stdout

### Rewrite: `dev-workspace-push`

1. Call `dev-workspace-archive`, capture path
2. Upload to `s3://vanta-dev-codespace-assets/ryanquinn3/ai-dev-archives/<timestamp>.tar.gz`

### Rewrite: `dev-workspace-pull`

1. `mkdir -p $DEV_ARCHIVE_DIR`
2. List `s3://vanta-dev-codespace-assets/ryanquinn3/ai-dev-archives/`, sort, take last (most recent)
3. Download to `$DEV_ARCHIVE_DIR/<filename>`
4. Update `$DEV_ARCHIVE_DIR/latest` symlink
5. Extract to `/workspaces/obsidian/`

### Other references to update

- `new_prompt` function uses `.ryanquinn3` -- update to `.ai-dev`
- CLAUDE.md references `.ryanquinn3` as notes/research dir -- update to `.ai-dev`

## Migration

User will manually clear old S3 state after verifying the new setup works.
