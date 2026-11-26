local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles;

local assert = function(condition, errorMessage) 
    if (not condition) then
        error(if errorMessage then errorMessage else "assert failed", 3)
    end
end

if typeof(clonefunction) == "function" then
    -- Fix is_____ functions for shitsploits, those functions should never error, only return a boolean.

    local
        isfolder_copy,
        isfile_copy,
        listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder)
            local success, data = pcall(isfolder_copy, folder)
            return (if success then data else false)
        end

        isfile = function(file)
            local success, data = pcall(isfile_copy, file)
            return (if success then data else false)
        end

        listfiles = function(folder)
            local success, data = pcall(listfiles_copy, folder)
            return (if success then data else {})
        end
    end
end

local SaveManager = {} do
    SaveManager.Folder = "LinoriaLibSettings"
    SaveManager.SubFolder = ""
    SaveManager.Ignore = {}
    SaveManager.Library = nil
    SaveManager.UseLoadingOrder = false
    SaveManager.LoadingOrder = {}
    SaveManager.ActiveConfig = nil
    SaveManager.Dirty = false
    SaveManager.AutoSave = false
    SaveManager.AutoSaveDelay = 2
    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = 'Toggle', idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Toggles[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = 'Slider', idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = 'Dropdown', idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value, modifiers = object.Modifiers }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValue({ data.key, data.mode, data.modifiers })
                end
            end,
        },
        ESPPanel = {
            Save = function(idx, object)
                return { type = 'ESPPanel', idx = idx, layout = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and typeof(data.layout) == 'table' then
                    object:SetValue(data.layout)
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = 'Input', idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.text and type(data.text) == 'string' then
                    SaveManager.Library.Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:SetLoadingOrder(enabled, order)
        self.UseLoadingOrder = enabled

        if typeof(order) == "table" then
            self.LoadingOrder = order
        end
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", -- themes
            "ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', -- themes
            "VideoLink",
        })
    end

    --// Folders \\--
    function SaveManager:CheckSubFolder(createFolder)
        if typeof(self.SubFolder) ~= "string" or self.SubFolder == "" then return false end

        if createFolder == true then
            if not isfolder(self.Folder .. "/settings/" .. self.SubFolder) then
                makefolder(self.Folder .. "/settings/" .. self.SubFolder)
            end
        end

        return true
    end

    function SaveManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split('/')
        for idx = 1, #parts do
            local path = table.concat(parts, '/', 1, idx)
            if not table.find(paths, path) then paths[#paths + 1] = path end
        end

        paths[#paths + 1] = self.Folder .. '/themes'
        paths[#paths + 1] = self.Folder .. '/settings'

        if self:CheckSubFolder(false) then
            local subFolder = self.Folder .. "/settings/" .. self.SubFolder
            parts = subFolder:split('/')

            for idx = 1, #parts do
                local path = table.concat(parts, '/', 1, idx)
                if not table.find(paths, path) then paths[#paths + 1] = path end
            end
        end

        return paths
    end

    function SaveManager:BuildFolderTree()
        local paths = self:GetPaths()

        for i = 1, #paths do
            local str = paths[i]
            if isfolder(str) then continue end

            makefolder(str)
        end
    end

    function SaveManager:CheckFolderTree()
        if isfolder(self.Folder) then return end
        SaveManager:BuildFolderTree()

        task.wait(0.1)
    end

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in next, list do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder;
        self:BuildFolderTree()
    end

    function SaveManager:SetSubFolder(folder)
        self.SubFolder = folder;
        self:BuildFolderTree()
    end

    --// Save, Load, Delete, Refresh \\--
    function SaveManager:Save(name)
        if (not name) then
            return false, 'no config file is selected'
        end
        SaveManager:CheckFolderTree()

        local fullPath = self.Folder .. '/settings/' .. name .. '.json'
        if SaveManager:CheckSubFolder(true) then
            fullPath = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. '.json'
        end

        local data = {
            objects = {}
        }

        for idx, toggle in next, self.Library.Toggles do
            if not toggle.Type then continue end
            if not self.Parser[toggle.Type] then continue end
            if self.Ignore[idx] then continue end

            table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
        end

        for idx, option in next, self.Library.Options do
            if not option.Type then continue end
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end

            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return false, 'failed to encode data'
        end

        writefile(fullPath, encoded)

        self.ActiveConfig = name
        self.Dirty = false
        self:RefreshStatus()

        return true
    end

    function SaveManager:Load(name)
        if (not name) then
            return false, 'no config file is selected'
        end
        SaveManager:CheckFolderTree()

        local file = self.Folder .. '/settings/' .. name .. '.json'
        if SaveManager:CheckSubFolder(true) then
            file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. '.json'
        end

        if not isfile(file) then return false, 'invalid file' end

        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not success then return false, 'decode error' end

        if self.UseLoadingOrder == true and typeof(self.LoadingOrder) == "table" then
            table.sort(decoded.objects, function(a, b)
                local aIndex = table.find(self.LoadingOrder, a.type) or math.huge
                local bIndex = table.find(self.LoadingOrder, b.type) or math.huge
                return aIndex < bIndex
            end)
        end

        for _, option in decoded.objects do
            if not option.type then continue end
            if not self.Parser[option.type] then continue end
            if self.Ignore[option.idx] then continue end

            task.spawn(self.Parser[option.type].Load, option.idx, option) -- task.spawn() so the config loading wont get stuck.
        end

        self.ActiveConfig = name

        -- loading fires every change callback, so settle the flag after they land
        task.defer(function()
            self.Dirty = false
            self:RefreshStatus()
        end)

        return true
    end

    function SaveManager:Delete(name)
        if (not name) then
            return false, 'no config file is selected'
        end

        local file = self.Folder .. '/settings/' .. name .. '.json'
        if SaveManager:CheckSubFolder(true) then
            file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. '.json'
        end

        if not isfile(file) then return false, 'invalid file' end

        local success = pcall(delfile, file)
        if not success then return false, 'delete file error' end

        if self.ActiveConfig == name then
            self.ActiveConfig = nil
            self.Dirty = false
            self:RefreshStatus()
        end

        return true
    end

    function SaveManager:ConfigPath(name)
        if self:CheckSubFolder(true) then
            return self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end

        return self.Folder .. "/settings/" .. name .. ".json"
    end

    function SaveManager:ConfigExists(name)
        if typeof(name) ~= "string" or name:gsub(" ", "") == "" then return false end
        return isfile(self:ConfigPath(name))
    end

    function SaveManager:Duplicate(from, to)
        if not self:ConfigExists(from) then return false, "config does not exist" end
        if self:ConfigExists(to) then return false, "a config with that name already exists" end

        local ok, data = pcall(readfile, self:ConfigPath(from))
        if not ok then return false, "could not read the config" end

        local written = pcall(writefile, self:ConfigPath(to), data)
        if not written then return false, "could not write the config" end

        return true
    end

    function SaveManager:Rename(from, to)
        local ok, err = self:Duplicate(from, to)
        if not ok then return false, err end

        self:Delete(from)

        if self.ActiveConfig == from then
            self.ActiveConfig = to
            self:RefreshStatus()
        end

        return true
    end

    -- Keeps the status line under the config list honest.
    function SaveManager:RefreshStatus()
        if not self.StatusLabel then return end

        local Text = self.ActiveConfig
            and string.format("Active: %s%s", self.ActiveConfig, self.Dirty and "  (unsaved)" or "")
            or "No config loaded"

        self.StatusLabel:SetText(Text)
    end

    function SaveManager:MarkDirty()
        if self.Dirty then return end

        self.Dirty = true
        self:RefreshStatus()

        if not (self.AutoSave and self.ActiveConfig) then return end

        task.delay(self.AutoSaveDelay, function()
            if self.AutoSave and self.Dirty and self.ActiveConfig then
                self:Save(self.ActiveConfig)
            end
        end)
    end

    -- Every saved element marks the config dirty when the user changes it.
    function SaveManager:WatchChanges()
        local function Watch(Collection)
            for idx, object in next, Collection do
                if typeof(object) ~= "table" then continue end
                if not object.Type or not self.Parser[object.Type] then continue end
                if self.Ignore[idx] then continue end
                if object.__SaveManagerWatched then continue end

                object.__SaveManagerWatched = true

                -- the library keeps one Changed function per element, so wrap
                -- whatever is there rather than calling OnChanged, which would
                -- replace the script's own callback
                local Existing = object.Changed

                object.Changed = function(...)
                    self:MarkDirty()

                    if typeof(Existing) == "function" then
                        Existing(...)
                    end
                end
            end
        end

        Watch(self.Library.Toggles)
        Watch(self.Library.Options)
    end

    function SaveManager:RefreshConfigList()
        local success, data = pcall(function()
            SaveManager:CheckFolderTree()

            local list = {}
            local out = {}

            if SaveManager:CheckSubFolder(true) then
                list = listfiles(self.Folder .. "/settings/" .. self.SubFolder)
            else
                list = listfiles(self.Folder .. "/settings")
            end
            if typeof(list) ~= "table" then list = {} end

            for i = 1, #list do
                local file = list[i]
                if file:sub(-5) == '.json' then
                    -- i hate this but it has to be done ...

                    local pos = file:find('.json', 1, true)
                    local start = pos

                    local char = file:sub(pos, pos)
                    while char ~= '/' and char ~= '\\' and char ~= '' do
                        pos = pos - 1
                        char = file:sub(pos, pos)
                    end

                    if char == '/' or char == '\\' then
                        table.insert(out, file:sub(pos + 1, start - 1))
                    end
                end
            end

            return out
        end)

        if (not success) then
            if self.Library then
                self.Library:Notify('Failed to load config list: ' .. tostring(data))
            else
                warn('Failed to load config list: ' .. tostring(data))
            end

            return {}
        end

        return data
    end

    --// Auto Load \\--
    function SaveManager:GetAutoloadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        if isfile(autoLoadPath) then
            local successRead, name = pcall(readfile, autoLoadPath)
            if not successRead then
                return "none"
            end

            name = tostring(name)
            return if name == "" then "none" else name
        end

        return "none"
    end

    function SaveManager:LoadAutoloadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        if isfile(autoLoadPath) then
            local successRead, name = pcall(readfile, autoLoadPath)
            if not successRead then
                self.Library:Notify('Failed to load autoload config: write file error')
                return
            end

            local success, err = self:Load(name)
            if not success then
                self.Library:Notify('Failed to load autoload config: ' .. err)
                return
            end

            self.Library:Notify(string.format('Auto loaded config %q', name))
        end
    end

    function SaveManager:SaveAutoloadConfig(name)
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        local success = pcall(writefile, autoLoadPath, name)
        if not success then return false, 'write file error' end

        return true, ""
    end

    function SaveManager:DeleteAutoLoadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        local success = pcall(delfile, autoLoadPath)
        if not success then return false, 'delete file error' end

        return true, ""
    end

    --// GUI \\--
    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, 'SaveManager:BuildConfigSection -> Must set SaveManager.Library')

        local Library = self.Library
        local section = tab:AddRightGroupbox('Configuration')

        local function Selected()
            local name = Library.Options.SaveManager_ConfigList.Value
            if typeof(name) ~= "string" or name == "" then return nil end
            return name
        end

        local function Typed()
            local name = Library.Options.SaveManager_ConfigName.Value
            if typeof(name) ~= "string" or name:gsub(' ', '') == '' then return nil end
            return name
        end

        local function Refresh(select)
            Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            Library.Options.SaveManager_ConfigList:SetValue(select)
        end

        --// Status \\--
        self.StatusLabel = section:AddLabel('No config loaded', true)
        self.AutoloadConfigLabel = section:AddLabel('Autoload: ' .. self:GetAutoloadConfig(), true)

        section:AddDivider()

        --// Pick one \\--
        section:AddDropdown('SaveManager_ConfigList', {
            Text = 'Config list',
            Values = self:RefreshConfigList(),
            AllowNull = true,
            Searchable = true,
        })

        section:AddButton({
            Text = 'Load',
            Func = function()
                local name = Selected()
                if not name then return Library:Notify('Pick a config first', 3) end

                local ok, err = self:Load(name)
                if not ok then return Library:Notify('Failed to load: ' .. err, 4) end

                Library:Notify(string.format('Loaded %q', name), 3)
                self:RefreshStatus()
            end,
        }):AddButton({
            Text = 'Save',
            Tooltip = 'Overwrites the selected config',
            Func = function()
                local name = Selected() or self.ActiveConfig
                if not name then return Library:Notify('Pick a config first', 3) end

                local ok, err = self:Save(name)
                if not ok then return Library:Notify('Failed to save: ' .. err, 4) end

                Library:Notify(string.format('Saved %q', name), 3)
            end,
        })

        section:AddButton({
            Text = 'Duplicate',
            Func = function()
                local from, to = Selected(), Typed()
                if not from then return Library:Notify('Pick a config first', 3) end
                if not to then return Library:Notify('Type a name for the copy', 3) end

                local ok, err = self:Duplicate(from, to)
                if not ok then return Library:Notify('Failed to duplicate: ' .. err, 4) end

                Library:Notify(string.format('Copied %q to %q', from, to), 3)
                Refresh(to)
            end,
        }):AddButton({
            Text = 'Rename',
            Func = function()
                local from, to = Selected(), Typed()
                if not from then return Library:Notify('Pick a config first', 3) end
                if not to then return Library:Notify('Type the new name', 3) end

                local ok, err = self:Rename(from, to)
                if not ok then return Library:Notify('Failed to rename: ' .. err, 4) end

                Library:Notify(string.format('Renamed to %q', to), 3)
                Refresh(to)
            end,
        })

        section:AddButton({
            Text = 'Delete',
            DoubleClick = true,
            Tooltip = 'Double click, this cannot be undone',
            Func = function()
                local name = Selected()
                if not name then return Library:Notify('Pick a config first', 3) end

                local ok, err = self:Delete(name)
                if not ok then return Library:Notify('Failed to delete: ' .. err, 4) end

                Library:Notify(string.format('Deleted %q', name), 3)
                Refresh(nil)
            end,
        }):AddButton({
            Text = 'Refresh list',
            Func = function() Refresh(Selected()) end,
        })

        section:AddDivider()

        --// Make a new one \\--
        section:AddInput('SaveManager_ConfigName', {
            Text = 'New config name',
            Placeholder = 'name',
            Finished = true,
        })

        section:AddButton({
            Text = 'Create',
            Func = function()
                local name = Typed()
                if not name then return Library:Notify('Type a name first', 3) end

                if self:ConfigExists(name) then
                    return Library:Notify('That config already exists, use Save to overwrite it', 4)
                end

                local ok, err = self:Save(name)
                if not ok then return Library:Notify('Failed to create: ' .. err, 4) end

                Library:Notify(string.format('Created %q', name), 3)
                Refresh(name)
            end,
        })

        section:AddDivider()

        --// Autoload and autosave \\--
        section:AddButton({
            Text = 'Set autoload',
            Func = function()
                local name = Selected()
                if not name then return Library:Notify('Pick a config first', 3) end

                local ok, err = self:SaveAutoloadConfig(name)
                if not ok then return Library:Notify('Failed: ' .. err, 4) end

                Library:Notify(string.format('%q will load on start', name), 3)
                self.AutoloadConfigLabel:SetText('Autoload: ' .. name)
            end,
        }):AddButton({
            Text = 'Clear autoload',
            Func = function()
                local ok, err = self:DeleteAutoLoadConfig()
                if not ok then return Library:Notify('Failed: ' .. err, 4) end

                Library:Notify('Autoload cleared', 3)
                self.AutoloadConfigLabel:SetText('Autoload: none')
            end,
        })

        section:AddToggle('SaveManager_AutoSave', {
            Text = 'Autosave',
            Tooltip = 'Writes changes to the active config a couple of seconds after you make them',
            Default = false,
            Callback = function(Value)
                self.AutoSave = Value

                if Value and self.Dirty and self.ActiveConfig then
                    self:Save(self.ActiveConfig)
                end
            end,
        })

        self:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName', 'SaveManager_AutoSave' })
        self:RefreshStatus()

        -- hook this last so every element built before it is covered
        task.defer(function()
            self:WatchChanges()
        end)
    end

    SaveManager:BuildFolderTree()
end

return SaveManager
