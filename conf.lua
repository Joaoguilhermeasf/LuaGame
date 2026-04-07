-- Arquivo: conf.lua (deve estar na mesma pasta que o main.lua)
function love.conf(t)
    t.identity = "meu_jogo_blob"  -- Nome único para salvar dados
    t.version = "11.4"             -- Versão do LÖVE

    t.window.title = "bLob High Res"
    t.window.icon = nil            -- Caminho para o ícone (opcional)

    -- --- CONFIGURAÇÕES DE RESOLUÇÃO CRUCIAIS PARA IOS ---
    t.window.width = 1280          -- Largura lógica (não física)
    t.window.height = 720          -- Altura lógica
    t.window.highdpi = true        -- ATIVA O SUPORTE A RETINA DISPLAY (MÁXIMA NITIDEZ)
    t.window.usedpiscale = true    -- Usa a escala do sistema operacional
    t.window.resizable = true      -- Permite rotacionar a tela no iOS
    t.window.borderless = false
    t.window.fullscreen = false

    -- Módulos necessários
    t.modules.physics = true
    t.modules.touch = true
    t.modules.graphics = true
end