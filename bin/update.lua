-- This script updates our environment with the stuff in the GitHub repo.

-- Step 1. Download the latest manifest.
-- Step 2. Compare latest manifest with current manifest, make a list of changed and new files.
--         (If there exists no current manifest, the created list should be all available files.)
-- Step 3. Download changed and new files.
-- TODO: Do stuff for crash consistency.
-- TODO: Handle HTTP request failures.

local MANIFEST_URL = "https://gist.githubusercontent.com/Monadic-Cat/14d640bddddbb46196657a69539190ed/raw/manifest"
local MANIFEST_PATH = "/etc/manifest"

local latest_manifest_req = http.get(MANIFEST_URL .. "?owo=" .. os.epoch())
local latest_manifest_text = latest_manifest_req.readAll()
latest_manifest_req.close()
local latest_manifest = textutils.unserializeJSON(latest_manifest_text)

local old_manifest_file = io.open(MANIFEST_PATH, "r")
local old_manifest = nil
if old_manifest_file ~= nil then
   local old_manifest_text = old_manifest_file:read("*a")
   old_manifest = textutils.unserializeJSON(old_manifest_text)
   old_manifest_file:close()
end

function make_file_hash_dict(file_list)
   local dict = {}
   for _, file in ipairs(file_list) do
      dict[file.name] = file.hash
   end
   return dict
end

-- TODO: consider saving hash here so we can validate downloaded file content
-- Type: [{ name: string }]
local diff = {}
local count = 0
if old_manifest ~= nil then
   local old_hashes = make_file_hash_dict(old_manifest.files)
   for name, hash in pairs(make_file_hash_dict(latest_manifest.files)) do
      if hash ~= old_hashes[name] then
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
for i, needed in ipairs(diff) do
   local name = needed.name
   print("Getting `" .. name .. "` (" .. i .. "/" .. #diff .. ")...")
   local file_req = http.get(latest_manifest.HTTP_ROOT .. "/" .. latest_manifest.COMMIT .. "/" .. name)
   local file_text = file_req.readAll()
   file_req.close()
   files[name] = file_text
end

for name, content in pairs(files) do
   fs.makeDir(fs.getDir(name))
   local file = io.open(name, "w")
   file:write(content)
   file:close()
end

fs.makeDir(fs.getDir(MANIFEST_PATH))
local manifest_file = io.open(MANIFEST_PATH, "w")
manifest_file:write(latest_manifest_text)
manifest_file:close()
