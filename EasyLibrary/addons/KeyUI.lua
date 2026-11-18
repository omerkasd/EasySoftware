local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local setclipboard = (setclipboard or toclipboard or set_clipboard or function() end)
local isfile, readfile, writefile, makefolder, isfolder = isfile, readfile, writefile, makefolder, isfolder

local KeyUI = {} do
    KeyUI.Library = nil

    function KeyUI:SetLibrary(library)
        self.Library = library
    end

    local function Tween(Instance, Properties, Time)
        TweenService:Create(
            Instance,
            TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            Properties
        ):Play()
    end

    local function SafeFile(Func, ...)
        local Ok, Result = pcall(Func, ...)
        if Ok then return Result end
        return nil
    end

    --// Create the key window. Returns a Prompt object; see KeyUI:Prompt below.
    function KeyUI:Create(Info)
        assert(self.Library, "KeyUI:Create -> Must set KeyUI.Library first!")

        Info = Info or {}

        local Library = self.Library
        local Size = Info.Size or UDim2.fromOffset(340, 172)

        local Prompt = {
            Done = false,
            Success = false,
            Attempts = 0,
            MaxAttempts = Info.MaxAttempts or 0, -- 0 = unlimited
        }

        --// Frames \\--
        local Outer = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderSizePixel = 0;
            Position = Info.Position or UDim2.fromScale(0.5, 0.5);
            Size = Size;
            ZIndex = 110;
            Name = "KeyUI";
            Parent = Library.ScreenGui;
        })

        Library:MakeDraggable(Outer, 34)

        local Inner = Library:Create("Frame", {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 111;
            Parent = Outer;
        })

        Library:AddToRegistry(Inner, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "AccentColor";
        })

        Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 10, 0, 9);
            Size = UDim2.new(1, -20, 0, 18);
            Text = Info.Title or "Key system";
            TextSize = 16;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 112;
            Parent = Inner;
        })

        Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 10, 0, 29);
            Size = UDim2.new(1, -20, 0, 16);
            Text = Info.Note or "Paste your key below.";
            TextSize = 14;
            TextTransparency = 0.35;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 112;
            Parent = Inner;
        })

        --// Input \\--
        local BoxOuter = Library:Create("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 10, 0, 54);
            Size = UDim2.new(1, -20, 0, 22);
            ZIndex = 112;
            Parent = Inner;
        })

        local BoxInner = Library:Create("Frame", {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 113;
            Parent = BoxOuter;
        })

        Library:AddToRegistry(BoxInner, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "OutlineColor";
        })

        Library:OnHighlight(BoxOuter, BoxOuter,
            { BorderColor3 = "AccentColor" },
            { BorderColor3 = "Black" }
        )

        local KeyBox = Library:Create("TextBox", {
            BackgroundTransparency = 1;
            ClearTextOnFocus = false;
            Position = UDim2.new(0, 6, 0, 0);
            Size = UDim2.new(1, -12, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(150, 150, 150);
            PlaceholderText = Info.Placeholder or "Key";
            Text = "";
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 114;
            Parent = BoxInner;
        })

        Library:ApplyTextStroke(KeyBox)
        Library:AddToRegistry(KeyBox, {
            TextColor3 = "FontColor";
            Font = "Font";
        })

        table.insert(Library.DragBlockers, BoxOuter)

        --// Status line \\--
        local StatusLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 10, 0, 80);
            Size = UDim2.new(1, -20, 0, 16);
            Text = "";
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 112;
            Parent = Inner;
        })

        local function SetStatus(Text, Colour)
            StatusLabel.Text = tostring(Text or "")

            Library:RemoveFromRegistry(StatusLabel)
            StatusLabel.TextColor3 = Library[Colour] or Library.FontColor
            Library:AddToRegistry(StatusLabel, { TextColor3 = Colour or "FontColor", Font = "Font" })
        end

        --// Buttons \\--
        local ButtonRow = Library:Create("Frame", {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 10, 1, -40);
            Size = UDim2.new(1, -20, 0, 30);
            ZIndex = 112;
            Parent = Inner;
        })

        Library:Create("UIListLayout", {
            Padding = UDim.new(0, 6);
            FillDirection = Enum.FillDirection.Horizontal;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ButtonRow;
        })

        local ButtonCount = 0

        local function AddButton(Text, Callback)
            ButtonCount = ButtonCount + 1

            local ButtonOuter = Library:Create("Frame", {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 0, 1, 0);
                LayoutOrder = ButtonCount;
                ZIndex = 113;
                Parent = ButtonRow;
            })

            local ButtonInner = Library:Create("Frame", {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 114;
                Parent = ButtonOuter;
            })

            Library:AddToRegistry(ButtonInner, {
                BackgroundColor3 = "BackgroundColor";
                BorderColor3 = "OutlineColor";
            })

            Library:CreateLabel({
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Text = Text;
                TextSize = 14;
                ZIndex = 115;
                Parent = ButtonInner;
            })

            Library:OnHighlight(ButtonOuter, ButtonOuter,
                { BorderColor3 = "AccentColor" },
                { BorderColor3 = "Black" }
            )

            local Region = Library:Create("TextButton", {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Text = "";
                ZIndex = 116;
                Parent = ButtonInner;
            })

            Region.MouseButton1Click:Connect(function()
                Library:SafeCallback(Callback)
            end)

            return ButtonOuter
        end

        local Buttons = {}

        --// Validation \\--
        local function Validate(Key)
            Key = tostring(Key or "")

            if Key:gsub("%s", "") == "" then
                return false, "Enter a key first"
            end

            if typeof(Info.Validate) == "function" then
                local Ok, Result, Message = pcall(Info.Validate, Key)

                if not Ok then
                    return false, "Check failed, try again"
                end

                return Result and true or false, Message
            end

            local Keys = Info.Keys or (Info.Key and { Info.Key }) or {}

            for _, Valid in next, Keys do
                if Key == tostring(Valid) then
                    return true
                end
            end

            return false, "Invalid key"
        end

        local function Close()
            for Idx = #Library.DragBlockers, 1, -1 do
                if Library.DragBlockers[Idx] == BoxOuter then
                    table.remove(Library.DragBlockers, Idx)
                end
            end

            Outer:Destroy()
        end

        function Prompt:Submit(Key)
            if Prompt.Done then return end

            Key = Key or KeyBox.Text
            Prompt.Attempts = Prompt.Attempts + 1

            SetStatus("Checking...", "FontColor")

            local Ok, Message = Validate(Key)

            if Ok then
                SetStatus(Info.SuccessText or "Key accepted", "AccentColor")

                if Info.SaveKey then
                    local Path = Info.SaveFile or "EasyLibrary/key.txt"
                    local Folder = Path:match("^(.*)/[^/]+$")

                    if Folder and not SafeFile(isfolder, Folder) then
                        SafeFile(makefolder, Folder)
                    end

                    SafeFile(writefile, Path, Key)
                end

                Prompt.Key = Key
                Prompt.Success = true

                task.wait(0.4)
                Close()
                Prompt.Done = true

                if typeof(Info.OnSuccess) == "function" then
                    Library:SafeCallback(function() Info.OnSuccess(Key) end)
                end

                return true
            end

            SetStatus(Message or "Invalid key", "RiskColor")

            if Prompt.MaxAttempts > 0 and Prompt.Attempts >= Prompt.MaxAttempts then
                SetStatus("Too many attempts", "RiskColor")
                task.wait(1)
                Prompt:Cancel()
            end

            return false
        end

        function Prompt:Cancel()
            if Prompt.Done then return end

            Prompt.Success = false
            Close()
            Prompt.Done = true

            if typeof(Info.OnFail) == "function" then
                Library:SafeCallback(Info.OnFail)
            end
        end

        -- Yields until the key is accepted or the window is closed.
        function Prompt:Wait()
            while not Prompt.Done do
                task.wait()
            end

            return Prompt.Success, Prompt.Key
        end

        --// Wire up \\--
        table.insert(Buttons, AddButton("Check", function() Prompt:Submit() end))

        if Info.GetKeyLink then
            table.insert(Buttons, AddButton(Info.GetKeyText or "Get key", function()
                pcall(setclipboard, Info.GetKeyLink)
                SetStatus("Link copied to clipboard", "AccentColor")
            end))
        end

        table.insert(Buttons, AddButton("Close", function() Prompt:Cancel() end))

        -- split the row evenly between however many buttons we ended up with
        local Width = 1 / #Buttons
        for _, Button in next, Buttons do
            Button.Size = UDim2.new(Width, -6 * (#Buttons - 1) / #Buttons, 1, 0)
        end

        KeyBox.FocusLost:Connect(function(Enter)
            if Enter then Prompt:Submit() end
        end)

        --// Saved key \\--
        if Info.SaveKey then
            local Path = Info.SaveFile or "EasyLibrary/key.txt"

            if SafeFile(isfile, Path) then
                local Saved = SafeFile(readfile, Path)

                if typeof(Saved) == "string" and Saved ~= "" then
                    KeyBox.Text = Saved
                    task.spawn(function() Prompt:Submit(Saved) end)
                end
            end
        end

        Prompt.Outer = Outer
        Prompt.KeyBox = KeyBox
        Prompt.SetStatus = function(_, Text, Colour) SetStatus(Text, Colour) end

        return Prompt
    end

    -- Convenience: create the window and yield until it is answered.
    -- Returns success (boolean) and the key that was accepted.
    function KeyUI:Prompt(Info)
        return self:Create(Info):Wait()
    end
end

return KeyUI
