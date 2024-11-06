#!/usr/bin/env lua
-- Create By Maizil https://github.com/maizil41

local socket = require("socket")
local use_ssl, ssl = pcall(require, "ssl")

local Blynk = require("blynk.socket")
local Timer = require("timer")

local auth = 'Glgo6NUSt-VdMQuxr8pKK-xxxxxxxx' -- Ganti dengan token blynk anda

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
  blynk:syncVirtual(0, 1, 2, 3, 4) -- Sync V0, V1, V2, V3, V4
end)

blynk:on("disconnected", function()
  print("Disconnected.")
  socket.sleep(5)
  connectBlynk()
end)

blynk:on("V2", function(param)
  local command = tonumber(param[1])
  if command == 1 then
    os.execute("wifi up")
  else
    os.execute("wifi down")
  end
end)

blynk:on("V4", function(param)
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

local function readEth0Speed()
  local file = io.popen("cat /proc/net/dev | grep eth0.20")
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
  local file = io.popen("cat /proc/net/dev | grep eth0.30")
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

local previous_rx_bytes_eth0, previous_tx_bytes_eth0 = 0, 0
local previous_rx_bytes_eth1, previous_tx_bytes_eth1 = 0, 0

local tmr1 = Timer:new{interval = 5000, func = function()
  local temperature = readTemperature()
  if temperature then
    blynk:virtualWrite(0, temperature)
  end

  local rx0, tx0 = readEth0Speed()
  if rx0 and tx0 then
    local total_bytes_eth0 = (rx0 - previous_rx_bytes_eth0) + (tx0 - previous_tx_bytes_eth0)
    local speed_eth0_mbps = (total_bytes_eth0 * 8) / (5 * 1000000)
    previous_rx_bytes_eth0, previous_tx_bytes_eth0 = rx0, tx0
    blynk:virtualWrite(1, speed_eth0_mbps)
  end

  local rx1, tx1 = readEth1Speed()
  if rx1 and tx1 then
    local total_bytes_eth1 = (rx1 - previous_rx_bytes_eth1) + (tx1 - previous_tx_bytes_eth1)
    local speed_eth1_mbps = (total_bytes_eth1 * 8) / (5 * 1000000)
    previous_rx_bytes_eth1, previous_tx_bytes_eth1 = rx1, tx1
    blynk:virtualWrite(3, speed_eth1_mbps)
  end
end}

connectBlynk()

while true do
  blynk:run()
  tmr1:run()
end
