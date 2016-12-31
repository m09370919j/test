-- This script is based on telegram-cli sample lua script by @vysheng, 
-- written to demonstrate how to use tdlib.lua for your telegram-cli bot.

-- Load tdcli library.
tdcli = dofile('tdcli.lua')

-- Print message format. Use serpent for prettier result.
function vardump(value, depth, key)
  local linePrefix = ''
  local spaces = ''

  if key ~= nil then
    linePrefix = key .. ' = '
  end

  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do 
      spaces = spaces .. '  '
    end
  end
  
 function is_sudo(msg)
 local var = false
--  — Check users id in config
  for v,user in pairs(sudo_users) do
  if user == msg.sender_user_id_ then
     var = true
 end
  end
  return var
end
sudo_users = {
  90285047,
  0
} 

  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces .. linePrefix .. '(table) ')
    else
      print(spaces .. '(metatable) ')
        value = mTable
    end
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)  == 'function' or 
    type(value) == 'thread' or 
    type(value) == 'userdata' or 
    value == nil then
      print(spaces .. tostring(value))
  elseif type(value)  == 'string' then
    print(spaces .. linePrefix .. '"' .. tostring(value) .. '",')
  else
    print(spaces .. linePrefix .. tostring(value) .. ',')
  end
end

-- Print callback
function dl_cb(arg, data)
  vardump(arg)
  vardump(data)
end

function tdcli_update_callback(data)
  --vardump(data)
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    local input = msg.content_.text_
    local chat_id = msg.chat_id_
    local user_id = msg.sender_user_id_
    local reply_id = msg.reply_to_message_id_
    vardump(msg)
    if msg.content_.ID == "MessageText" then
      -- And content of the text is...
      if input == "ping" then
        -- Reply with regular text
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'pong', 1)
        end
      -- And if content of the text is...
      if input == "PING" then
        -- Reply with formatted text
        tdcli.sendMessage(msg.chat_id_, 0, 1, '<b>PONG</b>', 1, 'html')
      end
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
