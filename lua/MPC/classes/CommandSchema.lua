local CommandSchema = {}
CommandSchema.__index = CommandSchema

function CommandSchema.New(name, description, category, argList, flgList, func, builtIn, aliases, examples)
    local self = setmetatable({}, CommandSchema)
    self.name = name -- Command name
    self.description = description or "No description available." -- Command description
    self.category = category or "" -- Category for grouping commands
    self.arguments = argList or {} -- List of arguments with metadata
    self.flags = flgList or {} -- List of flags with metadata
    self.func = func -- Execution function
    self.aliases = {} -- Aliases for the command
    self.examples = {} -- Examples of how to use the command

    self.requiredArgs = 0
    self:CalculateRequiredArgs()
    self:EnsureArgumentIntegrity()
    self:EnsureFlagIntegrity()
    return self
end

--[[
testCommand = CommandSchema.New(
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
        print("Executing test command with arguments:", args[1], args[2])
        if flags.verbose then
            print("Verbose mode enabled.")
        end
    end,
    true
)
'test "fancy string" 1234 -verbose -count 5'
]]

-- Add an alias to the command
function CommandSchema:AddAlias(alias)
    table.insert(self.aliases, alias)
end

-- Add an example usage for the command
function CommandSchema:AddExample(example)
    table.insert(self.examples, example)
end

-- Set the category for the command
function CommandSchema:SetCategory(category)
    self.category = category
end

function CommandSchema:CalculateRequiredArgs()
    self.requiredArgs = 0
    for _, arg in ipairs(self.arguments) do
        if not arg.optional then
            self.requiredArgs = self.requiredArgs + 1
        end
    end
end

function CommandSchema:EnsureArgumentIntegrity()
    local argNames = {}
    for _, arg in ipairs(self.arguments) do
        if not arg.name then
            error("All arguments must have a name.")
        end
        if argNames[arg.name] then
            error("Duplicate argument name: " .. arg.name)
        end
        argNames[arg.name] = true

        arg.description = arg.description or "No description for " .. arg.name

        arg.type = arg.type or "string"
        if arg.type != "string" and arg.type != "number" and arg.type != "register" then
            error("Invalid argument type for " .. arg.name .. ": " .. arg.type)
        end

        arg.optional = arg.optional or false
        if arg.optional and arg.default == nil then
            arg.default = arg.type == "number" and 0 or ""
        end
    end
end

function CommandSchema:EnsureFlagIntegrity()
    for flagName, flag in pairs(self.flags) do
        flag.name = flagName
        flag.type = flag.type or "boolean" -- default type is bool
        if flag.type != "string" and flag.type != "number" and flag.type != "boolean" then
            error("Invalid flag type for " .. flagName .. ": " .. flag.type)
        end

        flag.description = flag.description or "No description for flag " .. flagName

        if flag.default == nil then
            if flag.type == "boolean" then
                flag.default = false
            elseif flag.type == "number" then
                flag.default = 0
            else
                flag.default = ""
            end
        end
    end
end

-- ? For execution
-- Validate arguments against the schema
function CommandSchema:ValidateArguments(args)
    if #args < self.requiredArgs then
        return false, "Missing required arguments."
    end

    for i, argSchema in ipairs(self.arguments) do
        local argValue = args[i]
        if argSchema.type == "number" and tonumber(argValue) == nil then
            return false, "Argument " .. argSchema.name .. " must be a number."
        elseif argSchema.type == "string" and type(argValue) != "string" then
            return false, "Argument " .. argSchema.name .. " must be a string."
        elseif argSchema.type == "register" then
            if type(argValue) == "string" and argValue:lower():match("^r(%d+)$") then -- matches "r0" to "r15"
                local regNum = tonumber(argValue:sub(2))
                if regNum == nil or regNum < 0 or regNum > 15 then
                    return false, "Argument " .. argSchema.name .. " must be a register number between 0 and 15."
                end
                argValue = math.floor(argValue)
            elseif type(argValue) == "number" then
                argValue = math.floor(argValue)
                if argValue < 0 or argValue > 15 then
                    return false, "Argument " .. argSchema.name .. " must be a register number between 0 and 15."
                end
            else
                return false, "Argument " .. argSchema.name .. " must be a register in the format 'r<number>' or an integer between 0 and 15 (e.g. r5)."
            end
        end
    end

    return true
end

-- Validate flags against the schema
function CommandSchema:ValidateFlags(flags)
    for flagName, flagValue in pairs(flags) do
        local flagSchema = self.flags[flagName]
        if not flagSchema then
            return false, "Unknown flag: " .. flagName
        end

        if flagSchema.type == "number" and tonumber(flagValue) == nil then
            return false, "Flag " .. flagName .. " must be a number."
        elseif flagSchema.type == "string" and type(flagValue) != "string" then
            return false, "Flag " .. flagName .. " must be a string."
        elseif flagSchema.type == "boolean" and type(flagValue) != "boolean" then
            return false, "Flag " .. flagName .. " must be a boolean."
        end
    end

    return true
end

MPC.CommandSchema = CommandSchema