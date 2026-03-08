extends Node
class_name CarStateManager

## Gerencia os estados do carro e transições entre eles

# Estados possíveis do carro
enum CarState {
	UNASSEMBLED,	# Peças soltas, precisa montar
	ASSEMBLED,		# Montado, mas não dirigido ainda
	READY_TO_DRIVE, # Pronto para dirigir (após lavagem)
	DRIVING,		# Em uso
	DIRTY,			# Sujo após dirigir
	BROKEN			# Precisa de manutenção
}

# Estado atual
var current_state: CarState = CarState.UNASSEMBLED

# Dados do carro
var total_distance: float = 0.0
var cleanliness: float = 100.0 # 0-100
var fuel: float = 100.0 # 0-100
var condition: float = 100.0 # 0-100, condição geral

# Configurações
const DIRTY_THRESHOLD: float = 20.0 # Abaixo disso, carro está sujo
const BROKEN_THRESHOLD: float = 20.0 # Abaixo disso, precisa manutenção
const FUEL_CONSUMPTION_RATE: float = 5.0 # Combustível por segundo

signal state_changed(from_state: CarState, to_state: CarState)
signal needs_maintenance(type: String) # "cleaning", "fuel", "repair"

func _ready() -> void:
	reset_car()

func reset_car() -> void:
	current_state = CarState.UNASSEMBLED
	total_distance = 0.0
	cleanliness = 100.0
	fuel = 100.0
	condition = 100.0

## Transiciona para um novo estado
func change_state(new_state: CarState) -> void:
	if new_state == current_state:
		return
	
	var old_state = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)
	
	# Verifica necessidades após mudança de estado
	_check_needs()

func _process(delta: float) -> void:
	if current_state == CarState.DRIVING:
		# Consome combustível
		fuel -= FUEL_CONSUMPTION_RATE * delta
		# Carro fica mais sujo com o tempo
		cleanliness -= delta * 2.0
		# Condição diminui lentamente
		condition -= delta * 0.5
		
		# Verifica se precisa de manutenção
		_check_needs()
		
		# Limites
		fuel = max(0.0, fuel)
		cleanliness = max(0.0, cleanliness)
		condition = max(0.0, condition)

func _check_needs() -> void:
	if cleanliness <= DIRTY_THRESHOLD:
		needs_maintenance.emit("cleaning")
	if fuel <= 10.0:
		needs_maintenance.emit("fuel")
	if condition <= BROKEN_THRESHOLD:
		needs_maintenance.emit("repair")

## Called when player starts assembling
func start_assembly() -> void:
	change_state(CarState.UNASSEMBLED)

## Called when all parts are placed correctly
func complete_assembly() -> void:
	change_state(CarState.ASSEMBLED)

## Called when player washes the car
func wash_car() -> void:
	cleanliness = 100.0
	if fuel > 0.0 and condition > BROKEN_THRESHOLD:
		change_state(CarState.READY_TO_DRIVE)
	elif condition <= BROKEN_THRESHOLD:
		change_state(CarState.BROKEN)

## Called when player starts driving
func start_driving() -> void:
	if current_state == CarState.READY_TO_DRIVE:
		change_state(CarState.DRIVING)

## Called when player stops driving
func stop_driving() -> void:
	if current_state == CarState.DRIVING:
		if cleanliness <= DIRTY_THRESHOLD:
			change_state(CarState.DIRTY)
		elif condition <= BROKEN_THRESHOLD:
			change_state(CarState.BROKEN)
		else:
			change_state(CarState.READY_TO_DRIVE)

## Called when player refuels
func refuel() -> void:
	fuel = 100.0
	_check_needs()

## Called when player repairs
func repair() -> void:
	condition = 100.0
	_check_needs()

## Retorna string do estado atual
func get_state_name() -> String:
	match current_state:
		CarState.UNASSEMBLED: return "Montar"
		CarState.ASSEMBLED: return "Montado"
		CarState.READY_TO_DRIVE: return "Pronto"
		CarState.DRIVING: return "Dirigindo"
		CarState.DIRTY: return "Sujo"
		CarState.BROKEN: return "Quebrado"
		_: return "Desconhecido"

## Retorna se o carro pode ser dirigido
func can_drive() -> bool:
	return current_state == CarState.READY_TO_DRIVE and fuel > 0.0

## Retorna se o carro precisa de atenção
func needs_attention() -> bool:
	return cleanliness <= DIRTY_THRESHOLD or fuel <= 10.0 or condition <= BROKEN_THRESHOLD
