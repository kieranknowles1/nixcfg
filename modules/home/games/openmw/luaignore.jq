# Death counts per character
with_entries(select(.key | test("^NCGDMW_") | not)) |

# Volatile
del(.SettingsOMWControls.alwaysRun)
