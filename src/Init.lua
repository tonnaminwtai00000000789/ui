-- src/Init.lua
-- Entry point: load Library และ expose เป็น WindUI-compatible interface

local Library = require("./modules/Library")

getgenv().Library = Library

return Library
