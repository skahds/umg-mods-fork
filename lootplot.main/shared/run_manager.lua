---@class lootplot.main.RunManager
local runManager = {}



umg.definePacket("lootplot.main:runData", {typelist = {"boolean", "string"}})
umg.definePacket("lootplot.main:startRun", {typelist = {"string"}})
umg.definePacket("lootplot.main:continueRun", {typelist = {}})


local RUN_FILENAME = "run.bin"


local function loadRunServer()
    local save = server.getSaveFilesystem()

    if save:exists(RUN_FILENAME) then
        ---@type lootplot.main.RunSerialized
        local runSerialized, msg = umg.deserialize((assert(save:read(RUN_FILENAME))))
        if not runSerialized then
            umg.log.error("Cannot serialize run: "..msg)
        else
            assert(runSerialized)
        end
        return runSerialized
    end

    return nil
end

local function queryRunServer()
    local runSerialized = loadRunServer()

    if runSerialized then
        return runSerialized.runMeta
    end

    return nil
end

---@param run lootplot.main.Run
local function serializeRun(run)
    ---@class lootplot.main.RunSerialized
    local data = {
        runMeta = run:getMetadata(),
        runData = run:serialize(),
        rngState = lp.SEED:serializeToTable()
    }
    return umg.serialize(data)
end

---@param run lootplot.main.Run
local function saveRunServer(run)
    local save = server.getSaveFilesystem()
    local runSerialized = nil

    if run:canSerialize() then
        umg.log.debug("Current run is serializable. Serializing run...")
        runSerialized = serializeRun(run)
    end

    if runSerialized then
        save:write(RUN_FILENAME, runSerialized)
    else
        umg.log.debug("Current run is not serializable. Discarding run...")
    end
end



if server then

local startRunService = require("server.start_run_service")

server.on("lootplot.main:startRun", function(clientId, runOptionsString)
    if server.getHostClient() == clientId then
        local runOptions = umg.deserialize(runOptionsString)
        startRunService.startGame(
            lp.main.PLAYER_TEAM,
            runOptions.starterItem,
            runOptions.worldgenItem,
            runOptions.background
        )
        lp.setPlayerTeam(clientId, lp.main.PLAYER_TEAM)
    end
end)

server.on("lootplot.main:continueRun", function(clientId)
    if server.getHostClient() == clientId then
        local runSerialized = assert(loadRunServer())
        startRunService.continueGame(runSerialized.runData, runSerialized.rngState)
        lp.setPlayerTeam(clientId, lp.main.PLAYER_TEAM)
    end
end)


umg.on("@playerJoin", function(clientId)
    local runData = ""
    local isHost = server.getHostClient() == clientId
    if isHost then
        local info = queryRunServer()
        if info then
            runData = umg.serialize(info)
        end
    end
    server.unicast(clientId, "lootplot.main:runData", isHost, runData)
end)

umg.on("@quit", function()
    local run = lp.main.getRun()

    if run and run:getAttribute("LEVEL") >= 1 and run:getAttribute("ROUND") >= 1 then
        if run:isLose() then
            runManager.deleteRun()
        else
            saveRunServer(run)
        end
    end
end)

function runManager.saveRun()
    local run = lp.main.getRun()

    if run then
        saveRunServer(run)
        return true
    end

    return false
end

function runManager.deleteRun()
    local save = server.getSaveFilesystem()
    save:remove(RUN_FILENAME)
end

end -- if server


local runInfoArrived = false
local runInfo = nil


if client then

client.on("lootplot.main:runData", function(isHost, runmeta)
    -- TODO: Keep the isHost, in case if we want to support multiplayer
    runInfoArrived = true

    if #runmeta > 0 then
        runInfo = umg.deserialize(runmeta)
    end
end)

end -- if client

function runManager.hasReceivedInfo()
    -- Server always have run info, but client may not.
    return not not (runInfoArrived or server)
end

function runManager.getSavedRun()
    if server then
        return queryRunServer()
    else
        return runInfo
    end
end

function runManager.continueRun()
    client.send("lootplot.main:continueRun")
end


local newRunOptionsTc = typecheck.assert({
    starterItem = "string",
    seed = "string"
})
---@param options {starterItem:string,seed:string,background:string?}
function runManager.startRun(options)
    newRunOptionsTc(options)
    client.send("lootplot.main:startRun", umg.serialize(options))
end

return runManager
