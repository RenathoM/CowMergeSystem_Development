local tabs = script.Parent['Layout']:GetChildren()
local selector = script.Parent['Selector']
local seltab = 4

local cd = false

local caroussel = script.Parent.Parent['Frame']['FakeFrame']['Pages']
caroussel.Parent.Parent.ClipDescendants = true


selector.SizeRelative = Vector2.New(1/#tabs, 0)
local selSize = selector.SizeOffset

for i, v in pairs(tabs) do
    v.MouseEnter:Connect(function()
        Tween:TweenColor(v.TextColor, Color.FromHex("#d2d2d6ff"), 0.225, function(val) v.TextColor = val end, TweenType.easeInOutCubic, function() end)
    end)
    v.MouseExit:Connect(function()
        Tween:TweenColor(v.TextColor, Color.FromHex("#717176ff"), 0.225, function(val) v.TextColor = val end, TweenType.easeInOutCubic, function() end)
    end)
    v.Clicked:Connect(function()
        if cd then
            return
        end
        cd = true
        selector.Text = v.Text
        seltab = i
        print(seltab)
        if v.text ~= "Closed" then
            caroussel.Parent.Parent.Visible = true
            Tween:TweenVector2(caroussel.Parent.PositionRelative, Vector2.New(0.5, 0.5), 0.175, function(val) caroussel.Parent.PositionRelative = val  end, TweenType.easeInOutCubic, function()  end)
        else
            Tween:TweenVector2(caroussel.Parent.PositionRelative, Vector2.New(-0.5, 0.5), 0.175, function(val) caroussel.Parent.PositionRelative = val  end, TweenType.easeInOutCubic, function() caroussel.Parent.Parent.Visible = false end)
        end
        Tween:TweenVector2(selector.PositionRelative, Vector2.New((i/#tabs)-(0.5/#tabs), 0.5), 0.175, function(val) selector.PositionRelative = val  end, TweenType.easeInOutCubic, function() end)
        Tween:TweenVector2(caroussel.PositionRelative, Vector2.New(2.5-seltab, 0.5), 0.175, function(val) caroussel.PositionRelative = val  end, TweenType.easeInOutCubic, function() end)        
        if v.text == "Closed" then wait(.175) end
        cd = false
    end)
end

selector.MouseEnter:Connect(function()
    Tween:TweenVector2(selSize, Vector2.New(selSize.x+10, selSize.y+10), 0.225, function(val) selector.SizeOffset = val end, TweenType.easeInOutCubic, function() end)
end)
selector.MouseExit:Connect(function()
    Tween:TweenVector2(Vector2.New(selSize.x+10, selSize.y+10), selSize, 0.225, function(val) selector.SizeOffset = val end, TweenType.easeInOutCubic, function() end)
end)