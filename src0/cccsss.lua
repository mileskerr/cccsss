require("ui")
require("storage")

function main()
    parallel.waitForAll(
        storage.filter_items,
        function() search(term.current()) end
    )
end

function search(win)
    local list_win, search_box = ui.split(win, -1, "v")
    ui.setColors(search_box, colors.white, colors.gray)
    ui.setColors(list_win, colors.light_gray)

    while true do
        local match_locs, match_names

        parallel.waitForAny(
            function()
                ui.text_input(search_box, "search_changed")
            end,
            function()
                while true do
                    local _, query = os.pullEvent("search_changed")
                    locs, names = storage.find_by_name(query)
                    ui.list(list_win, names, true)
                end
            end,
            function()
                os.pullEvent("mode_changed")
            end
        )

        list_win.clear()
        os.queueEvent("filter_changed", locs)
    end
end

--termw, termh = term.getSize()
--local main_win = window.create(term.current(), 1, 5, termw, termh-5)

main()
