# Troubleshooting

## Scripts don't work

**Verify scripts are executable:**
```bash
chmod +x scripts/*.sh
```

## Rules not detected

**Check structure:**
```bash
bash scripts/validate-rules.sh
```

## Path errors

**Ensure you run scripts from project root**, not from `scripts/`.

## MCP shows unavailable

**Possible causes:**
- MCP server not configured in your IDE
- MCP server not running
- GitHub MCP server not installed

**Solutions:**
- Check your IDE's MCP settings
- Verify MCP server is running
- Install/configure GitHub MCP server if needed
- Workflow will fall back to gh CLI or REST automatically

## gh CLI shows not authenticated

**Solution:**
```bash
gh auth login
# Follow prompts to authenticate
```

## GitHub token shows missing

**Solutions:**
1. Export token before launching your IDE:
   ```bash
   export GITHUB_TOKEN=your_token_here
   # Relaunch your IDE from this shell
   ```

2. Or use gh CLI instead:
   ```bash
   gh auth login
   ```

3. Or add to shell profile:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export GITHUB_TOKEN=your_token_here
   # Then restart shell and relaunch your IDE
   ```

## Fallback occurs silently

**Check:**
- Review "Execution Environment" section in `github-signals.md`
- Look for fallback messages in console output
- Verify environment setup

**Solution:** Fix environment issue and rerun. The gate will detect the correct method.

## YAML concatenation in config

**Symptoms:** Config file shows concatenated values like `repo: owner/namerepo: newowner/newname`

**Cause:** Inline concatenation instead of full line replacement

**Solution:** Use full line replacement pattern `^repo:\s*.*$` and replace entire line

## Target not overridden

**Symptoms:** Config still shows old target after providing new one

**Cause:** Target Gate logic not executed or comparison failed

**Solution:** Verify config parsing and comparison logic

## Archive not created on target change

**Symptoms:** Target changed but no archive folder created

**Cause:** Reset Gate logic not executed or RUN_STATE.json not read correctly

**Solution:** Verify RUN_STATE.json exists and is readable

## Mixed content in artifacts

**Symptoms:** Current artifacts contain both old and new target IDs

**Cause:** Files not written as fresh (append instead of overwrite)

**Solution:** Ensure all artifact writes use full file replacement
