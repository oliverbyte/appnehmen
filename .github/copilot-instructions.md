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

### Deployment Workflow Critical Rules

**CRITICAL**: The deployment workflow must ALWAYS build and deploy both Flutter app and Jekyll website on EVERY push to main branch, regardless of which files changed.

**Why this is critical:**
- After force-pushes, the workflow might not detect file changes correctly
- Users may see old, cached versions of the app with bugs that were supposedly fixed
- The app must be rebuilt to update the service worker cache with new commit IDs

**Implementation:**
- The workflow does NOT use conditional builds based on changed files
- Both Flutter and Jekyll are built on every deployment
- The service worker cache version is updated with the commit ID on every build
- This ensures users always get the latest version after a hard refresh

**If deployment issues occur:**
- Manually trigger the workflow via GitHub Actions UI or `gh workflow run deploy.yml`
- Force rebuild ensures the latest code is deployed
- Verify deployment by checking the commit hash in the deployed service worker

## Language Guidelines

This project uses different languages for different contexts:

- **Code comments**: English only
- **Commit messages**: English only
- **User-facing content (News Screen)**: German only
- **Documentation**: English preferred (unless specifically for German users)

### Examples:
```dart
// Good: Calculate weight trend using linear regression
// Bad: Berechne Gewichtstrend mit linearer Regression

// Commit messages:
// Good: "Fix: Weight chart now displays all recent entries"
// Bad: "Fix: Gewichtsdiagramm zeigt jetzt alle neuesten Einträge"
```

## News Service Update Policy

**Important**: When making user-relevant changes, always update both:
1. **In-app news screen**: `lib/screens/news_screen.dart`
2. **Jekyll website**: `website/index.md` (features section)

### When to add a news entry:
- New features or functionality
- Important bug fixes that affected user experience
- UI/UX improvements
- Changes to existing features
- Performance improvements noticeable by users

### When NOT to add a news entry:
- Internal code refactoring
- Minor code cleanup
- Documentation updates (except website content)
- Development tooling changes

### News entry format:
- Add new entries at the TOP of the list (most recent first)
- Use German language for user-facing content
- Include an appropriate icon (in-app)
- Keep descriptions concise but informative
- Group entries by month (e.g., "Februar 2026", "Januar 2026")

## Data Preservation and Backward Compatibility

**CRITICAL**: This is a PWA with local data storage. All changes must preserve user data and maintain backward compatibility.

### Rules:
- **NEVER delete or modify localStorage keys** without migration logic
- **NEVER change data structure** without backward-compatible reading logic
- **Cache clearing must preserve user data** (only clear cache, not localStorage)
- **Service Worker updates must not delete user data**
- **Test data migration** before deploying breaking changes

### When modifying storage:
1. Read old format first (backward compatibility)
2. Migrate data if needed
3. Write in new format
4. Keep old format reading logic for at least 2 versions

### Safe operations:
- ✅ Clearing Service Worker cache (doesn't affect localStorage)
- ✅ Updating Service Worker version
- ✅ Adding new optional fields to data models
- ✅ Renaming UI elements (doesn't affect data)

### Unsafe operations (require migration):
- ❌ Changing localStorage key names
- ❌ Changing data structure (e.g., array → object)
- ❌ Removing fields from stored data models
- ❌ Changing data types (e.g., string → number)

### Example of safe data structure extension:
```dart
// Old format still works:
final data = json['weight'] as double;

// New optional field with fallback:
final timestamp = json['timestamp'] as String? ?? DateTime.now().toIso8601String();
```

## PWA Update and Cache Management

### Automatic Update Behavior:
- Service Worker automatically detects updates every 60 seconds
- On activation of new Service Worker, all old caches are deleted automatically
- Service Worker sends RELOAD message to all clients to force immediate update
- Update Manager listens for RELOAD messages and reloads the app
- Loading overlay is shown during the reload process
- User data (localStorage) is always preserved during updates

### Manual Cache Clear:
- Info screen has "Cache löschen & neu laden" button for force-clear
- Useful when automatic updates fail or user wants immediate update
- Only clears cache and Service Worker, never touches localStorage

### Critical Rules:
- ✅ Always preserve localStorage during cache operations
- ✅ Service Worker cache name MUST include commit ID for versioning
- ✅ Auto-reload on Service Worker activation ensures users get latest version
- ✅ Show loading overlay during updates to prevent user confusion
- ❌ Never clear localStorage or user data during updates

## Weight Chart Implementation

### Data Filtering and Display:
- **Group by day**: When multiple entries exist per day, show only the latest entry
- **Date comparison**: Extract year/month/day components, ignore time for filtering
- **Time range filtering**: Use `!isBefore()` for inclusive filtering to include cutoff day
- **X-axis labels**: Dynamic interval based on data point count to prevent overlap
  - 7 days: Show all labels (interval 1)
  - 14 days: Every 2nd label (interval 2)
  - 4 weeks: Every 4th label (interval 4)
  - 3+ months: Scale accordingly

### Tooltip and Touch Indicators:
- **Tooltip**: Only show for weight data line (barIndex 0), not trend/target lines
- **Touch indicator**: Use `getTouchedSpotIndicator` to control visual feedback
- **Color**: Indicator must match weight line color (green), not trend line (red)
- **Position**: Touched point stays on actual weight value, not trend line position

### Example Implementation:
```dart
// Group by date and take only latest entry per day
final Map<String, WeightEntry> latestEntriesPerDay = {};
for (final entry in filteredHistory) {
  final dateKey = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
  final existing = latestEntriesPerDay[dateKey];
  if (existing == null || entry.date.isAfter(existing.date)) {
    latestEntriesPerDay[dateKey] = entry;
  }
}

// Dynamic x-axis interval
double _calculateXAxisInterval(int dataPointCount) {
  if (dataPointCount <= 7) return 1;
  if (dataPointCount <= 14) return 2;
  if (dataPointCount <= 30) return 4;
  // ... scale for longer periods
}
```