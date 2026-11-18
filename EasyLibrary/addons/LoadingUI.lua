local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local LoadingUI = {} do
    LoadingUI.Library = nil

    function LoadingUI:SetLibrary(library)
        self.Library = library
    end

    local function Tween(Instance, Properties, Time)
        local Info = TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Object = TweenService:Create(Instance, Info, Properties)
        Object:Play()
        return Object
    end

    function LoadingUI:Create(Info)
        assert(self.Library, "LoadingUI:Create -> Must set LoadingUI.Library first!")

        Info = Info or {}

        local Library = self.Library
        local Steps = Info.Steps or {}
        local Size = Info.Size or UDim2.fromOffset(360, 94)

        local Loader = {
            Steps = Steps,
            StepIndex = 0,
            Progress = 0,
            Finished = false,
        }

        --// Frames \\--
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
            BorderColor3 = Library.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 101;
            Parent = Outer;
        })

        Library:AddToRegistry(Inner, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "AccentColor";
        })

        if Library.RegisterCorner then
            Library:RegisterCorner(Outer)
            Library:RegisterCorner(Inner)
            Library:RegisterStroke(Inner, "AccentColor")
        end

        --// Text \\--
        local TitleLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 10, 0, 10);
            Size = UDim2.new(1, -20, 0, 18);
            Text = Info.Title or "Loading";
            TextSize = 16;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 102;
            Parent = Inner;
        })

        local StatusLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 10, 0, 30);
            Size = UDim2.new(1, -60, 0, 16);
            Text = Info.Subtitle or (Steps[1] or "Please wait...");
            TextSize = 14;
            TextTransparency = 0.35;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 102;
            Parent = Inner;
        })

        local PercentLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -50, 0, 30);
            Size = UDim2.new(0, 40, 0, 16);
            Text = "0%";
            TextSize = 14;
            TextTransparency = 0.35;
            TextXAlignment = Enum.TextXAlignment.Right;
            ZIndex = 102;
            Parent = Inner;
        })

        --// Progress bar \\--
        local BarOuter = Library:Create("Frame", {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.new(0, 10, 1, -24);
            Size = UDim2.new(1, -20, 0, 12);
            ZIndex = 102;
            Parent = Inner;
        })

        Library:AddToRegistry(BarOuter, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        local BarFill = Library:Create("Frame", {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 103;
            Parent = BarOuter;
        })

        Library:AddToRegistry(BarFill, {
            BackgroundColor3 = "AccentColor";
        })

        if Library.RegisterCorner then
            Library:RegisterCorner(BarOuter, 0.5)
            Library:RegisterCorner(BarFill, 0.5)
            Library:RegisterStroke(BarOuter, "OutlineColor")
        end

        Library:Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 190, 190)),
            });
            Rotation = 90;
            Parent = BarFill;
        })

        --// API \\--

        -- Progress is 0 to 1. Never goes backwards unless Force is true.
        function Loader:SetProgress(Value, Force)
            if Loader.Finished then return end

            Value = math.clamp(tonumber(Value) or 0, 0, 1)
            if not Force and Value < Loader.Progress then return end

            Loader.Progress = Value

            Tween(BarFill, { Size = UDim2.new(Value, 0, 1, 0) }, 0.25)
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
        end

        function Loader:Destroy()
            Loader.Finished = true
            Outer:Destroy()
        end

        -- Fills the bar, holds for a moment, then fades out and destroys itself.
        -- Yields. Pass Callback to run something after it is gone.
        function Loader:Finish(Callback)
            if Loader.Finished then return end

            Loader:SetProgress(1, true)
            Loader:SetStatus(Info.FinishText or "Done")

            task.wait(Info.FinishDelay or 0.4)
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
