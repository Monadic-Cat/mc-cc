local shell_path = shell.path()

system_startup = shell.getRunningProgram()
system_dir = "/" .. fs.getDir(system_startup)

path_additions = ":".. system_dir .. "/bin"

if not (system_dir == "/") then
   path_additions = path_additions .. ":" .. system_dir .. "/bin/live"
end

shell.setPath(shell_path .. path_additions)
