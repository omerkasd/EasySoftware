local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local LoadingUI = {} do
    LoadingUI.Library = nil

    function LoadingUI:SetLibrary(library)
        self.Library = library
    end

    local function Tween(Instance, Properties, Time, Style)
        local Info = TweenInfo.new(
            Time or 0.2,
            Style or Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )

        local Object = TweenService:Create(Instance, Info, Properties)
        Object:Play()
        return Object
    end

    function LoadingUI:Create(Info)
        assert(self.Library, "LoadingUI:Create -> Must set LoadingUI.Library first!")

        Info = Info or {}

        local Library = self.Library
        local Steps = Info.Steps or {}
        local Size = Info.Size or UDim2.fromOffset(380, 104)

        local Loader = {
            Steps = Steps,
            StepIndex = 0,
            Progress = 0,
            Finished = false,
        }

        --// Shell \\--
        local Outer = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderSizePixel = 0;
            Position = Info.Position or UDim2.fromScale(0.5, 0.5);
            Size = Size;
            ZIndex = 100;
            Name = "LoadingUI";
            Parent = Library.ScreenGui;
        })

        Library:MakeDraggable(Outer, Size.Y.Offset)

        local Inner = Library:Create("Frame", {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            ClipsDescendants = true;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 101;
            Parent = Outer;
        })

        Library:AddToRegistry(Inner, { BackgroundColor3 = "MainColor"; })

        if Library.RegisterCorner then
            Library:RegisterCorner(Outer)
            Library:RegisterCorner(Inner)
            Library:RegisterStroke(Inner, "AccentColor")
        end

        -- the accent strip every groupbox wears
        local Strip = Library:Create("Frame", {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 105;
            Parent = Inner;
        })

        Library:AddToRegistry(Strip, { BackgroundColor3 = "AccentColor"; })

        --// Text \\--
        local TitleLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 12, 0, 12);
            Size = UDim2.new(1, -24, 0, 20);
            Text = Info.Title or "Loading";
            TextSize = 17;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 102;
            Parent = Inner;
        })

        local StatusLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 12, 0, 34);
            Size = UDim2.new(1, -70, 0, 16);
            Text = Info.Subtitle or (Steps[1] or "Please wait...");
            TextSize = 14;
            TextTransparency = 0.4;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 102;
            Parent = Inner;
        })

        local PercentLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -56, 0, 34);
            Size = UDim2.new(0, 44, 0, 16);
            Text = "0%";
            TextSize = 14;
            TextTransparency = 0.4;
            TextXAlignment = Enum.TextXAlignment.Right;
            ZIndex = 102;
            Parent = Inner;
        })

        --// Progress bar \\--
        local BarOuter = Library:Create("Frame", {
            BackgroundColor3 = Library.BackgroundColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 12, 1, -30);
            Size = UDim2.new(1, -24, 0, 8);
            ZIndex = 102;
            Parent = Inner;
        })

        Library:AddToRegistry(BarOuter, { BackgroundColor3 = "BackgroundColor"; })

        local BarFill = Library:Create("Frame", {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            ClipsDescendants = true;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 103;
            Parent = BarOuter;
        })

        Library:AddToRegistry(BarFill, { BackgroundColor3 = "AccentColor"; })

        if Library.RegisterCorner then
            Library:RegisterCorner(BarOuter, 0.8)
            Library:RegisterCorner(BarFill, 0.8)
            Library:RegisterStroke(BarOuter, "OutlineColor")
        end

        -- a slow sheen so the bar does not look frozen while a step takes a while
        local Sheen = Library:Create("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BackgroundTransparency = 0.75;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 40, 1, 0);
            Position = UDim2.new(0, -40, 0, 0);
            ZIndex = 104;
            Parent = BarFill;
        })

        Library:Create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1, 1),
            });
            Parent = Sheen;
        })

        task.spawn(function()
            while not Loader.Finished and Sheen.Parent do
                Sheen.Position = UDim2.new(0, -40, 0, 0)
                Tween(Sheen, { Position = UDim2.new(1, 0, 0, 0) }, 1.1, Enum.EasingStyle.Linear)
                task.wait(1.6)
            end
        end)

        --// Step dots \\--
        local Dots = {}

        if #Steps > 1 then
            local DotRow = Library:Create("Frame", {
                AnchorPoint = Vector2.new(1, 0);
                BackgroundTransparency = 1;
                Position = UDim2.new(1, -12, 0, 14);
                Size = UDim2.new(0, #Steps * 10, 0, 8);
                ZIndex = 102;
                Parent = Inner;
            })

            Library:Create("UIListLayout", {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = DotRow;
            })

            for Index = 1, #Steps do
                local Dot = Library:Create("Frame", {
                    BackgroundColor3 = Library.OutlineColor;
                    BorderSizePixel = 0;
                    LayoutOrder = Index;
                    Size = UDim2.new(0, 6, 0, 6);
                    ZIndex = 103;
                    Parent = DotRow;
                })

                Library:AddToRegistry(Dot, { BackgroundColor3 = "OutlineColor"; })

                if Library.RegisterCorner then
                    Library:RegisterCorner(Dot, 0.6)
                end

                Dots[Index] = Dot
            end
        end

        local function PaintDots()
            for Index, Dot in next, Dots do
                local Done = Index <= Loader.StepIndex
                local Key = Done and "AccentColor" or "OutlineColor"

                Tween(Dot, { BackgroundColor3 = Library[Key] }, 0.2)

                if Library.RegistryMap[Dot] then
                    Library.RegistryMap[Dot].Properties.BackgroundColor3 = Key
                end
            end
        end

        --// Open animation \\--
        local Scale = Library:Create("UIScale", { Scale = 0.94, Parent = Outer })
        Tween(Scale, { Scale = 1 }, 0.22, Enum.EasingStyle.Back)

        --// API \\--

        -- Progress is 0 to 1. Never goes backwards unless Force is true.
        function Loader:SetProgress(Value, Force)
            if Loader.Finished then return end

            Value = math.clamp(tonumber(Value) or 0, 0, 1)
            if not Force and Value < Loader.Progress then return end

            Loader.Progress = Value

            Tween(BarFill, { Size = UDim2.new(Value, 0, 1, 0) }, 0.3)
            PercentLabel.Text = string.format("%d%%", math.floor(Value * 100 + 0.5))
        end

        function Loader:SetStatus(Text)
            if Loader.Finished then return end
            StatusLabel.Text = tostring(Text)
        end

        function Loader:SetTitle(Text)
            TitleLabel.Text = tostring(Text)
        end

        -- Advances to the next entry in Steps and moves the bar with it.
        function Loader:NextStep(Text)
            if Loader.Finished then return end

            Loader.StepIndex = Loader.StepIndex + 1

            local Label = Text or Steps[Loader.StepIndex]
            if Label then Loader:SetStatus(Label) end

            local Total = math.max(#Steps, Loader.StepIndex)
            Loader:SetProgress(Loader.StepIndex / Total)
            PaintDots()
        end

        function Loader:Destroy()
            Loader.Finished = true
            Outer:Destroy()
        end

        -- Fills the bar, holds for a moment, then fades out and destroys itself.
        -- Yields. Pass Callback to run something after it is gone.
        function Loader:Finish(Callback)
            if Loader.Finished then return end

            Loader.StepIndex = #Steps
            Loader:SetProgress(1, true)
            Loader:SetStatus(Info.FinishText or "Done")
            PaintDots()

            task.wait(Info.FinishDelay or 0.45)
            Loader.Finished = true

            local Time = Info.FadeTime or 0.3

            for _, Object in next, Outer:GetDescendants() do
                if Object:IsA("TextLabel") or Object:IsA("TextButton") then
                    Tween(Object, { TextTransparency = 1, TextStrokeTransparency = 1 }, Time)
                elseif Object:IsA("UIStroke") then
                    Tween(Object, { Transparency = 1 }, Time)
                end

                if Object:IsA("GuiObject") and Object.BackgroundTransparency < 1 then
                    Tween(Object, { BackgroundTransparency = 1 }, Time)
                end
            end

            Tween(Outer, { BackgroundTransparency = 1 }, Time)
            Tween(Scale, { Scale = 0.96 }, Time)

            task.wait(Time)
            Outer:Destroy()

            if typeof(Callback) == "function" then
                Library:SafeCallback(Callback)
            end
        end

        Loader.Outer = Outer
        Loader.Inner = Inner

        if Info.Progress then
            Loader:SetProgress(Info.Progress)
        end

        return Loader
    end
end

return LoadingUI
