return {
  ["init"] = function(trigpin,resetpin,gofn)
    gpio.mode(trigpin,gpio.INT,gpio.PULLUP)   -- GPIO12 is cap sensor IRQ (active low)
    gpio.mode(resetpin,gpio.OUTPUT,gpio.FLOAT) -- GPIO14 is cap sensor reset (active low)
  
    -- put cap through a reset cycle and then hook our IRQ handler
    gpio.trig(trigpin)
    gpio.write(resetpin,gpio.HIGH)
    tq:queue(200,function()
      gpio.write(resetpin,gpio.LOW)
      tq:queue(300,function()
        print('CAP', cap:info())
        gpio.trig(trigpin, "low", gofn)
        cap:wr(0x20,0x28) -- config: add maximum duration autorecalibrate
        cap:wr(0x22,0xF4) -- raise maximum duration to 11 seconds; repeat every 175ms
        cap:wr(0x2A,0x00) -- do not block multiple touches
        cap:wr(0x41,0x30) -- change standby sampling rate
        cap:wr(0x72,0xFF) -- link all LEDs to touches
      end)
    end)
  end,

  -- calibrate all input sensors
  ["calibrate"] = function() 
     cap:wr(0x26,0xFF)
  end
}
