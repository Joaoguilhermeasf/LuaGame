
181
182
183
184
185
186
187
188
189
190
191
192
193
194
195
196
197
198
199
200
201
202
203
204
205
206
207
208
209
210
211
212
213
214
215
216
217
218
219
220
221
222
223
224
225
226
227
228
229
230
231
232
233
234
local level = {}
local checkpointX = sw/2
function level.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

     love.graphics.setColor(1, 1, 1, 0.5)
    --GUIDE
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill",0,0,sw/2,sh)

    -- Fundo (sem câmera)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 0, 0, sw/background:getWidth(), sh/background:getHeight())

   

    -- Câmera
    love.graphics.push()
    love.graphics.translate(-camX, 0)

    


     -- Bush
    local bs = sw*0.25
    local scale = bs / bush:getWidth()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bush, sw/2, sh*0.65, 0, scale, scale)

    -- Chão 1
    love.graphics.setColor(0.8, 0.7, 0.6)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- Chão 2
    love.graphics.setColor(0.8, 0.7, 0.6)
    love.graphics.polygon("fill", ground2.body:getWorldPoints(ground2.shape:getPoints()))

    love.graphics.setColor(0.8,0.7,0.6)
    love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))


    -- define cor com alpha (fade)
love.graphics.setColor(1, 1, 1, fade)

    -- desenha centralizado
    love.graphics.draw(
        welcomeText,
        textX - welcomeText:getWidth()/2,
        textY - welcomeText:getHeight()/2
    )

    love.graphics.setColor(1, 1, 1)

    -- Player
    local px, py = player.body:getPosition()
    local pScale = (player.shape:getRadius() * 2.5) / playerImg:getWidth()
    love.graphics.draw(playerImg, px, py, player.body:getAngle(), pScale, pScale, playerImg:getWidth()/2, playerImg:getHeight()/2)

    love.graphics.pop()
end
