    Library.CreateSettingsPage = function(self, Window, KeybindList)
        local Page = Window:Page({Name = "Settings", Icon = "122669828593160"})
        local IsLoadingAutoConfig = false

        if Window.Items and Window.Items["SettingsButton"] then
            Window.Items["SettingsButton"]:Connect("MouseButton1Down", function()
                for _, ExistingPage in Window.Pages do
                    ExistingPage:Turn(ExistingPage == Page)
                end
            end)
        end

        local ThemeSection = Page:Section({Name = "Theme", Side = 1}) do
            local IsApplyingPreset = false
            local IsInitializingTheme = true
            local ThemePickers = { }
            local ThemeColorNames = {
                "Accent",
                "AccentGradient",
                "Background",
                "Background 2",
                "Text",
                "Outline",
                "Section Top",
                "Section Background",
                "Section Background 2",
                "Element"
            }
            local ThemePresetDropdown

            ThemePresetDropdown = ThemeSection:Dropdown({
                Name = "Theme preset",
                Flag = "ThemePreset",
                Default = "Preset",
                Items = {
                    "Preset", "Ocean", "Forest", "Rose", "Light",
                    "Midnight", "Ember", "Mint", "Crimson", "Contrast",
                    "Graphite", "Arctic", "Lavender", "Coral", "Jade",
                    "Cobalt", "Solar", "Plum", "Aqua", "Cherry",
                    "Olive", "Sakura", "Sandstone", "Monochrome", "Ice",
                    "Tangerine", "Violet", "Lagoon", "Ruby", "Paper", "Custom"
                },
                Callback = function(Value)
                    local Preset = Themes[Value]

                    if not Preset then
                        return
                    end

                    IsApplyingPreset = true
                    for _, ThemeName in ThemeColorNames do
                        local Color = Preset[ThemeName]
                        if Color then
                            Library:ChangeTheme(ThemeName, Color)
                            if ThemePickers[ThemeName] then
                                ThemePickers[ThemeName]:Set(Color)
                            end
                        end
                    end
                    IsApplyingPreset = false
                end
            })

            for _, ThemeName in ThemeColorNames do
                local ColorName = ThemeName
                ThemePickers[ColorName] = ThemeSection:Label(ColorName):Colorpicker({
                    Flag = "ThemeColor_" .. StringGSub(ColorName, "%s+", ""),
                    Default = Library.Theme[ColorName],
                    Callback = function(Color)
                        Library:ChangeTheme(ColorName, Color)
                        if not IsApplyingPreset and not IsInitializingTheme then
                            ThemePresetDropdown:Set("Custom")
                        end
                    end
                })
            end

            IsInitializingTheme = false
        end

        local InterfaceSection = Page:Section({Name = "Interface", Side = 1}) do
            InterfaceSection:Dropdown({
                Name = "Font",
                Flag = "FontStyle",
                Default = "Itim",
                Items = {"Itim", "Winky Rough", "Archivo Black", "IBM Plex Sans", "Light", "Regular", "SemiBold"},
                Callback = function(Value)
                    local FontData = Library.Fonts[Value]

                    if FontData then
                        Library.Font = FontData
                        Library.TitleFont = Font.new(FontData.Family, Enum.FontWeight.Bold, FontData.Style)
                        Library:UpdateText()
                    end
                end
            })

            InterfaceSection:Slider({
                Name = "Background Transparency",
                Default = 0.12,
                Decimals = 0.01,
                Max = 1,
                Min = 0,
                Suffix = "%",
                Flag = "BackgroundTransparency",
                Callback = function(Value)
                    Window:SetTransparency(Value)
                end
            })

            InterfaceSection:Keybind({
                Name = "Menu Keybind",
                Flag = "MenuBind",
                Default = Enum.KeyCode.Z,
                Callback = function(Value)
                    if not IsLoadingAutoConfig then
                        Window:SetOpen(Value)
                    end
                end
            })
        end

        local ConfigsSection = Page:Section({Name = "Configs", Side = 2}) do 
            local ConfigName
            local ConfigSelected
            local AutoConfigFileName = LocalPlayer.Name .. ".json"

            local ConfigsDropdown = ConfigsSection:Listbox({
                Flag = "ConfigsList", 
                Items = { }, 
                Multi = false,
                Callback = function(Value)
                    ConfigSelected = Value
                end
            })

            ConfigsSection:Label("Auto-save: " .. LocalPlayer.Name)
            
            ConfigsSection:Textbox({
                Flag = "ConfigsName",
                Placeholder = "Name",
                Numeric = false,
                Finished = false,
                Callback = function(Value)
                    ConfigName = Value
                end
            })

            ConfigsSection:Button({
                Name = "Create",
                Callback = function()
                    if ConfigName and ConfigName ~= "" then
                        if not isfile(Library.Folders.Configs .. "/" .. ConfigName .. ".json") then
                            writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())
                            Library:RefreshConfigsList(ConfigsDropdown)
                        end
                    end
                end
            })

            ConfigsSection:Button({
                Name = "Delete",
                Callback = function()
                    if ConfigSelected then
                        Library:DeleteConfig(ConfigSelected)
                        Library:RefreshConfigsList(ConfigsDropdown)
                    end
                end
            })

            ConfigsSection:Button({
                Name = "Load",
                Callback = function()
                    if ConfigSelected then
                        Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. ConfigSelected))
                    end
                end
            })

            ConfigsSection:Button({
                Name = "Save",
                Callback = function()
                    if ConfigSelected then
                        writefile(Library.Folders.Configs .. "/" .. ConfigSelected, Library:GetConfig())
                    end
                end
            })

            ConfigsSection:Button({
                Name = "Refresh",
                Callback = function()
                    Library:RefreshConfigsList(ConfigsDropdown)
                end
            })

            Library.StartAutoConfig = function()
                local AutoConfigPath = Library.Folders.Configs .. "/" .. AutoConfigFileName
                local LastAutoConfig

                if isfile(AutoConfigPath) then
                    local ReadSuccess, SavedConfig = pcall(readfile, AutoConfigPath)
                    if ReadSuccess then
                        LastAutoConfig = SavedConfig
                        IsLoadingAutoConfig = true
                        pcall(function()
                            Library:LoadConfig(SavedConfig)
                        end)
                        IsLoadingAutoConfig = false
                    end
                end

                local function SaveAutoConfig()
                    if not Library then
                        return
                    end

                    local CurrentConfig = Library:GetConfig()
                    if CurrentConfig == LastAutoConfig then
                        return
                    end

                    local WriteSuccess = pcall(writefile, AutoConfigPath, CurrentConfig)
                    if WriteSuccess then
                        LastAutoConfig = CurrentConfig
                        Library:RefreshConfigsList(ConfigsDropdown)
                    end
                end

                SaveAutoConfig()
                Library:RefreshConfigsList(ConfigsDropdown)

                task.spawn(function()
                    while Library and task.wait(1) and not Library.Destroyed do
                        SaveAutoConfig()
                    end
                end)
            end
        end

        return Page
    end
end



