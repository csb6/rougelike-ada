puts "Paste in the traceback, then press enter twice:"
input = gets(sep="\n\n")

exe_name_index = input.index("Execution of ") + 13
end_exe_name = input.index(/\s/, exe_name_index)
exe_name = input[exe_name_index .. end_exe_name]

# Find the load address (first address of the stack trace)
first_address = input.index("Load address: ") + 14
end_first_address = input.index(/\s/, first_address)

# Find the rest of the addresses of the stack trace
addresses = []
addresses << input[first_address .. end_first_address].chomp

next_address = input.index("0x", end_first_address)
new_addresses = input[next_address .. ].chomp.split(/\s/)
new_addresses.each{|addr| addresses << addr}

# Use atos to get a symbolic traceback with line numbers, etc.
puts "\n\n"
puts `atos -o #{exe_name} #{addresses.join(" ")}`