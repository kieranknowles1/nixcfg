# Exceptions when synchonysing OpenMW lua data files
# All entries except the first must being with a pipe `|` separator.

# Death counts per character https://www.nexusmods.com/morrowind/mods/53136
with_entries(select(.key | test("^NCGDMW_") | not))

# Volatile
| del(.SettingsOMWControls.alwaysRun)

# Player location history (personal plugin)
| del(.Journey)
