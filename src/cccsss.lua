require("vinv")
require("utils")
require("ui")
require("storage")

local monitor = peripheral.find("monitor")
monitor.clear()
monitor.setCursorPos(1,1)



term.clear()
term.setCursorPos(3,3)

local v1 = vinv.new("minecraft:barrel_15");
local v2 = vinv.new("create:item_vault_2");

local store = storage.new(v1, v2)

local categories = {
    wood = {
        oak = {},
        birch  = {
            planks = {},
            logs = {}
        },
    },
    stone = {},
    tools = {
        pickaxes = {},
        axes = {},
        shovels = {},
    },
}

local addCategories

local category_index = {
    ["minecraft:stone"] = "/stone",
    ["minecraft:cobblestone"] = "/stone",
    ["minecraft:oak_planks"] = "/wood/oak",
    ["minecraft:birch_planks"] = "/wood/birch",
    ["minecraft:spruce_planks"] = "/wood/spruce",
}


local categories_window do
    local sel_buttons = {}
    local desel_color = colors.black
    local sel_color = colors.green
    local width = 10
    local y = 1
    local x = 1

    function desel_button(button)
        button.bg_color = desel_color
        for i=#sel_buttons,1,-1 do
            local stop = false
            if sel_buttons[i] == button then stop = true end
            sel_buttons[i].opened_list.delete()
            sel_buttons[i].opened_list = nil
            table.remove(sel_buttons,i)
            if stop then break end
        end
        categories_window.propagate("draw")
    end

    function sel_button(button, subcategories)
        button.bg_color = sel_color

        table.insert(sel_buttons,button)

        button.opened_list = category_list(subcategories, button.level+1)

        categories_window.addChild(button.opened_list)
        categories_window.propagate("draw")
    end

    function new_button(name, subcategories, level)
        --self here isn't really self. it just felt right.
        local self = ui.button {}
        self.bg_color = desel_color
        self.width = width
        self.label = name
        self.level = level

        self.action1 = function()
            local deselected = false
            if not self.opened_list then deselected = true end

            for _, b in ipairs(sel_buttons) do
                if b.level == self.level then desel_button(b) end
            end

            if deselected then
                 sel_button(self, subcategories)
            end
        end
        return self
    end

    function category_list(cats, level)
        local children = {}
        for name, subcategories in pairs(cats) do
            table.insert(children, new_button(name, subcategories, level))
        end
        local add_new = ui.button {
            width = width,
            label = "Add New",
            text_color = colors.white,
            bg_color = colors.gray
        }
        add_new.action1 = function()
            local popup = ui.win { x = 15, y = 8, width = 20, height = 2, clear_color = colors.gray}
            local exit_button = ui.button { x = 34, y = 8, label = "X", bg_color = colors.gray,
                action1 = function()
                    popup.delete()
                    categories_window.propagate("draw")
                end
            }
            local text_box = ui.text_box { x = 15, y = 9, width = 20, bg_color = colors.black }
            text_box.onEnter = function(read_str)
                add_new.parent.addChild(new_button(read_str, {}, level), #children)
                popup.delete()
                categories_window.propagate("draw")
            end

            popup.addChild(exit_button)
            popup.addChild(text_box)

            categories_window.addChild(popup)
            categories_window.propagate("draw")
            popup.write("Enter Name:")
        end
        table.insert(children, add_new)
        local list = ui.list { x = x + level * width - width, y = 1, width = width, height = 17, clear_color = colors.red, children = children }
        return list
    end

    categories_window = ui.win {
        width = 50,
        height = 18,
        clear_color = colors.blue,
        children = {
            category_list(categories, 1)
        }
    }
end

interface = ui.new {
    categories_window
}

categories_window.propagate("draw")
--term.clear()
--textutils.pagedPrint(ttstring(categories_window))
--monitor.write(ttstring(categories_window))
--nwrite(monitor,ttstring(categories_window))

--monitor.write(textutils.serialize(categories_window))

interface.start()

