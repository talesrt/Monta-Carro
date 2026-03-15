# 📁 Folder Structure - Monta-Carro

```
Monta-Carro/
├── scenes/
│   ├── main.tscn              # Cena principal
│   ├── car/
│   │   ├── assembly.tscn     # Cena de montagem
│   │   ├── assembly_v2.tscn  # Cena v2 (com modelo GLB)
│   │   ├── chassis.tscn       # Chassis
│   │   ├── wheel.tscn         # Roda
│   │   └── engine.tscn        # Motor
│   ├── ui/
│   └── levels/
├── scripts/
│   ├── main.gd
│   ├── car/
│   │   ├── car_controller.gd
│   │   └── car_state.gd
│   └── systems/
│       ├── assembly_system.gd
│       ├── draggable_part.gd
│       ├── snap_point.gd
│       └── ...
├── assets/
│   ├── models/
│   │   └── car_1.glb         # Modelo 3D do carro
│   └── textures/
└── documentation/
    ├── PROJECT_README.md       # Documentação principal
    ├── Agent Instructions.md  # Instruções de design
    ├── AGENT_LOG.md           # 📓 LOG DO AGENTE (sempre atualizar!)
    └── Folder Structure.md    # Este arquivo
```

---

## 📓 AGENT LOG

**SEMPRE atualize o `AGENT_LOG.md`** quando:
- Tomar uma decisão de design
- Completar uma fase/tarefa
- Encontrar um problema
- Mudar de contexto (ex: parar de trabalhar e voltar depois)

Isso garante continuidade quando o agente reinicia.

---

*Última atualização: 2026-03-10*
