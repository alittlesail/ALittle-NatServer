-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.NatServer == nil then _G.NatServer = {} end
local NatServer = NatServer
local Lua = Lua
local ALittle = ALittle
local ___pairs = pairs
local ___ipairs = ipairs

ALittle.RegStruct(1835539840, "NatServer.SS2NAT_QSetTarget", {
name = "NatServer.SS2NAT_QSetTarget", ns_name = "NatServer", rl_name = "SS2NAT_QSetTarget", hash_code = 1835539840,
name_list = {"port","target_ip","target_port"},
type_list = {"int","string","int"},
option_map = {}
})
ALittle.RegStruct(-1673577841, "NatServer.SS2NAT_NReleasePort", {
name = "NatServer.SS2NAT_NReleasePort", ns_name = "NatServer", rl_name = "SS2NAT_NReleasePort", hash_code = -1673577841,
name_list = {"port"},
type_list = {"int"},
option_map = {}
})
ALittle.RegStruct(953391362, "NatServer.SS2NAT_QUsePort", {
name = "NatServer.SS2NAT_QUsePort", ns_name = "NatServer", rl_name = "SS2NAT_QUsePort", hash_code = 953391362,
name_list = {"port"},
type_list = {"int"},
option_map = {}
})
ALittle.RegStruct(-777595446, "NatServer.SS2NAT_ASetTarget", {
name = "NatServer.SS2NAT_ASetTarget", ns_name = "NatServer", rl_name = "SS2NAT_ASetTarget", hash_code = -777595446,
name_list = {},
type_list = {},
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
function NatServer.__Module_Setup(sengine_path, module_path, config_path)
	NatServer.g_ConfigSystem = ALittle.CreateJsonConfig(config_path, true)
	NatServer.g_ModulePath = module_path
	Require(sengine_path, "Script/Nat/NatSystem")
	local wan_ip = NatServer.g_ConfigSystem:GetConfig("wan_ip", "127.0.0.1")
	local yun_ip = NatServer.g_ConfigSystem:GetConfig("yun_ip", "")
	local nat_route_num = NatServer.g_ConfigSystem:GetConfig("nat_route_num", 1)
	__CPPAPI_ServerSchedule:StartRouteSystem(12, nat_route_num)
	__CPPAPI_ServerSchedule:CreateConnectServer(yun_ip, wan_ip, 2100 + nat_route_num)
	local start_nat_port = NatServer.g_ConfigSystem:GetConfig("start_nat_port", 5060)
	local nat_port_count = NatServer.g_ConfigSystem:GetConfig("nat_port_count", 10000)
	A_NatSystem:Setup(wan_ip, start_nat_port, nat_port_count)
end
NatServer.__Module_Setup = Lua.CoWrap(NatServer.__Module_Setup)

function NatServer.__Module_Shutdown()
	A_NatSystem:Shutdown()
end

function NatServer.HandleQUsePort(client, msg)
	local ___COROUTINE = coroutine.running()
	local port, password = A_NatSystem:UsePort(client, msg.port)
	Lua.Assert(port, "can't use port:" .. msg.port)
	local rsp = {}
	rsp.port = port
	rsp.password = password
	return rsp
end

ALittle.RegMsgRpcCallback(953391362, NatServer.HandleQUsePort, 726219872)
function NatServer.HandleQSetTarget(client, msg)
	local ___COROUTINE = coroutine.running()
	local error = A_NatSystem:SetTarget(client, msg.port, msg.target_ip, msg.target_port)
	if error ~= nil then
		Lua.Assert(false, error)
	end
	return {}
end

ALittle.RegMsgRpcCallback(1835539840, NatServer.HandleQSetTarget, -777595446)
function NatServer.HandleQReleasePort(client, msg)
	A_NatSystem:ReleasePort(client, msg.port)
end

ALittle.RegMsgCallback(-1673577841, NatServer.HandleQReleasePort)
end