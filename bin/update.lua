-- This script updates our environment with the stuff in the GitHub repo.

-- Step 1. Download the latest manifest.
-- Step 2. Compare latest manifest with current manifest, make a list of changed and new files.
--         (If there exists no current manifest, the created list should be all available files.)
-- Step 3. Download changed and new files.
-- TODO: Do stuff for crash consistency.
-- TODO: Handle HTTP request failures.

local TMP_DIR = "/.tmp"

local MANIFEST_URL = "https://gist.githubusercontent.com/Monadic-Cat/14d640bddddbb46196657a69539190ed/raw/manifest"

-- TODO: figure out cache busting for this particular line
local latest_manifest_req = http.get(MANIFEST_URL)
local latest_manifest_text = latest_manifest_req.readAll()
latest_manifest_req.close()
local latest_manifest = textutils.unserializeJSON(latest_manifest_text)

local old_manifest_file = io.open("/etc/manifest", "r")
local old_manifest = {}
if not (old_manifest_file == nil) then
   local old_manifest_text = old_manifest_file.readAll()
   old_manifest = textutils.unserializeJSON(old_manifest_text)
end

function make_file_hash_dict(file_list)
   local dict = {}
   for _, file in ipairs(file_list) do
      dict[file.name] = file.hash
   end
end

-- TODO: consider saving hash here so we can validate downloaded file content
-- Type: [{ name: string }]
local diff = {}
local count = 0
if not (old_manifest == nil) then
   local old_hashes = make_file_hash_dict(old_manifest.files)
   for name, hash in make_file_hash_dict(latest_manifest.files) do
      if not (hash == old_hashes[name]) then
         count = count + 1
         -- Type: [{ name: string }]
         diff[count] = { name = name }
      end
   end
else
   -- Type: [{ name: string, hash: string }]
   diff = latest_manifest.files
   count = #diff
end

-- Step 3. Download all needed files.
-- Type: { string -> string }
files = {}
for _, name in ipairs(diff) do
   local file_req = http.get(manifest.HTTP_ROOT .. "/" .. name)
   local file_text = file_req.readAll()
   file_req.close()
   files[name] = file_text
end

for name, content in pairs(files) do
   local file = io.open(name, "w")
   file.write(content)
   file.close()
end
