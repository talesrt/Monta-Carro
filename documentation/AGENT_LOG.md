# 📓 Agent Log - Monta-Carro

*Log de decisões e ações do agente. Atualizar sempre que houver mudança significativa.*

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
