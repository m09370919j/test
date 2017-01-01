-- This script is based on telegram-cli sample lua script by @vysheng, 
-- written to demonstrate how to use tdlib.lua for your telegram-cli bot

-- Load tdcli library.
tdcli = dofile('tdcli.lua')
--local redis = require 'redis'
--redis = (loadfile "redis.lua")()
--JSON = require('dkjson')
--db = require('redis')
--redis = db.connect('127.0.0.1', 6379)
--serpent = require('serpent')
--redis:select(2)}
--redis = dofile('redis.lua')
--JSON = require('dkjson')
--serpent = require('serpent')
--redis = (loadfile "./libs/redis.lua")()
redis = require('redis')
redis = Redis.connect('127.0.0.1', 6379)

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
	if msg.content_.caption_ then
          input = msg.text .. msg.content_.caption_
        end
	if msg.content_.voice_ then
        input = "!!!voice:"
        if msg.content_.caption_ then
          input = msg.text .. msg.content_.caption_
        end
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
      if input:match("^[#!/][Ii][Dd]$") then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Chat ID:</b> <code>'..string.sub(chat_id, 5,14)..'</code>\n<b>Your ID:</b> <code>'..user_id..'</code>', 1, 'html')
      end
      if input:match("^[#!/][Pp][Ii][Nn]") and reply_id then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Your Msg Has Been Pinned.</i>', 1, 'html')
        tdcli.pinChannelMessage(chat_id, reply_id, 1)
      end
      if input:match("^[#!/][Uu][Nn][Pp][Ii][Nn]") and reply_id then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Your Msg Has Been Unpinned.', 1, 'html')
        tdcli.unpinChannelMessage(chat_id, reply_id, 1)
      end
      if input:match("^[#!/][Ll]ock link$") and is_sudo(msg) then
       if redis:get('llink:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Link Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('llink:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Link Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock link$") and is_sudo(msg) then
       if not redis:get('llink:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Link Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('llink:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Link Posting Is Allowed Here.</i>', 1, 'html')
      end
      end
      if redis:get('llink:'..chat_id) and input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
		
	if input:match("^[#!/][Ll]ock fwd$") and is_sudo(msg) then
       if redis:get('lfwd:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Fwd Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('lfwd:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Fwd Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock fwd$") and is_sudo(msg) then
       if not redis:get('lfwd:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Fwd Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('lfwd:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Fwd Posting Is Allowed Here.</i>', 1, 'html')
      end
      end		
	if redis:get('lfwd:'..chat_id) and msg.forward_info_ and not is_sudo(msg) then
	tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
		
	if input:match("^[#!/][Ll]ock tag$") and is_sudo(msg) then
       if redis:get('ltag:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Tag Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('ltag:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Tag Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock tag$") and is_sudo(msg) then
       if not redis:get('ltag:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Tag Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('ltag:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Tag Posting Is Allowed Here.</i>', 1, 'html')
      end
      end
      if redis:get('ltag:'..chat_id) and input:match("@") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end	
		
	if input:match("^[#!/][Ll]ock hashtag$") and is_sudo(msg) then
       if redis:get('lhashtag:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>HashTag Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('lhashtag:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now HashTag Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock hashtag$") and is_sudo(msg) then
       if not redis:get('lhashtag:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>HashTag Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('lhashtag:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now HashTag Posting Is Allowed Here.</i>', 1, 'html')
      end
      end
      if redis:get('lhashtag:'..chat_id) and input:match("#") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end

	if input:match("^[#!/][Ll]ock cmd$") and is_sudo(msg) then
       if redis:get('lcmd:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Cmd Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('lcmd:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Cmd Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock cmd$") and is_sudo(msg) then
       if not redis:get('lcmd:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Cmd Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('lcmd:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Cmd Posting Is Allowed Here.</i>', 1, 'html')
      end
      end
      if redis:get('lcmd:'..chat_id) and input:match("[#/!]") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
			
      if input:match("^[#!/][Ll]ock webpage$") and is_sudo(msg) then
       if redis:get('lwebpage:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>WebPage Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('lwebpage:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now WebPage Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock webpage$") and is_sudo(msg) then
       if not redis:get('lwebpage:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>WebPage Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('lwebpage:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now WebPage Posting Is Allowed Here.</i>', 1, 'html')
      end
      end
      if redis:get('lwebpage:'..chat_id) and input:match("https://") and not is_sudo(msg) then
	elseif redis:get('lwebpage:'..chat_id) and input:match("http://") and not is_sudo(msg) then
	elseif redis:get('lwebpage:'..chat_id) and input:match("www.") and not is_sudo(msg) then
	elseif redis:get('lwebpage:'..chat_id) and input:match(".com") and not is_sudo(msg) then
	elseif redis:get('lwebpage:'..chat_id) and input:match(".ir") and not is_sudo(msg) then
	elseif redis:get('lwebpage:'..chat_id) and input:match(".org") and not is_sudo(msg) then
	elseif redis:get('lwebpage:'..chat_id) and input:match(".net") and not is_sudo(msg) then
	elseif redis:get('lwebpage:'..chat_id) and input:match(".info") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
			
	if input:match("^[#!/][Ll]ock english$") and is_sudo(msg) then
       if redis:get('lenglish:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>English Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('lenglish:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now English Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock english$") and is_sudo(msg) then
       if not redis:get('lenglish:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>English Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('lenglish:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now English Posting Is Allowed Here.</i>', 1, 'html')
      end
      end
      if redis:get('lenglish:'..chat_id) and input:match("[abcdefghijklmnopqrstuvwxyz]") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
			
	if input:match("^[#!/][Ll]ock arabic$") and is_sudo(msg) then
       if redis:get('larabic:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Arabic/Persian Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('larabic:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Arabic/Persian Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock arabic$") and is_sudo(msg) then
       if not redis:get('larabic:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Arabic/Persian Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('larabic:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now Arabic/Persian Posting Is Allowed Here.</i>', 1, 'html')
      end
      end
      if redis:get('larabic:'..chat_id) and input:match("[ضصقفغعهخحجشسیبلاتنمچظطزردپوکگژذثآ]") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
			
	if input:match("^[#!/][Ll]ock badword$") and is_sudo(msg) then
       if redis:get('lbadword:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>BadWord Posting Is Already Not Allowed Here.</i>', 1, 'html')
       else 
        redis:set('lbadword:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now BadWord Posting Is Not Allowed Here.</i>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock badword$") and is_sudo(msg) then
       if not redis:get('lbadword:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>BadWord Posting Is Already Allowed Here.</i>', 1, 'html')
       else
         redis:del('lbadword:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Now BadWord Posting Is Allowed Here.</i>', 1, 'html')
      end
      end
      if redis:get('lbadword:'..chat_id) and input:match("کیر") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("کس") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("کص") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("کث") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("کسکش") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("کونی") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("چاقال") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("ننه") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("نن") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("kir") and not is_sudo(msg) then
	elseif redis:get('lbadword:'..chat_id) and input:match("kos") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
			
	
			
      if input:match("^[#!/][Mm]ute all$") and is_sudo(msg) then
       if redis:get('mall:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Mute All Is Already Enabled.</i>', 1, 'html')
       else 
        redis:set('mall:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b\n<i>>Mute All Has Been Enabled.</i>', 1, 'html')
      end
      end
      if input:match("^[#!/][Uu]nmute all$") and is_sudo(msg) then
       if not redis:get('mall:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Mute All Is Already Disable.</i>', 1, 'html')
       else 
         redis:del('mall:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Mute All Has Been Disabled.</i>', 1, 'html')
      end
      end
	if redis:get('mall:'..chat_id) and msg then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end			
				
		if input:match("^[#!/][Mm]ute sticker$") and is_sudo(msg) then
       if redis:get('msticker:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Mute Sticker Is Already Enabled.</i>', 1, 'html')
       else 
        redis:set('msticker:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b\n<i>>Mute Sticker Has Been Enabled.</i>', 1, 'html')
      end
      end
      if input:match("^[#!/][Uu]nmute sticker$") and is_sudo(msg) then
       if not redis:get('msticker:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Error!</b>\n<i>>Mute Sticker Is Already Disable.</i>', 1, 'html')
       else 
         redis:del('msticker:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Done!</b>\n<i>>Mute Sticker Has Been Disabled.</i>', 1, 'html')
      end		
	end
	if redis:get('msticker:'..chat_id) and input:match("!!!voice:") and msg then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end			
         local links = 'llink:'..chat_id
	 if redis:get(links) then
	  Links = "Lock"
	  else 
	  Links = "Unlock"
	 end
			
	local lfwd = 'lfwd:'..chat_id
	 if redis:get(lfwd) then
	  lfwd = "Lock"
	  else 
	  lfwd = "Unlock"
	 end
			
	local ltag = 'ltag:'..chat_id
	 if redis:get(ltag) then
	  ltag = "Lock"
	  else 
	  ltag = "Unlock"
	 end
			
	local lhashtag = 'lhashtag:'..chat_id
	 if redis:get(lhashtag) then
	  lhashtag = "Lock"
	  else 
	  lhashtag = "Unlock"
	 end

	local lcmd = 'lcmd:'..chat_id
	 if redis:get(lcmd) then
	  lcmd = "Lock"
	  else 
	  lcmd = "Unlock"
	 end
			
	local lwebpage = 'lwebpage:'..chat_id
	 if redis:get(lwebpage) then
	  lwebpage = "Lock"
	  else 
	  lwebpage = "Unlock"
	 end
			
	local lenglish = 'lenglish:'..chat_id
	 if redis:get(lenglish) then
	  lenglish = "Lock"
	  else 
	  lenglish = "Unlock"
	 end
			
	local larabic = 'larabic:'..chat_id
	 if redis:get(larabic) then
	  larabic = "Lock"
	  else 
	  larabic = "Unlock"
	 end
			
	local lbadword = 'lbadword:'..chat_id
	 if redis:get(lbadword) then
	  lbadword = "Lock"
	  else 
	  lbadword = "Unlock"
	 end
			
         local all = 'mall:'..chat_id
	 if redis:get(all) then
	  All = "Lock"
	  else 
	  All = "Unlock"
	 end
      if input:match("^[#!/][Ss]ettings$") and is_sudo(msg) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Settings:</b>\n\n<b>Fwd:</b> <code>'..lfwd..'</code>\n<b>Link:</b> <code>'..Links..'</code>\n<b>Tag{@}:</b> <code>'..ltag..'</code>\n<b>HashTag{#}:</b> <code>'..lhashtag..'</code>\n<b>Cmd:</b> <code>'..lcmd..'</code>\n<b>WebPage:</b> <code>'..lwebpage..'</code>\n<b>English:</b> <code>'..lenglish..'</code>\n<b>Arabic/Persian:</b> <code>'..larabic..'</code>\n<b>BadWord:</b> <code>'..lbadword..'</code>\n➖➖➖➖➖➖➖\n<b>Mutes List:</b>\n\n<b>Mute All:</b> <code>'..All..'</code>\n➖➖➖➖➖➖➖\n<b>Group Language:</b> <i>EN</i>', 1, 'html')
      end
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
end
