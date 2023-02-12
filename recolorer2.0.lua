function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    callFunction(0x823BDB , 3, 3, 0, 0, 0)
    wait(-1)
end