local shell_path = shell.path()

system_startup = shell.getRunningProgram()
system_dir = "/" .. fs.getDir(system_startup)

path_additions = ":".. system_dir .. "/bin"

-- If we're not booting from the root directory, we're booting from a disk.
-- Disk booting gives access to programs that only make sense to run when doing so.
if not (system_dir == "/") then
   path_additions = path_additions .. ":" .. system_dir .. "/bin/live"
   settings.set("system_dir", system_dir)
end

shell.setPath(shell_path .. path_additions)
