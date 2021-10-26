-- A simple `cat` script.
arg = { ... }

for _, name in ipairs(arg) do
   for line in io.lines(name) do
      print(line)
   end
end
