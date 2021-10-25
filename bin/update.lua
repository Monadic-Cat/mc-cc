-- This script updates our environment with the stuff in the GitHub repo.

-- Step 1. Download the latest manifest.
-- Step 2. Compare latest manifest with current manifest, make a list of changed and new files.
--         (If there exists no current manifest, the created list should be all available files.)
-- Step 3. Download changed and new files.

local TMP_DIR = "/.tmp"

local MANIFEST_URL = "https://gist.githubusercontent.com/Monadic-Cat/14d640bddddbb46196657a69539190ed/raw/manifest"
