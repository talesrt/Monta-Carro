# 📓 Agent Log - Monta-Carro

*Log de decisões e ações do agente. Atualizar sempre que houver mudança significativa.*

---

## [2026-04-04]

### Decisões
- Opção B: finalizar e limpar assembly_system_v2.gd como sistema principal
- Snap detection usa group-based approach: DraggablePart procura `snap_points` group
- DraggablePart.gd reescrito do zero para Godot 4 (Area3D, proper signals)

### Ações Realizadas
- assembly_system_v2.gd: simplificado, auto_load_model=true, usa grupos
- DraggablePart.gd: reescrito, usa group lookup para sockets, highlight verde, snap distance 1.0m
- assembly_v2.tscn: script trocado de assembly_system.gd (v1) para v2, DraggablePart em cada Area3D, auto_load_model=true
- main.tscn: referência atualizada de assembly.tscn para assembly_v2.tscn
- game_manager.gd: wired para AssemblySystem v2, has_method() guards

### Status Atual
- Assembly: PRONTO PARA TESTAR (5 peças - 4 rodas + motor)
- Car_1.glb sockets: socket_wheel_FL, socket_wheel_FR, socket_wheel_RL, socket_wheel_RR (já configurados no GLB)
- Próximo: testar no Godot, depois Fase 3 (Lavagem)

---

## [2026-03-10]

### Decisões Tomadas
- Criada cena `assembly_v2.tscn` com o modelo `car_1.glb`
- Sistema de sockets configurado no modelo GLB
- Script `assembly_system_v2.gd` criado para conectar peças aos sockets
- Gateway watchdog issue resolved (disabled watchdog.cmd)

### Ações Realizadas
- Pull do repo `Monta-Carro`
- Análise dos sockets no modelo `car_1.tscn`
- Criação de sistema de drag & drop com SnapPoints
- Setup do reminder diário do Engrama (Notion)

### Problemas
- API do ArtStation bloqueada por Cloudflare
- Sockets precisam de `part_type` configurado manualmente no Godot

### Próximos Passos
- [ ] Testar drag & drop no Godot
- [ ] Configurar `part_type` nos sockets
- [ ] Continuar Fase 2 (Montagem)
- [ ] Implementar sistema de Lavagem

---

## [2026-03-09]

### Decisões Tomadas
- Sistema de drag & drop será baseado em Area3D + CollisionShape3D
- Sockets detectarão peças automaticamente via proximity

### Ações Realizadas
- Revisão do código existente (DraggablePart.gd, SnapPoint.gd)
- Análise da estrutura do projeto

---

*Este arquivo deve ser atualizado sempre que houver decisões importantes ou progresso significativo.*
