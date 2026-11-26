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

    local function Tween(Instance, Properties, Time, Style)
        TweenService:Create(
            Instance,
            TweenInfo.new(Time or 0.2, Style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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
        local Size = Info.Size or UDim2.fromOffset(360, 180)

        local Prompt = {
            Done = false,
            Success = false,
            Attempts = 0,
            MaxAttempts = Info.MaxAttempts or 0, -- 0 = unlimited
        }

        --// Shell \\--
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

        Library:MakeDraggable(Outer, 40)

        local Inner = Library:Create("Frame", {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            ClipsDescendants = true;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 111;
            Parent = Outer;
        })

        Library:AddToRegistry(Inner, { BackgroundColor3 = "MainColor"; })

        if Library.RegisterCorner then
            Library:RegisterCorner(Outer)
            Library:RegisterCorner(Inner)
            Library:RegisterStroke(Inner, "AccentColor")
        end

        local Strip = Library:Create("Frame", {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 116;
            Parent = Inner;
        })

        Library:AddToRegistry(Strip, { BackgroundColor3 = "AccentColor"; })

        Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 12, 0, 12);
            Size = UDim2.new(1, -24, 0, 20);
            Text = Info.Title or "Key system";
            TextSize = 17;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 112;
            Parent = Inner;
        })

        Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 12, 0, 34);
            Size = UDim2.new(1, -24, 0, 16);
            Text = Info.Note or "Paste your key below.";
            TextSize = 14;
            TextTransparency = 0.4;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 112;
            Parent = Inner;
        })

        --// Input \\--
        local BoxOuter = Library:Create("Frame", {
            BackgroundColor3 = Library.BackgroundColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 12, 0, 60);
            Size = UDim2.new(1, -24, 0, 26);
            ZIndex = 112;
            Parent = Inner;
        })

        Library:AddToRegistry(BoxOuter, { BackgroundColor3 = "BackgroundColor"; })

        local BoxStroke = Library:RegisterStroke(BoxOuter, "OutlineColor")

        if Library.RegisterCorner then
            Library:RegisterCorner(BoxOuter, 0.8)
        end

        local KeyBox = Library:Create("TextBox", {
            BackgroundTransparency = 1;
            ClearTextOnFocus = false;
            Position = UDim2.new(0, 10, 0, 0);
            Size = UDim2.new(1, -20, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(140, 140, 140);
            PlaceholderText = Info.Placeholder or "Key";
            Text = "";
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 114;
            Parent = BoxOuter;
        })

        Library:ApplyTextStroke(KeyBox)
        Library:AddToRegistry(KeyBox, {
            TextColor3 = "FontColor";
            Font = "Font";
        })

        KeyBox.Focused:Connect(function()
            Tween(BoxStroke, { Color = Library.AccentColor })
        end)

        KeyBox.FocusLost:Connect(function(Enter)
            Tween(BoxStroke, { Color = Library.OutlineColor })
            if Enter then Prompt:Submit() end
        end)

        table.insert(Library.DragBlockers, BoxOuter)

        --// Status line \\--
        local StatusLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 12, 0, 92);
            Size = UDim2.new(1, -24, 0, 16);
            Text = "";
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 112;
            Parent = Inner;
        })

        local function SetStatus(Text, Colour)
            StatusLabel.Text = tostring(Text or "")
            Colour = Colour or "FontColor"

            Tween(StatusLabel, { TextColor3 = Library[Colour] or Library.FontColor })

            if Library.RegistryMap[StatusLabel] then
                Library.RegistryMap[StatusLabel].Properties.TextColor3 = Colour
            end
        end

        -- a small nudge reads as "wrong" faster than any sentence
        local function Shake()
            local Base = Outer.Position

            for Index, Offset in next, { 8, -7, 5, -3, 0 } do
                task.delay(Index * 0.045, function()
                    if Prompt.Done then return end
                    Outer.Position = Base + UDim2.fromOffset(Offset, 0)
                end)
            end
        end

        --// Buttons: flat, like the tab row \\--
        local ButtonRow = Library:Create("Frame", {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 12, 1, -42);
            Size = UDim2.new(1, -24, 0, 30);
            ZIndex = 112;
            Parent = Inner;
        })

        Library:Create("UIListLayout", {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ButtonRow;
        })

        local ButtonCount = 0

        local function AddButton(Text, Primary, Callback)
            ButtonCount = ButtonCount + 1

            local Button = Library:Create("Frame", {
                BackgroundColor3 = Primary and Library.AccentColor or Library.BackgroundColor;
                BackgroundTransparency = Primary and 0 or 1;
                BorderSizePixel = 0;
                LayoutOrder = ButtonCount;
                Size = UDim2.new(0, 90, 1, -6);
                ZIndex = 113;
                Parent = ButtonRow;
            })

            Library:AddToRegistry(Button, {
                BackgroundColor3 = Primary and "AccentColor" or "BackgroundColor";
            })

            local Stroke = Library:RegisterStroke(Button, Primary and "AccentColor" or "OutlineColor")

            if Library.RegisterCorner then
                Library:RegisterCorner(Button, 0.8)
            end

            local Label = Library:CreateLabel({
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(1, 1);
                Text = Text;
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Center;
                ZIndex = 114;
                Parent = Button;
            })

            local Region = Library:Create("TextButton", {
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(1, 1);
                Text = "";
                ZIndex = 115;
                Parent = Button;
            })

            if not Primary then
                Region.MouseEnter:Connect(function()
                    Tween(Stroke, { Color = Library.AccentColor })
                    Tween(Label, { TextColor3 = Library.AccentColor })
                end)

                Region.MouseLeave:Connect(function()
                    Tween(Stroke, { Color = Library.OutlineColor })
                    Tween(Label, { TextColor3 = Library.FontColor })
                end)
            end

            Region.MouseButton1Click:Connect(function()
                Library:SafeCallback(Callback)
            end)

            return Button
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
            Shake()

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
        table.insert(Buttons, AddButton("Check", true, function() Prompt:Submit() end))

        if Info.GetKeyLink then
            table.insert(Buttons, AddButton(Info.GetKeyText or "Get key", false, function()
                pcall(setclipboard, Info.GetKeyLink)
                SetStatus("Link copied to clipboard", "AccentColor")
            end))
        end

        table.insert(Buttons, AddButton("Close", false, function() Prompt:Cancel() end))

        -- split the row evenly between however many buttons we ended up with
        local Width = 1 / #Buttons
        for _, Button in next, Buttons do
            Button.Size = UDim2.new(Width, -8 * (#Buttons - 1) / #Buttons, 1, -6)
        end

        --// Open animation \\--
        local Scale = Library:Create("UIScale", { Scale = 0.94, Parent = Outer })
        Tween(Scale, { Scale = 1 }, 0.22, Enum.EasingStyle.Back)

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
