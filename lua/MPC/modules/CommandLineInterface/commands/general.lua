print("General commands! :D") -- debug print autoload

-- echo
MPC.RegisterCommand(MPC.CommandSchema.New(
    "echo",
    "Echoes the provided arguments back to the user.",
    "Utility",
    {
        {name = "message", type = "string", optional = false}
    },
    {},
    function(args, flags)
        print("Echo: ", args[1])
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
    function(args, flags)
        for i = 1, flags.count or 1 do
            print("Executing test command with arguments:", args[1], args[2])
            if flags.verbose then
                print("Verbose mode enabled.")
            end
        end
    end,
    true
))