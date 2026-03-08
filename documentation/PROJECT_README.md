# Monta-Carro - Documentação do Projeto

## Visão Geral
Jogo 3D em Godot 4.6+ para Android, aimed at a 3-year-old child.
- **Criador:** Tales da Rocha (talesrt)
- **Colaborador:** Molton.claw (AI Assistant)
- **Repositório:** https://github.com/talesrt/Monta-Carro

---

## Regras de Contexto (IMPORTANTE)

### Se o Agente Perder Contexto
1. Ler esta documentação primeiro
2. Verificar o roadmap na seção abaixo
3. Olhar o código mais recente no repo
4. Continuar da última tarefa incompleta

### Divisão de Trabalho
- **Molton.claw (IA):** Lógica, programação, sistemas, código
- **Tales (Humano):** Arte, assets 3D, decisions de performance
- **Juntos:** Decisões menores de design

### Processo de Desenvolvimento
1. Tarefas longas = usar sub-agents
2. Revisar código após sub-agents
3. Placeholders são bem-vindos (não esperar assets finais)
4. Código primeiro, arte depois

---

## 🚀 Roadmap de Desenvolvimento

### Fase 1: Setup + Estrutura Base
- [x] Configurar Godot 4.6 (mobile renderer) ✓
- [x] Criar pastas (scenes, scripts, etc.) ✓
- [ ] Scene principal (Main)
- [ ] Sistema de estados do carro (enum:montado, limpo, sujo, quebrado)

### Fase 2: Sistema de Montagem
- [ ] Modelo 3D placeholder do carro
- [ ] Peças soltas (chassis, rodas, motor)
- [ ] Drag & drop com snap
- [ ] Detectar montagem completa
- [ ] Animação de "carro montado"

### Fase 3: Sistema de Lavagem
- [ ] Carro sujo (visual placeholder)
- [ ] Input de toque/arrastar para limpar
- [ ] Progresso de limpeza
- [ ] Carro limpo

### Fase 4: Sistema de Direção
- [ ] Câmera lateral
- [ ] Controles de toque
- [ ] Movimento do carro
- [ ] Contador de distância/tempo

### Fase 5: Sistema de Manutenção
- [ ] Carro fica sujo/degradado depois de dirigir
- [ ] Sistema de manutenção (motor, pneu, gasolina)
- [ ] Minigame de manutenção

### Fase 6: Game Loop Completo
- [ ] Menu inicial
- [ ] Conectar todas as fases
- [ ] Transições
- [ ] Sons placeholder

---

## 📁 Estrutura de Arquivos

```
Monta-Carro/
├── scenes/
│   ├── main.tscn              # Cena principal
│   ├── car/                   # Pasta do carro
│   │   ├── car.tscn           # Modelo do carro
│   │   ├── chassis.tscn       # Chassis
│   │   ├── wheel.tscn         # Roda (reutilizável)
│   │   └── engine.tscn        # Motor
│   ├── ui/
│   │   └── game_ui.tscn       # Interface do jogo
│   └── levels/
│       └── level_01.tscn      # Primeiro nível
├── scripts/
│   ├── main.gd                # Script principal
│   ├── car/
│   │   ├── car_controller.gd  # Lógica do carro
│   │   └── car_state.gd       # Estados do carro
│   ├── systems/
│   │   ├── assembly_system.gd    # Sistema de montagem
│   │   ├── wash_system.gd        # Sistema de lavagem
│   │   ├── drive_system.gd       # Sistema de direção
│   │   └── maintenance_system.gd # Sistema de manutenção
│   └── ui/
│       └── game_ui.gd         # Interface
├── assets/
│   ├── models/                # Modelos 3D (placeholder: primitivas)
│   ├── textures/              # Texturas (placeholder: cores)
│   └── sounds/                # Sons (placeholder: none)
└── documentation/
    └── PROJECT_README.md      # Este arquivo
```

---

## 🎮 Estados do Carro

```gdscript
enum CarState {
    UNASSEMBLED,  # Peças soltas
    ASSEMBLED,    # Montado, belum usado
    CLEAN,        # Limpo, pronto para dirigir
    DIRTY,        # Sujo depois de dirigir
    BROKEN        # Precisa de manutenção
}
```

---

## 🔄 Fluxo do Jogo

```
[PEÇAS SOLTAS] → [MONTAR] → [CARRO MONTADO] → [LAVAR] → [LIMPO]
                                                              ↓
                                                    [DIRIGIR]
                                                              ↓
                                                    [SUJO/QUEBRADO]
                                                              ↓
                                                    [MANUTENÇÃO]
                                                              ↓
                                                    [VOLTA AO LIMPO]
```

---

## 📝 Comandos Git

```bash
# Ver status
git status

# Adicionar mudanças
git add -A

# Commit
git commit -m "Descrição da mudança"

# Push
git push

# Pull
git pull
```

---

## ⚠️ Notas Importantes

1. **Nunca fazer push de assets 3D grandes** - só código e placeholders
2. **Sempre testar localmente** antes de commitar
3. **Commits pequenos e frequentes** - facilita revisão
4. **Documentar decisões de design** junto com o código

---

Última atualização: 2026-03-08
Agente atual: Molton.claw
