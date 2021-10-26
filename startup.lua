local shell_path = shell.path()

-- Check if we're running on a disk, by using the same startup
-- resolver code as the ROM does.
local function findStartups(sBaseDir)
   local tStartups = nil
   local sBasePath = "/" .. fs.combine(sBaseDir, "startup")
   local sStartupNode = shell.resolveProgram(sBasePath)
   if sStartupNode then
      tStartups = { sStartupNode }
   end
   -- It's possible that there is a startup directory and a startup.lua file, so this has to be
   -- executed even if a file has already been found.
   if fs.isDir(sBasePath) then
      if tStartups == nil then
         tStartups = {}
      end
      for _, v in pairs(fs.list(sBasePath)) do
         local sPath = "/" .. fs.combine(sBasePath, v)
         if not fs.isDir(sPath) then
            tStartups[#tStartups + 1] = sPath
         end
      end
   end
   return tStartups
end

disk_boot = false

-- Run the user created startup, either from disk drives or the root
local tUserStartups = nil
if settings.get("shell.allow_startup") then
   tUserStartups = findStartups("/")
end
if settings.get("shell.allow_disk_startup") then
   for _, sName in pairs(peripheral.getNames()) do
      if disk.isPresent(sName) and disk.hasData(sName) then
         local startups = findStartups(disk.getMountPath(sName))
         if startups then
            tUserStartups = startups
            disk_boot = true
            break
         end
      end
   end
end

system_dir = "/"
if tUserStartups then
   for _, v in pairs(tUserStartups) do
      system_dir = fs.getDir(v)
   end
end

shell.setPath(shell_path .. ":".. system_dir .. "bin")
