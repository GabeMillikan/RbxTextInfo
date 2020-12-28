local TextService = game:GetService("TextService")

local function getTextSize(txt, fontSize, font)
    local size = TextService:GetTextSize(txt, fontSize, font, Vector2.new(math.huge,math.huge))
    return size.X, size.Y
end

local function getTextInfo(str, bounds, fontSize, font)
    str = str:gsub("%s", " ")
    local words = str:split(" ")
    local paragraph = {}
    local x = 0
    local y = 0
    
    local i = 1
    while i <= #words do
        local word = words[i]
        local width, height = getTextSize(word, fontSize, font)
        if x + width > bounds.X then
            -- we need to wrap this word around
            
            if x == 0 then
                -- it's already wrapped, this word is just huge lol
                -- find the minimum amount of character we have to chop off 
                -- in order for it to fit on the line
                
                local strlen = math.floor((width / bounds.X) * word:len())
                local lastWidth, lastHeight
                local finalWidth, finalHeight
                local initialFit = nil 
                
                repeat
                    local wordCopy = word:sub(1, strlen)
                    local newWidth, newHeight = getTextSize(wordCopy, fontSize, font)
                    local thisFit = newWidth <= bounds.X
                    
                    if initialFit == nil then
                        -- this was the first iteration
                        initialFit = thisFit
                    else
                        if initialFit and not thisFit then
                            -- we have walked off the end of the string
                            strlen -= 1
                            finalWidth = lastWidth
                            finalHeight = lastWidth
                            break
                        elseif not initialFit and thisFit then
                            -- we have walked back onto the string
                            finalWidth = newWidth
                            finalHeight = newHeight
                            break
                        end
                    end
                    lastWidth = newWidth
                    lastHeight = newHeight
                    strlen += thisFit and 1 or -1
                until false -- will break on its own

                -- length is the max number of characters that will fit on this line
                table.insert(paragraph, 
                    {word=word:sub(1, strlen), x=x, y=y, width=finalWidth, height=finalHeight}
                )

                -- move to next line
                y += fontSize
                x = 0

                -- truncate word so it can be processed again on the next line
                words[i] = word:sub(strlen+1, word:len())
                i -= 1
            else
                -- the word can be wrapped onto the next line, and the carrige can return
                x = 0
                y += fontSize 
                    
                -- let the word get processed again with the new wrapping
                i -= 1
            end
        else
            -- the word does not need to be wrapped, hurray!
            table.insert(paragraph, 
                {word=word, x=x, y=y, width=width, height=height}
            )
            
            local _width_for_x, _ = getTextSize(word.." ", fontSize, font)
            x += _width_for_x
        end
        i += 1
    end
    
    return paragraph
end
