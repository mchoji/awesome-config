-----------------------------------------------------------------------------------------------------------------------
--                                                Rules config                                                       --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful =require("awful")
local beautiful = require("beautiful")
local redtitle = require("redflat.titlebar")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local rules = {}

rules.base_properties = {
	border_width     = beautiful.border_width,
	border_color     = beautiful.border_normal,
	focus            = awful.client.focus.filter,
	raise            = true,
	size_hints_honor = false,
	screen           = awful.screen.preferred,
}

rules.floating_any = {
	class = {
		"Clipflap", "Run.py",
	},
	role = { "AlarmWindow", "pop-up", },
	type = { "dialog" }
}

rules.titlebar_exeptions = {
	class = { "Cavalcade", "Clipflap", "Steam", "Qemu-system-x86_64" }
}

rules.maximized = {
	class = { "Emacs24" }
}

-- Build rule table
-----------------------------------------------------------------------------------------------------------------------
function rules:init(args)

	args = args or {}
	self.base_properties.keys = args.hotkeys.keys.client
	self.base_properties.buttons = args.hotkeys.mouse.client
	self.env = args.env or {}


	-- Build rules
	--------------------------------------------------------------------------------
	self.rules = {
		{
			rule       = {},
			properties = args.base_properties or self.base_properties
		},
		{
			rule_any   = args.floating_any or self.floating_any,
			properties = { floating = true }
		},
		{
			rule_any   = self.maximized,
			callback   = function(c)
				c.maximized = true
				redtitle.cut_all({ c })
				c.height = c.screen.workarea.height - 2 * c.border_width
			end
		},
		{
			rule_any   = { type = { "normal", "dialog" }},
			except_any = self.titlebar_exeptions,
			properties = { titlebars_enabled = true }
		},
		{
			rule_any   = { type = { "normal" }},
			properties = { placement = awful.placement.no_overlap + awful.placement.no_offscreen }
		},
        {
            rule       = { type = "dialog" },
            properties = { size_hints_honor = true },
            callback   = awful.placement.centered
        },

		-- Tags placement
		{
			rule       = { instance = "Xephyr" },
			properties = { tag = self.env.theme == "bankai" and "Test" or "Free", fullscreen = true }
		},
        -- Sublime Text
        {
            rule       = { class = "Sublime_text" },
            properties = { tag = "Edit", switchtotag = true }
        },
        -- Spotify
        {
            rule       = { name = "[sS]potify" },
            properties = { tag = self.env.theme == "bankai" and "Back" or "Free", 
                           fullscreen = false }
        },
        -- KeePass
        {
            rule       = { class = "keepassxc" },
            properties = { tag = self.env.theme == "bankai" and "Back" or "Free" }
        },
        -- Evince
        {
            rule       = { class = "Evince" },
            properties = { tag = "Read", switchtotag = true }
        },
        -- VS Code
        {
            rule       = { class = "code-oss" },
            properties = { tag = self.env.theme == "bankai" and "Code" or "Edit",
                           maximized = true, switchtotag = true }
        },
        -- Spyder
        {
            rule       = { class = "Spyder" },
            properties = { tag = self.env.theme == "bankai" and "Code" or "Edit",
                           maximized = true, switchtotag = true }
        },
        -- JabRef
        {
            rule       = { class = "org-jabref-JabRefMain" },
            properties = { tag = self.env.theme == "bankai" and "Misc" or "Free" }
        },
        -- Libreoffice
        {   
            rule_any   = { class = { "libreoffice-startcenter",
                                   "libreoffice-writer",
                                   "libreoffice-calc",
                                   "libreoffice-impress",
                                   "libreoffice-base",
                                   "libreoffice-math",
                                   "VCLSalFrame.DocumentWindow" }},
            properties = { tag = self.env.theme == "bankai" and "Misc" or "Edit" }
        },
        -- WPS Office
        {
            rule_any   = { class = { "Wps", "Wpp", "Et" }},
            properties = { tag = self.env.theme == "bankai" and "Misc" or "Full",
                           switchtotag = true, maximized = true }
        },
        -- Wireshark
        {
            rule       = { class = "Wireshark" },
            properties = { tag = self.env.theme == "bankai" and "Data" or "Free",
                           switchtotag = true }
        },
        -- File management
        {
            rule_any   = { class = { "Nautilus", "Thunar", "Nemo" } },
            properties = { tag = self.env.theme == "bankai" and "Nav" or "Main",
                           switchtotag = true } 
        },
        -- Thunderbird
        {
            rule       = { class = "Thunderbird" },
            properties = { tag = self.env.theme == "bankai" and "Spare" or "Full" }
        },
        -- Video players
        {
            rule_any   = { class = { "vlc", "mpv" }},
            properties = { tag = "Full", switchtotag = true }
        },
        {
            rule       = { class = "vlc", name = "VLSub.*" },
            properties = { tag = "Full", floating = true, 
                           size_hints_honor = true }
        },
        -- Jetbrains
        {
            rule       = { class = "jetbrains-%w+", type = "normal" },
            except     = { class = "jetbrains-toolbox" },
            properties = { tag = self.env.theme == "bankai" and "Code" or "Full",
                           switchtotag = true }
        },
        --{
        --    rule       = { class = "jetbrains-toolbox" },
        --    properties = { size_hints_honor = true,
        --                    type = "menu" }
        --},
		-- Jetbrains dirty focus trick assuming separate tag used for IDE
		{
			rule       = { class = "jetbrains-%w+", type = "normal" },
            except     = { class = "jetbrains-toolbox" },
			callback = function(jetbrain)
				local initial_tag = jetbrain.first_tag -- remember tag for unmanaged
				jetbrain:connect_signal("focus", function(c)
					for _, win in ipairs(c.first_tag:clients()) do
						if win.name ~= c.name and win.type == "normal" then win.minimized = true end
					end
				end)
				jetbrain:connect_signal("unmanage", function(c)
					for _, win in ipairs(initial_tag:clients()) do
						if win.name ~= c.name and win.type == "normal" then
							win.minimized = false
							client.focus = win
							win:raise()
							return
						end
					end
				end)
			end
		}
	}


	-- Set rules
	--------------------------------------------------------------------------------
	awful.rules.rules = rules.rules
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return rules
