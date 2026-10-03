    -- Custom font
    local CustomFont = { } do
        function CustomFont:New(Name, Weight, Style, Data)
            if not isfile(Data.Id) then 
                writefile(Data.Id, game:HttpGet(Data.Url))
            end

            local Data = {
                name = Name,
                faces = {
                    {
                        name = Name,
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(Data.Id)
                    }
                }
            }

            writefile(`{Library.Folders.Assets}/{Name}.font`, HttpService:JSONEncode(Data))
            return getcustomasset(`{Library.Folders.Assets}/{Name}.font`)
        end

        local ItimAsset = CustomFont:New("Itim", 400, "normal", {
            Id = `{Library.Folders.Assets}/Itim-Regular.ttf`,
            Url = "https://raw.githubusercontent.com/google/fonts/main/ofl/itim/Itim-Regular.ttf"
        })

        local Itim = Font.new(ItimAsset, Enum.FontWeight.Regular, Enum.FontStyle.Normal)

        local WinkyRoughAsset = CustomFont:New("Winky Rough", 400, "normal", {
            Id = `{Library.Folders.Assets}/WinkyRough.ttf`,
            Url = "https://raw.githubusercontent.com/google/fonts/main/ofl/winkyrough/WinkyRough%5Bwght%5D.ttf"
        })
        local WinkyRough = Font.new(WinkyRoughAsset, Enum.FontWeight.Regular, Enum.FontStyle.Normal)

        local ArchivoBlackAsset = CustomFont:New("Archivo Black", 400, "normal", {
            Id = `{Library.Folders.Assets}/ArchivoBlack-Regular.ttf`,
            Url = "https://raw.githubusercontent.com/google/fonts/main/ofl/archivoblack/ArchivoBlack-Regular.ttf"
        })
        local ArchivoBlack = Font.new(ArchivoBlackAsset, Enum.FontWeight.Regular, Enum.FontStyle.Normal)

        local IBMPlexSansAsset = CustomFont:New("IBM Plex Sans", 400, "normal", {
            Id = `{Library.Folders.Assets}/IBMPlexSans.ttf`,
            Url = "https://raw.githubusercontent.com/google/fonts/main/ofl/ibmplexsans/IBMPlexSans%5Bwdth%2Cwght%5D.ttf"
        })
        local IBMPlexSans = Font.new(IBMPlexSansAsset, Enum.FontWeight.Regular, Enum.FontStyle.Normal)

        local SemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        local Regular = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        local Light = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal)

        Library.Fonts = {
            ["Itim"] = Itim,
            ["Winky Rough"] = WinkyRough,
            ["Archivo Black"] = ArchivoBlack,
            ["IBM Plex Sans"] = IBMPlexSans,
            ["SemiBold"] = SemiBold,
            ["Regular"] = Regular,
            ["Light"] = Light
        }

        Library.Font = Itim
        Library.TitleFont = Font.new(ItimAsset, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        Library.TitleItems = { }
    end

