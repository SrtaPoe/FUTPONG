 local background = nil
-- imagem do fundo (campo de futebol)


 function love.load(arg)

  -- fontes iniciais
  font100 = love.graphics.newFont("fonts/visitor/visitor1.ttf", 100)
  font40 = love.graphics.newFont("fonts/visitor/visitor1.ttf", 40)

  -- audio inicial
  beep = love.audio.newSource("audio/beep.wav", "static") -- música anterior não combinava com o tempo da batida
  beep2 = love.audio.newSource("audio/beep2.wav", "static") -- mesmo problema infeliz :(

  background = love.graphics.newImage("imagens/campo.jpg")

  -- tela (altura  e largura )
  screen = {}
  screen["w"] = love.graphics.getWidth()
  screen["h"] = love.graphics.getHeight()

  -- inicio / velocidade de inicialização / 
  pad = {}
  pad["w"] = 10
  pad["h"] = 60
  pad["speed"] = 3
  pad["startY"] = (screen.h - pad.h) / 2

  -- jogadores / tamanho/ velocidade e dimensão
  player1 = {}
  player1["x"] = 40 - pad.w / 2;
  player1["y"] = pad.startY;
  player1["score"] = 0

  player2 = {}
  player2["x"] = screen.w - 40 - pad.w / 2;
  player2["y"] = pad.startY;
  player2["score"] = 0

  -- bordas
  board = {}
  board["lineW"] = 14
  board["numVerticalDots"] = 14

  -- bolas / tamanho, velocidade e tamanho dividido por 2 / uma bola por vez
  ball = {}
  ball["size"] = 10
  ball["speed"] = 3
  ball["startX"] = screen.w / 2
  ball["startY"] = screen.h / 2
  ball["x"] = ball.startX
  ball["y"] = ball.startY
  ball["dx"] = 1
  ball["dy"] = 1

  -- Jogo / placar e "Começar"
  game = {}
  game["winScore"] = 9
  game["status"] = "start"

  gameOverTimer = 0;
end

function love.update(dt)
  -- Jogador 1 se movendo
  if(love.keyboard.isDown("w")) then -- para cima, a velocidade descresce
    player1.y = player1.y - pad.speed
  elseif(love.keyboard.isDown("s")) then -- para baixo a velocidade aumenta
    player1.y = player1.y + pad.speed
  end

  if(player1.y < board.lineW + pad.h / 2) then
    player1.y = board.lineW + pad.h / 2
  elseif(player1.y > screen.h - board.lineW - pad.h / 2) then  -- condições(jogador x tela X linha da borda e altura total)
    player1.y = screen.h - board.lineW - pad.h / 2
  end

  -- Jogador 2 se movendo
  if(love.keyboard.isDown("p")) then  -- mesma coisa do player 1
    player2.y = player2.y - pad.speed
  elseif(love.keyboard.isDown("l")) then
    player2.y = player2.y + pad.speed
  end

  if(player2.y < board.lineW + pad.h / 2) then
    player2.y = board.lineW + pad.h / 2
  elseif(player2.y > screen.h - board.lineW - pad.h / 2) then
    player2.y = screen.h - board.lineW - pad.h / 2
  end

  -- checando o status do jogo
  if(game.status == "start") then -- começar
    updateStartStatus()
  elseif(game.status == "play") then -- jogar
    updatePlayStatus()
  elseif(game.status == "game over") then -- game over
    gameOverTimer = gameOverTimer + dt
    updateGameOverStatus()
  end
end

function updateStartStatus()  -- espaço inicia uma partida e reinicia também
  if(love.keyboard.isDown("space")) then
    player1.score = 0
    player2.score = 0
    rand = math.random(-1, 1)
    if(rand > 0) then -- condição 1
      ball.dx = 1;
    else -- se não for a anterior, ela segue para Play, após isso termina a função // corrigido o erro do loop
      ball.dx = -1;
    end
    game.status = "play"
  end
end

function updateGameOverStatus() 
  -- aguardar alguns segundos e o show/jogo começa na tela
  if(gameOverTimer > 5) then -- tempo de game over
    resetScore()
    game.status = "start"
  end

  if(love.keyboard.isDown("space")) then
    resetScore()
    game.status = "play"
  end
end

function updatePlayStatus() -- estado de está numa partida / ativo 
  -- bola se movendo
  ball.x =  (ball.x + ball.dx * ball.speed) -- bola (eixo x) / distância / velocidade
  ball.y = (ball.y + ball.dy * ball.speed)

  if(ball.y > screen.h - board.lineW - ball.size / 2) then  -- bola (eixo y / tamanho da tela / borda / tamanho total)
    ball.y = screen.h - board.lineW - ball.size / 2
    ball.dy = -ball.dy
    beep:play()
  elseif (ball.y < board.lineW + ball.size / 2) then
    ball.y = board.lineW + ball.size / 2
    ball.dy = -ball.dy
    beep:play()
  end

  if(  --- testando condições 
      ball.x > player2.x - ball.size and
      ball.y < player2.y + pad.h / 2 and
      ball.y > player2.y - pad.h / 2
  ) then
    ball.x = player2.x - ball.size
    ball.dx = -ball.dx
    beep:play()
  elseif (
      ball.x < player1.x + ball.size and
      ball.y < player1.y + pad.h / 2 and
      ball.y > player1.y - pad.h / 2
  ) then
    ball.x = player1.x + ball.size
    ball.dx = -ball.dx
    beep:play()
  end

  if(ball.x > player2.x + 10) then -- condição ( bola eixo x / jogador 2 + 10)
    player1.score = player1.score + 1
    beep2:play()
    resetBall()
    if(player1.score == game.winScore) then  -- fim de jogo
      endGame()
    end
  elseif(ball.x < player1.x - 10) then
    player2.score = player2.score + 1
    beep2:play()
    resetBall()
    if(player2.score == game.winScore) then
      endGame()
    end
  end
end

function love.draw()  -- desenhando fundo, tela, jogadores, bolas e afins 
  love.graphics.draw(background, 0, 0)
  if(game.status ~= "start") then
    drawBoard()
    drawScore()
    drawPads()
    drawBall()
    if(game.status == "game over") then
        drawGameOverScreen()
    end
  else
    drawStartScreen()
  end
end

function drawStartScreen() -- acabamento / nome/ fonte/ frases para os jogadores
  love.graphics.setFont(font100)
  love.graphics.printf("FUTPONG", 0, 120, screen.w, "center")
  love.graphics.setFont(font40)
  love.graphics.printf("Pressione Espaço para começar", 0, screen.h / 2, screen.w, "center")
  love.graphics.printf("Jogador da Esquerda: w/s\nJogador da Direita: p/l", 0, screen.h / 2 + 60, screen.w, "center")
end

function drawGameOverScreen() -- tela / cor, tamanho e informações durante a partida 
  love.graphics.setColor(255, 0, 255, 0) -- rosa
  love.graphics.rectangle("fill", 0, 0, screen.w, screen.h)
  love.graphics.setColor(255, 0, 255, 255) -- rosa 
  love.graphics.setFont(font100)
  love.graphics.printf("Você Perdeu", 0, 180, screen.w, "center")
  love.graphics.setFont(font40)
  if(player1.score == game.winScore) then
    love.graphics.printf("Jogador 1 ganhou!", 0, screen.h / 2, screen.w, "center")
  else
    love.graphics.printf("Jogador 2 ganhou!", 0, screen.h / 2, screen.w, "center")
  end
  love.graphics.printf("Pressione Spacebar para jogar novamente", 0, screen.h / 2 + 60, screen.w, "center")
end

function drawBoard()  -- laterias / bordas 
  love.graphics.rectangle("fill", 0, 0, screen.w, board.lineW) -- retângulos sendo desenhados 
  love.graphics.rectangle("fill", 0, screen.h - board.lineW, screen.w, board.lineW)
  local h = screen.h / board.numVerticalDots  -- altura/tela // numero vertical da borda 
  for i=0,board.numVerticalDots - 1 do
    love.graphics.rectangle("fill", (screen.w / 2) - (board.lineW / 2), h * i, board.lineW, h / 2)
  end
end
 
function drawScore()  -- jogadores e placar
  love.graphics.setFont(font100)
  love.graphics.printf(player1.score, 0, 15, screen.w / 2, "center") -- x,y, tela, demais eixos 
  love.graphics.printf(player2.score, screen.w / 2, 15, screen.w / 2, "center")
end

function drawPads()  -- barras que se movem ( representam player 1 e player 2)
  love.graphics.rectangle("fill", player1.x - pad.w / 2, player1.y - pad.h / 2, pad.w, pad.h)
  love.graphics.rectangle("fill", player2.x - pad.w / 2, player2.y - pad.h / 2, pad.w, pad.h)
end

function drawBall()  -- bolinha do jogo
  love.graphics.circle("fill", ball.x - ball.size / 2, ball.y - ball.size / 2, ball.size, ball.size) -- MODIFICAR AQUI ( RETORNAR VALORES)
end

function resetScore() -- placar zerado
  player1.score = 0
  player2.score = 0
end

function resetBall() -- sumir as bolas após serem jogadas para as laterais 
  ball.x = ball.startX
  ball.y = ball.startY
  ball.dx = -ball.dx
  ball.dy = -ball.dy
end

function endGame() -- fim de jogo
  gameOverTimer = 0
  game.status = "game over"
end
