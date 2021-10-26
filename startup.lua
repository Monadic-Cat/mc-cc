local shell_path = shell.path()

system_startup = shell.getRunningProgram()
system_dir = fs.getDir(system_startup)

shell.setPath(shell_path .. ":".. "/" .. system_dir .. "bin")
