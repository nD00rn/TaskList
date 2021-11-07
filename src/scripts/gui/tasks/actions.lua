local edit_task_gui = require("scripts.gui.edit-task.index")
local task = require("scripts.task")
local util = require("scripts.util")

local actions = {}

local function toggle_fab(elem, sprite, state)
  if state then
    elem.style = "flib_selected_frame_action_button"
    elem.sprite = sprite .. "_black"
  else
    elem.style = "frame_action_button"
    elem.sprite = sprite .. "_white"
  end
end

--- @param Gui TasksGui
function actions.recenter(Gui)
  Gui.refs.window.force_auto_center()
end

--- @param Gui TasksGui
function actions.close(Gui)
  Gui:close()
end

--- @param Gui TasksGui
function actions.pin(Gui)
  Gui.state.pinned = not Gui.state.pinned

  toggle_fab(Gui.refs.pin_button, "flib_pin", Gui.state.pinned)

  if Gui.state.pinned then
    Gui.state.ignore_close = true
    Gui.player.opened = nil
  else
    Gui.player.opened = Gui.refs.window
    Gui.refs.window.force_auto_center()
  end
end

--- @param Gui TasksGui
function actions.edit_task(Gui, msg)
  if not util.get_gui(Gui.player.index, "edit_task") then
    local pinned = Gui.state.pinned
    if not pinned then
      Gui.state.ignore_close = true
    end
    local Task = msg.task_id and global.tasks[msg.task_id] or nil
    edit_task_gui.new(Gui.player, Gui.player_table, Gui, Task)
  end
end

-- TODO: Tasks will be deleted from their edit GUI
-- --- @param Gui TasksGui
-- --- @param msg table
-- function actions.delete_task(Gui, msg)
--   local task_id = msg.task_id

--   local task = global.tasks[task_id]
--   if task then
--     task:delete()
--   end
-- end

--- @param Gui TasksGui
--- @param msg table
--- @param e on_gui_checked_state_changed
function actions.toggle_task_completed(Gui, msg, e)
  local task_id = msg.task_id

  local task = global.tasks[task_id]
  if task then
    task.completed = not task.completed
    e.element.state = task.completed
  end
end

--- @param Gui TasksGui
--- @param e on_gui_click
function actions.expand_task(Gui, _, e)
  local elem = e.element
  local details_flow = elem.parent.parent.details_flow

  -- TEMPORARY:
  if e.control or e.shift then
    local our_index = elem.parent.parent.get_index_in_parent()
    local delta = e.shift and 1 or -1
    elem.parent.parent.parent.swap_children(our_index + delta, our_index)
    return
  end

  details_flow.visible = not details_flow.visible
  if details_flow.visible then
    elem.sprite = "tlst_arrow_down"
  else
    elem.sprite = "tlst_arrow_right"
  end
end

return actions
