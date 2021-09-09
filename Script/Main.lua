-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.NatServer == nil then _G.NatServer = {} end
local NatServer = NatServer
local Lua = Lua
local ALittle = ALittle
local ___pairs = pairs
local ___ipairs = ipairs

ALittle.RegStruct(-1673577841, "NatServer.SS2NAT_NReleasePort", {
name = "NatServer.SS2NAT_NReleasePort", ns_name = "NatServer", rl_name = "SS2NAT_NReleasePort", hash_code = -1673577841,
name_list = {"port"},
type_list = {"int"},
option_map = {}
})
ALittle.RegStruct(953391362, "NatServer.SS2NAT_QUsePort", {
name = "NatServer.SS2NAT_QUsePort", ns_name = "NatServer", rl_name = "SS2NAT_QUsePort", hash_code = 953391362,
name_list = {"port","target_ip","target_port"},
type_list = {"int","string","int"},
option_map = {}
})
ALittle.RegStruct(726219872, "NatServer.NAT2SS_AUsePort", {
name = "NatServer.NAT2SS_AUsePort", ns_name = "NatServer", rl_name = "NAT2SS_AUsePort", hash_code = 726219872,
name_list = {"port","password"},
type_list = {"int","string"},
option_map = {}
})

NatServer.g_ConfigSystem = nil
NatServer.g_ModulePath = nil
NatServer.g_DynamicNatSystem = nil
NatServer.g_StaticNatSystem = nil
function NatServer.__Module_Setup(sengine_path, module_path, config_path)
	NatServer.g_ConfigSystem = ALittle.CreateJsonConfig(config_path, true)
	NatServer.g_ModulePath = module_path
	Require(sengine_path, "Script/Nat/NatSystem")
	local wan_ip = NatServer.g_ConfigSystem:GetConfig("wan_ip", "127.0.0.1")
	local yun_ip = NatServer.g_ConfigSystem:GetConfig("yun_ip", "")
	local nat_route_num = NatServer.g_ConfigSystem:GetConfig("nat_route_num", 1)
	__CPPAPI_ServerSchedule:StartRouteSystem(12, nat_route_num)
	__CPPAPI_ServerSchedule:CreateConnectServer(yun_ip, wan_ip, 2100 + nat_route_num)
	local static_start_nat_port = NatServer.g_ConfigSystem:GetConfig("static_start_nat_port", 5060)
	local static_nat_port_count = NatServer.g_ConfigSystem:GetConfig("static_nat_port_count", 1000)
	NatServer.g_StaticNatSystem = ALittle.NatSystem()
	NatServer.g_StaticNatSystem:Setup(wan_ip, static_start_nat_port, static_nat_port_count)
	local dynamic_start_nat_port = NatServer.g_ConfigSystem:GetConfig("dynamic_start_nat_port", 10000)
	local dynamic_nat_port_count = NatServer.g_ConfigSystem:GetConfig("dynamic_nat_port_count", 10000)
	NatServer.g_DynamicNatSystem = ALittle.NatSystem()
	NatServer.g_DynamicNatSystem:Setup(wan_ip, dynamic_start_nat_port, dynamic_nat_port_count)
end
NatServer.__Module_Setup = Lua.CoWrap(NatServer.__Module_Setup)

function NatServer.__Module_Shutdown()
	NatServer.g_StaticNatSystem:Shutdown()
	NatServer.g_DynamicNatSystem:Shutdown()
end

function NatServer.HandleQUsePort(client, msg)
	local ___COROUTINE = coroutine.running()
	local rsp = {}
	if msg.port == 0 or msg.port == nil then
		rsp.port, rsp.password = NatServer.g_DynamicNatSystem:UsePort(client, msg.port)
		if rsp.port ~= nil and msg.target_ip ~= "" and msg.target_ip ~= nil then
			local error = NatServer.g_DynamicNatSystem:SetTarget(client, rsp.port, msg.target_ip, msg.target_port)
			if error ~= nil then
				Lua.Assert(false, error)
			end
		end
	else
		rsp.port, rsp.password = NatServer.g_StaticNatSystem:UsePort(client, msg.port)
		if rsp.port ~= nil and msg.target_ip ~= "" and msg.target_ip ~= nil then
			local error = NatServer.g_StaticNatSystem:SetTarget(client, rsp.port, msg.target_ip, msg.target_port)
			if error ~= nil then
				Lua.Assert(false, error)
			end
		end
	end
	Lua.Assert(rsp.port, "can't use port:" .. msg.port)
	ALittle.Log("use port, from port:" .. msg.port .. " bind port:" .. rsp.port .. " target " .. msg.target_ip .. ":" .. msg.target_port)
	return rsp
end

ALittle.RegMsgRpcCallback(953391362, NatServer.HandleQUsePort, 726219872)
function NatServer.HandleQReleasePort(client, msg)
	ALittle.Log("release port, bind port:" .. msg.port)
	NatServer.g_DynamicNatSystem:ReleasePort(client, msg.port)
	NatServer.g_StaticNatSystem:ReleasePort(client, msg.port)
end

ALittle.RegMsgCallback(-1673577841, NatServer.HandleQReleasePort)
end