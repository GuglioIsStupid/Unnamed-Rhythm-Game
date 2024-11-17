local TimingLine = Drawable:extend("TimingLine")

function TimingLine:new(data, width)
    self.data = data

    Drawable.new(self, 0, 0, width, 2)
end

return TimingLine