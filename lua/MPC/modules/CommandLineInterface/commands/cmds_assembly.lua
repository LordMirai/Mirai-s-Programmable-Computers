-- assembly-like commands (MIPS)
-- expect: cmp, push, pop, call
-- bound to computer's architecture. Expect to use flags: ZF, SF, OF, CF


-- cmp val1, val2 - sets flags based on the result of val1 - val2, stores the result in $R0
local compareSchema = MPC.CommandSchema.New(
    "cmp",
    "Compares two values and sets flags accordingly.",
    "Assembly",
    {
        {name = "val1", type = "number"}, -- can be registers or immediate values, but will be resolved to numbers before execution
        {name = "val2", type = "number"}
    },
    {},
    function(args, flags, computer)
        local val1, val2 = args[1], args[2]
        local result = val1 - val2
        computer.Registers[0] = result -- Store result in $R0

        -- Set flags
        computer.Flags.ZF = (result == 0) -- Zero Flag
        computer.Flags.SF = (result < 0)  -- Sign Flag
        computer.Flags.OF = (result > 2147483647 or result < -2147483648) -- Overflow Flag
        computer.Flags.CF = (val1 < val2) -- Carry Flag

        return true
    end,
    true
)