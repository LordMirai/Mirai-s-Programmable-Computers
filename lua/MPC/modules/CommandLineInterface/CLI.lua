--[[
! COMMAND LINE INTERFACE

CLI components:

1. Virtual File System (VFS):
   - Example: root = {home = {}, bin = {}} ...
   - Context: Current Working Directory (CWD), environment variables, history
   - Command Registry

2. The Parser:
   - Interprets the command line input, parses it into a command and its arguments, then executes the command.

   Example Input:
       cp file1.txt "this is epic.txt" -v -tail "okay"

   Tokens:
       {"cp", "file1.txt", "this is epic.txt", "-v", "-tail", "okay"}

   Output:
       {
           command = "cp",
           args = {
               "file1.txt",
               "this is epic.txt"
           },
           flags = {
               v = true,
               tail = "okay"
           }
       }

   - If the command is an alias, resolve it to the original command before execution.
     Example: "lsa" resolves to "ls -a".

   - Flags can expect values. Example: "-m 0" parses as {m = "0"} instead of {m = true}.
     This requires checking the command registry for expected flags and their types.

    "Command Schema" = the command structure table, containing all the descriptions, flags and other such metadata.

   Parsing Pipeline:
       a. Tokenization: Split input into tokens, considering quoted strings and escaped characters.
       b. Alias Resolution: Resolve aliases to original commands. "Token injection" - inspect the first token. if it exists as an alias, tokenize the alias' expanded value and replace the original alias token.
       c. "Fetch Command" - Command identification & schema lookup: consider the first token the base command and query the command registry for its specific Schema.
       d. "Evaluate Command" - Contextual parsing: iterate through the remaining tokens, evaluating them against the command's schema.
          - If the token starts with "-", it's a flag. Check if the flag is defined in the command schema.
              - If the flag expects a value, consume the next token as its value.
              - Otherwise, set the flag to true.
        e. Structured output. The result of this pipeline is a final "Command Instance" table, which is ready for execution.

3. Executor:
   - Executes the parsed command on the server.
   - Looks up the command in the registry and calls the associated function with parsed arguments and flags.

4. Output Formatter ("Response"):
   - Command functions return structured responses, not raw strings.
   - Responses include:
       - Message to display to the user
       - Line type (info, warning, error) for color coding


CLI class
Commands - "Top-Level global command" - main command registry, indexed by command name. Each entry contains the command's schema and execution function.
Aliases - maps alias names to their corresponding command strings. When a command is entered, the CLI checks if it matches an alias and resolves it before execution.
Cache - parented to a computer, points to the currently loaded command schemas for that computer. When a command is identified, it is loaded into the cache. Only built-in commands and library commands are cached, not library tables or aliases.

Hit order: Cache -> Built-in commands -> Libraries -> /bin/ commands -> User-defined commands (last 2 ignored until VFS)

Arguments may include registers e.g. $R1, $r9 and system/user variables $UserName, $FancyVariable which are resolved in the Evaluation stage.

* Libraries

A library is a collection of related commands, grouped together for organizational purposes.
E.g. "peripheral" library contains "peripheral wrap", "peripheral call", etc. so it is "peripheral" library with "wrap" and "call" commands.

expect functions like MPC.CLI.Tokenize(str), MPC.CLI.ResolveAlias(tokens), MPC.CLI.FetchCommand(cmdName), MPC.CLI.EvaluateCommand(cmdTable, tokens) and MPC.CLI.ExecuteCommand(cmdInstance)
]]

MPC.CLI = MPC.CLI or {}
MPC.CLI.Commands = MPC.CLI.Commands or {}
MPC.CLI.Libraries = MPC.CLI.Libraries or {}
MPC.CLI.Aliases = MPC.CLI.Aliases or {} -- Alias library


function MPC.RegisterCommand(cmdTable)
    if not cmdTable or not cmdTable.name then
        print("[MPC] Error: Invalid command schema. 'name' field is required.")
        return
    end

    if MPC.CLI.Commands[cmdTable.name] then
        print("[MPC] Warning: Command '" .. cmdTable.name .. "' is being overwritten.")
    end

    print("[MPC] Registering command: " .. cmdTable.name) -- ! Remove after testing
    MPC.CLI.Commands[cmdTable.name] = cmdTable
end






-- 1. Tokenization
function MPC.CLI.Tokenize(str)
    local tokens = {}
    local currentToken = ""
    local inQuote = false -- Track whether we're inside a quoted string
    local quoteChar = "" -- Track which quote character is being used (single or double)
    local escapeNext = false

    str = str:Trim()
    if str == "" then return tokens end

    for i = 1, #str do
        local c = str:sub(i, i) -- Get the current character
        
        if escapeNext then
            currentToken = currentToken .. c
            escapeNext = false
        elseif c == "\\" then
            escapeNext = true
        elseif inQuote then
            if c == quoteChar then
                inQuote = false -- End of quoted string
            else
                currentToken = currentToken .. c
            end
        elseif c == '"' or c == "'" then
            inQuote = true
            quoteChar = c
        elseif c:match("%s") then
            if currentToken != "" then
                table.insert(tokens, currentToken)
                currentToken = ""
            end
        else
            currentToken = currentToken .. c
        end
    end

    
    if currentToken != "" then
        table.insert(tokens, currentToken)
    end
    
    return tokens
end


-- 2. Alias Resolution (Token Injection) "lsa" -> "ls -a"
function MPC.CLI.ResolveAlias(tokens)
    if #tokens == 0 then return tokens end
    
    local firstToken = tokens[1]
    
    -- Check if the first token is an alias
    if MPC.CLI.Aliases[firstToken] then
        local expandedStr = MPC.CLI.Aliases[firstToken]
        local expandedTokens = MPC.CLI.Tokenize(expandedStr)
        
        -- Remove the alias token
        table.remove(tokens, 1)
        
        -- Inject the expanded tokens at the beginning
        for i = #expandedTokens, 1, -1 do
            table.insert(tokens, 1, expandedTokens[i])
        end
    end
    
    return tokens
end


-- 3. Command Identification & Schema Lookup
-- ? Returns the command table and how many tokens it consumed (1 for standard, 2 for library)
function MPC.CLI.FetchCommand(tokens, parentEntity)
    if #tokens == 0 then return nil, 0 end
    
    local cmdName = tokens[1] -- ! To be noted, we do not allow command saving in variables. So trying to run $func will not work.
    local subCmdName = tokens[2]

    -- Hit Order 1: Cache
    if parentEntity and parentEntity.IsComputer then
        if parentEntity.Cache[cmdName] then
            return parentEntity.Cache[cmdName], 1
        end
    end

    -- Hit Order 2: Built-in Commands
    if MPC.CLI.Commands[cmdName] then
        parentEntity.Cache[cmdName] = MPC.CLI.Commands[cmdName]
        return MPC.CLI.Commands[cmdName], 1
    end

    -- Hit Order 3: Libraries (e.g., "peripheral wrap")
    if subCmdName and MPC.CLI.Libraries[cmdName] and MPC.CLI.Libraries[cmdName][subCmdName] then
        local libCmd = MPC.CLI.Libraries[cmdName][subCmdName]
        return libCmd, 2
    end

    return nil, 0
end


-- 4. Command Evaluation
function MPC.CLI.ResolveVariable(currentComputer, val)
    if val:sub(1, 1) == "$" then
        local varName = val:sub(2)
        if varName:lower():StartsWith("r") then
            local regIndex = tonumber(varName:sub(2))
            if regIndex and currentComputer.Registers[regIndex] != nil then
                return currentComputer.Registers[regIndex]
            end
            return "NULL" -- Invalid register reference
        end
        return currentComputer.SystemVariables[varName] or currentComputer.UserVariables[varName] or val
    end
    return val -- Not a variable, return as is
end

function MPC.CLI.EvaluateCommand(currentComputer, cmdTable, tokens, startIndex)
    -- cmdTable IS the schema, containing all the metadata about the command, including expected flags and their types.
    -- 
    local cmdInstance = {
        command = cmdTable.name or "unknown",
        schema = cmdTable,
        computer = currentComputer,
        func = cmdTable.func,
        args = {},
        flags = {}
    }
    local schemaFlags = cmdTable.flags or {}
    local i = startIndex

    while i <= #tokens do
        local token = tokens[i]
        token = MPC.CLI.ResolveVariable(currentComputer, token)

        if type(token) == "string" and token:sub(1, 1) == "-" then
            -- It's a flag. Strip leading dashes (supports both -v and --tail)
            local flagName = token:match("^%-+(.+)")
            local expectedSchema = schemaFlags[flagName]

            if expectedSchema then
                if expectedSchema.type == "string" or expectedSchema.type == "number" then
                    -- Consume the next token as the value
                    local flagValue = tokens[i + 1]
                    if flagValue then
                        flagValue = MPC.CLI.ResolveVariable(currentComputer, flagValue)
                        if expectedSchema.type == "number" then 
                            flagValue = tonumber(flagValue) or 0 
                        end
                        cmdInstance.flags[flagName] = flagValue
                        i = i + 1 -- Skip the consumed token
                    else
                        -- Missing value, handle gracefully
                        cmdInstance.flags[flagName] = expectedSchema.type == "number" and 0 or ""
                    end
                else
                    -- Boolean flag
                    cmdInstance.flags[flagName] = true
                end
            else
                -- Undocumented flag found, default to boolean true
                cmdInstance.flags[flagName] = true
            end
        else
            -- It's an argument
            table.insert(cmdInstance.args, token)
        end
        
        i = i + 1
    end

    return cmdInstance
end


-- 5. Command Execution
function MPC.CLI.ExecuteCommand(currentComputer, cmdInstance)
    if not cmdInstance or type(cmdInstance.func) ~= "function" then
        return { type = "error", message = "Command execution failed: No valid function found." }
    end

    -- Use pcall to prevent the whole CLI from crashing if a command errors
    local success, result = pcall(cmdInstance.func, cmdInstance.args, cmdInstance.flags, currentComputer)
    
    if success then
        -- Enforce structured response
        if type(result) == "table" and result.type and result.message then
            return result
        else
            return { type = "info", message = tostring(result) or "Command executed successfully without output." }
        end
    else
        return { type = "error", message = "Runtime Error: " .. tostring(result) }
    end
end







print("CLI reloaded")