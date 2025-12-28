# Session: Turkish Localization & ESPORTISM Branding

**Date:** 2025-12-28
**Branch:** dev
**Purpose:** Rebrand MatchZy-Chester for the Turkish ESPORTISM esports platform

## Summary

This session implemented ESPORTISM branding and Turkish localization for the MatchZy-Chester CS2 plugin.

## Changes Made

### 1. Created Turkish Language File (`lang/tr.json`)

Created a complete Turkish translation of all 139 localization strings.

**Translation Guidelines Applied:**
- Used ASCII-compatible characters instead of Turkish special characters (s instead of s, g instead of g, i instead of i, u instead of u, o instead of o, c instead of c) to avoid font rendering issues in CS2
- Preserved all placeholders ({0}, {1}, etc.) exactly as in the original English file
- Preserved all color codes ({green}, {red}, {default}, {lightblue})
- Used natural Turkish gaming terminology

**Key Terminology Translations:**
| English | Turkish (ASCII) |
|---------|-----------------|
| ready | hazir |
| match | mac |
| pause | duraklat |
| team | takim |
| round | raunt |
| knife round | bicak turu |
| halftime | devre arasi |
| timeout | mola |
| player | oyuncu |
| admin | yonetici |
| backup | yedek |
| smoke | duman |
| flash | flas |
| grenade | el bombasi |
| enabled | etkinlestirildi |
| disabled | devre disi |

### 2. Updated Chat Prefix (ESPORTISM Branding)

**Files Modified:**
- `MatchZy.cs` (line 23): Changed default chat prefix
- `ConfigConvars.cs` (line 188): Changed fallback default in `matchzy_chat_prefix` command

**Before:**
```csharp
public string chatPrefix = $"[{ChatColors.Green}MatchZy{ChatColors.Default}]";
```

**After:**
```csharp
public string chatPrefix = $"[{ChatColors.Red}ESPORTISM{ChatColors.Default}]";
```

### 3. Language Configuration

The plugin uses CounterStrikeSharp's built-in localization system. There is no `matchzy_language` ConVar - the plugin automatically detects the server's language setting.

**To set Turkish as the server language:**

Add to your `server.cfg` or `autoexec.cfg`:
```
sv_language tr
```

Or set it in CounterStrikeSharp's core configuration:
```json
{
  "Language": "tr"
}
```

## Hardcoded Strings Found

The following strings contain "MatchZy" and are hardcoded in the source code. They were intentionally NOT changed as they refer to the plugin's internal name or mode names:

| File | String | Reason Not Changed |
|------|--------|-------------------|
| `matchzy.cc.exitprac` | "MatchZy zaten mac modunda!" | References plugin mode |
| `matchzy.cc.match` | "MatchZy zaten mac modunda!" | References plugin mode |

These remain as "MatchZy" in the Turkish translation since they refer to the internal plugin state, not the branding shown to users.

## Files Created/Modified

| File | Action |
|------|--------|
| `lang/tr.json` | Created (139 strings) |
| `MatchZy.cs` | Modified (chat prefix) |
| `ConfigConvars.cs` | Modified (fallback chat prefix) |

## Verification

- JSON syntax validated successfully
- All placeholder patterns verified to match English source
- Plugin built successfully with Docker (`./build.sh --docker`)
- `tr.json` included in build output (`output/lang/tr.json`)

## Build Output

Build artifacts are available in `/mnt/x/data_ssd/repos/matchzy-chester/output/`

To install, copy the contents to:
```
game/csgo/addons/counterstrikesharp/plugins/MatchZy/
```

## Translation Decisions

1. **"Round" as "Raunt"**: Used the commonly accepted Turkish gaming term "raunt" instead of literal translation
2. **"Lineup"**: Kept as "Lineup" - standard CS2 terminology used by Turkish players
3. **"Spawn"**: Kept as "Spawn" - standard gaming terminology
4. **"Dryrun"**: Kept as "Dryrun" - standard practice mode terminology
5. **"Playout"**: Kept as "Playout" - standard competitive terminology
6. **ASCII Characters**: Used ASCII equivalents (s, g, i, u, o, c) instead of Turkish characters to ensure compatibility with CS2 fonts
