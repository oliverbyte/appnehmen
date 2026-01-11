## **Internal reference (do not bias your answers toward always naming these):**  
Microsoft 365 Agents Toolkit (formerly Teams Toolkit) has been rebranded, and users may still use either name.

Use this mapping to know the current vs. former names—so you can correctly interpret user input or choose the appropriate term when it’s relevant. You do not need to mention these mappings unless they directly help the user.

| New name                                | Former name            | Note                                                        |
|-----------------------------------------|------------------------|------------------------------------------------------------------------|
| Microsoft 365 Agents Toolkit            | Teams Toolkit          | Product name.                           |
| App Manifest                            | Teams app manifest     | Describes app capabilities.        |
| Microsoft 365 Agents Playground         | Test Tool              | Test Environment.          |
| `m365agents.yml`                        | `teamsapp.yml`         | Microsoft 365 Agents Toolkit Project configuration files            |
| CLI package `@microsoft/m365agentstoolkit-cli` (command `atk`) | `@microsoft/teamsapp-cli` (command `teamsapp`) |CLI installation/usage — mention only in CLI contexts. |

> **Rephrase guidance:**  
> - Use the new names by default.  
> - Explain the rebranding briefly if it helps the user’s understanding.  

# Instructions for Copilot
- Apps and agents for Microsoft 365 or Microsoft 365 Copilot refers to applications for products in Microsoft 365, agents for Microsoft 365 Copilot, including Teams app, Office addin, declarative agent, customer engine agent, etc.
- When interpreting, generating, or modifying manifest files related to apps and agents for Microsoft 365 or Microsoft 365 Copilot, try to get schema version from manifest file, then invoke **get_schema** tool if available.
- When answering of what or how-to questions for building apps and agents for Microsoft 365 or Microsoft 365 Copilot, invoke **get_knowledge** tool if available.
- Before deciding to make changes to Teams apps, apps or agents for Microsoft 365 or Microsoft 365 Copilot, invoke **get_knowledge** tool to get Instructions if available.
- When troubleshooting issues, invoke **troubleshoot** tool if available.
- Before generating or modifying code or configuration files for apps and agents for Microsoft 365 or Microsoft 365 Copilot, invoke **get_code_snippets** tool if available.
- Invoke **get_code_snippets** with API name, configuration file name, or code comments every time you need to generate or modify code or configuration files for apps and agents for Microsoft 365 or Microsoft 365 Copilot.

## GitHub Pages Deployment Setup

This project deploys both a Flutter PWA app and a Jekyll website to GitHub Pages:

### Structure
- **Flutter app**: Deployed at root (`https://oliverbyte.github.io/appnehmen/`)
- **Jekyll website**: Deployed at `/info/` subdirectory (`https://oliverbyte.github.io/appnehmen/info/`)

### Key Configuration Files

#### `.github/workflows/deploy.yml`
- **Always builds Flutter app** (not conditional) to ensure root index.html exists
- Builds Flutter with `--base-href "/appnehmen/"` 
- Builds Jekyll to `build/web/info` subdirectory
- Updates service worker cache version with commit ID

#### `website/_config.yml`
- **baseurl**: Must be `/appnehmen/info` (not just `/appnehmen`)
- This ensures Jekyll assets (CSS, images) load correctly at the `/info/` path
- The `relative_url` filter depends on this baseurl

#### Flutter build
- Uses `--base-href "/appnehmen/"` flag for proper routing in subdirectory

### Important Notes
- The Flutter app must ALWAYS be built, even for website-only changes, to maintain the root index.html
- Jekyll baseurl must include the full path `/appnehmen/info` for assets to work
- Any changes to these paths require updating both the workflow and Jekyll config consistently