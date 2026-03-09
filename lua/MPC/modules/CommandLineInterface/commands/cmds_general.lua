-- echo
MPC.RegisterCommand(MPC.CommandSchema.New(
    "echo",
    "Echoes the provided arguments back to the user.",
    "Utility",
    {
        {name = "message", type = "string", optional = false}
    },
    {},
    function(args, flags, computer)
        local msg = table.concat(args, " ")
        computer:print(msg)

        return true
    end,
    true
))



-- fully fledged test cmd
MPC.RegisterCommand(MPC.CommandSchema.New(
    "test",
    "A test command that demonstrates the CommandSchema structure.",
    "Utility",
    {
        {name = "arg1", type = "string"}, -- optional=false by default
        {name = "arg2", type = "number", optional = true, default=321}
    },
    {
        verbose = {type = "boolean", description = "Enable verbose output."},
        count = {type = "number", description = "Number of times to execute.", default = 1}
    },
    function(args, flags, computer)
        for i = 1, flags.count or 1 do
            computer:print("Executing test command with arguments:", args[1], args[2])
            if flags.verbose then
                computer:print("Verbose mode enabled.")
            end
        end
        return true
    end,
    true
))



-- ! HELP function - enumerates all commands and their descriptions
MPC.RegisterCommand(MPC.CommandSchema.New(
    "help",
    "Lists all available commands and their descriptions.",
    "Utility",
    {
        {name = "command", type = "string", optional = true, default = ""}
    },
    {},
    function(args, flags, computer)
        local filter = args[1]
        local commands = MPC.CLI.Commands

        if filter then
            local cmd = commands[filter]
            if cmd then
                computer:print(filter .. ": " .. cmd.description)
            else
                computer:print("Command not found: " .. filter)
            end
        else
            for name, cmd in pairs(commands) do
                if cmd.hidden then continue end
                computer:print(name .. ": " .. cmd.description)
            end
        end

        return true
    end,
    true
))


-- dump registers
local dumpRegSchema = MPC.CommandSchema.New(
    "dumpregs",
    "Dumps the current values of all registers.",
    "Utility",
    {},
    {},
    function(args, flags, computer)
        computer:DumpRegisters()
        return true
    end,
    true
)
dumpRegSchema:SetHidden(true)
MPC.RegisterCommand(dumpRegSchema)