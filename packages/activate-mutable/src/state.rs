pub type FileContents = Vec<u8>;

pub enum ExistingMatch {
    // The home file is identical to the new file.
    EqualNew,
    // The home file is identical to the old file.
    EqualOld,
    // The home file differs from both the old and new files.
    Conflict,
}

impl ExistingMatch {
    // Compare the current home file with the new and old files.
    pub fn from_contents(
        old: Option<&FileContents>,
        new: &FileContents,
        home: &FileContents,
    ) -> Self {
        if new == home {
            ExistingMatch::EqualNew
        } else if Some(home) == old {
            ExistingMatch::EqualOld
        } else {
            // The files differ, or we have no previous file to compare to.
            // A non-existent file is never identical to an existing file.
            ExistingMatch::Conflict
        }
    }
}
