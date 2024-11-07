#!/usr/bin/env lua
-- Copyright (C) 2024 Maizil https://github.com/maizil41

local socket = require("socket")
local use_ssl, ssl = pcall(require, "ssl")

local Blynk = require("blynk.socket")
local Timer = require("timer")
local nixio = require("nixio")

local auth = 'Your_Blynk_Auth_Token' -- Ganti dengan token blynk anda

local iface0 = "eth0.20"  -- Sesuiakan interface
local iface1 = "wwan0"    -- Sesuiakan interface
local iface2 = "eth0.10"  -- Sesuiakan interface
local iface3 = "eth0.30"  -- Sesuiakan interface

local blynk = Blynk.new(auth, {
  heartbeat = 30,
})

local function connectBlynk()
  local host = "blynk.cloud"
  local sock = assert(socket.tcp())
  sock:setoption("tcp-nodelay", true)

  if use_ssl then
    print("Connecting Blynk (secure)...")
    sock:connect(host, 443)
    local opts = {
      mode = "client",
      protocol = "tlsv1_2"
    }
    sock = assert(ssl.wrap(sock, opts))
    assert(sock:dohandshake())
  else
    print("Connecting Blynk...")
    sock:connect(host, 80)
  end

  blynk:connect(sock)
end

blynk:on("connected", function(ping)
  print("Ready. Ping: " .. math.floor(ping * 1000) .. "ms")
  blynk:syncVirtual(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
end)

blynk:on("disconnected", function()
  print("Disconnected.")
  socket.sleep(5)
  connectBlynk()
end)

local function readAvailableRAM()
  local file = io.popen("free | grep Mem | awk '{print $7}'")
  local available_ram = file:read("*n")
  file:close()
  return available_ram
end

local tmr2 = Timer:new{interval = 5000, func = function()
  local available_ram = readAvailableRAM()
  if available_ram then
    blynk:virtualWrite(0, string.format("%.2f", available_ram / 1024))
  end
end}

blynk:on("V1", function(param)
  local command = tonumber(param[1])
  if command == 1 then
    os.execute("wifi up")
  else
    os.execute("wifi down")
  end
end)

blynk:on("V2", function(param)
  local gpio_path = "/sys/class/gpio/gpio505"

  local file = io.open(gpio_path, "r")
  if not file then
    os.execute("echo 505 > /sys/class/gpio/export")
    os.execute("echo 'out' > " .. gpio_path .. "/direction")
  else
    file:close()
  end

  local command = tonumber(param[1])
  if command == 1 then
    os.execute("echo 1 > " .. gpio_path .. "/value")
  else
    os.execute("echo 0 > " .. gpio_path .. "/value")
  end
end)

local function readTemperature()
  local file = io.open("/sys/class/thermal/thermal_zone0/temp", "r")
  if file then
    local temp = file:read("*n")
    file:close()
    return temp and temp / 1000 or nil
  end
end

local function formatBytes(bytes)
  if bytes >= 1073741824 then
    return string.format("%.2f GB", bytes / 1073741824)
  elseif bytes >= 1048576 then
    return string.format("%.2f MB", bytes / 1048576)
  elseif bytes >= 1024 then
    return string.format("%.2f KB", bytes / 1024)
  else
    return string.format("%d B", bytes)
  end
end

local function formatSpeed(speed_mbps)
  return string.format("%.2f", speed_mbps)
end

local function readEth0Speed()
  local file = io.popen("cat /proc/net/dev | grep " .. iface0)
  local line = file:read("*line")
  file:close()

  if line then
    local fields = {}
    for word in line:gmatch("%S+") do table.insert(fields, word) end
    local rx_bytes = tonumber(fields[2]) or 0
    local tx_bytes = tonumber(fields[10]) or 0
    return rx_bytes, tx_bytes
  end
end

local function readEth1Speed()
  local file = io.popen("cat /proc/net/dev | grep " .. iface1)
  local line = file:read("*line")
  file:close()

  if line then
    local fields = {}
    for word in line:gmatch("%S+") do table.insert(fields, word) end
    local rx_bytes = tonumber(fields[2]) or 0
    local tx_bytes = tonumber(fields[10]) or 0
    return rx_bytes, tx_bytes
  end
end

local function readEth2Speed()
  local file = io.popen("cat /proc/net/dev | grep " .. iface2)
  local line = file:read("*line")
  file:close()

  if line then
    local fields = {}
    for word in line:gmatch("%S+") do table.insert(fields, word) end
    local rx_bytes = tonumber(fields[2]) or 0
    local tx_bytes = tonumber(fields[10]) or 0
    return rx_bytes, tx_bytes
  end
end

local function readEth3Speed()
  local file = io.popen("cat /proc/net/dev | grep " .. iface3)
  local line = file:read("*line")
  file:close()

  if line then
    local fields = {}
    for word in line:gmatch("%S+") do table.insert(fields, word) end
    local rx_bytes = tonumber(fields[2]) or 0
    local tx_bytes = tonumber(fields[10]) or 0
    return rx_bytes, tx_bytes
  end
end

local function readCpuLoad()
  local c = io.popen("expr 100 - $(top -n 1 | grep 'CPU:' | awk -F '%' '{print$4}' | awk -F ' ' '{print$2}')")
  if c then
    local load = c:read("*n")
    c:close()
    return load
  end
  return nil
end

local function readCpuFrequency()
  local file = io.open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq", "r")
  if file then
    local freq_khz = tonumber(file:read("*n"))
    file:close()
    if freq_khz then
      return freq_khz / 1000
    end
  end
  return nil
end

local previous_rx_bytes_eth0, previous_tx_bytes_eth0 = 0, 0
local previous_rx_bytes_eth1, previous_tx_bytes_eth1 = 0, 0
local previous_rx_bytes_eth2, previous_tx_bytes_eth2 = 0, 0
local previous_rx_bytes_eth3, previous_tx_bytes_eth3 = 0, 0

local tmr1 = Timer:new{interval = 5000, func = function()
  local temperature = readTemperature()
  if temperature then
    blynk:virtualWrite(3, temperature)
  end

  local rx0, tx0 = readEth0Speed()
  if rx0 and tx0 then
    local total_bytes_eth0 = (rx0 - previous_rx_bytes_eth0) + (tx0 - previous_tx_bytes_eth0)
    local speed_eth0_mbps = (total_bytes_eth0 * 8) / (5 * 1000000)
    previous_rx_bytes_eth0, previous_tx_bytes_eth0 = rx0, tx0
    blynk:virtualWrite(4, formatSpeed(speed_eth0_mbps))
    
    local total_bytes_wan1 = rx0 + tx0
    blynk:virtualWrite(5, formatBytes(total_bytes_wan1))
  end

  local rx1, tx1 = readEth1Speed()
  if rx1 and tx1 then
    local total_bytes_eth1 = (rx1 - previous_rx_bytes_eth1) + (tx1 - previous_tx_bytes_eth1)
    local speed_eth1_mbps = (total_bytes_eth1 * 8) / (5 * 1000000)
    previous_rx_bytes_eth1, previous_tx_bytes_eth1 = rx1, tx1
    blynk:virtualWrite(6, formatSpeed(speed_eth1_mbps))
    
    local total_bytes_wan2 = rx1 + tx1
    blynk:virtualWrite(7, formatBytes(total_bytes_wan2))
  end

  local rx2, tx2 = readEth2Speed()
  if rx2 and tx2 then
    local total_bytes_eth2 = (rx2 - previous_rx_bytes_eth2) + (tx2 - previous_tx_bytes_eth2)
    local speed_eth2_mbps = (total_bytes_eth2 * 8) / (5 * 1000000)
    previous_rx_bytes_eth2, previous_tx_bytes_eth2 = rx2, tx2
    blynk:virtualWrite(8, formatSpeed(speed_eth2_mbps))
    
    local total_bytes_lan1 = rx2 + tx2
    blynk:virtualWrite(9, formatBytes(total_bytes_lan1))
  end
  
  local rx3, tx3 = readEth3Speed()
  if rx3 and tx3 then
    local total_bytes_eth3 = (rx3 - previous_rx_bytes_eth3) + (tx3 - previous_tx_bytes_eth3)
    local speed_eth3_mbps = (total_bytes_eth3 * 8) / (5 * 1000000)
    previous_rx_bytes_eth3, previous_tx_bytes_eth3 = rx3, tx3
    blynk:virtualWrite(10, formatSpeed(speed_eth3_mbps))
    
    local total_bytes_lan2 = rx3 + tx3
    blynk:virtualWrite(11, formatBytes(total_bytes_lan2))
  end

  local cpu_load = readCpuLoad()
  if cpu_load then
    blynk:virtualWrite(12, string.format("%.2f", cpu_load))
  end
end}

connectBlynk()

while true do
  blynk:run()
  tmr1:run()
  tmr2:run()
end
