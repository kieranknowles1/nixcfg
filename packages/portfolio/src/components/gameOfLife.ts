// Get a required element by its ID, throwing if not found
// Does not verify element type, only that it exists
function getById<T>(id: string): T {
    const elem = document.getElementById(id)
    if (elem == null) {
        throw new Error(`Could not get element ${id}`)
    }
    return elem as T
}

interface Vec2 { x: number, y: number }
// Utilities to make working with 2D arrays easier
function vec2(x: number, y: number): Vec2 { return { x, y }}
function vecAdd(a: Vec2, b: Vec2) {
    return vec2(a.x + b.x, a.y + b.y)
}

const canvas = getById<HTMLCanvasElement>('gameoflife')
const ctx = canvas.getContext('2d')
if (ctx == null) {
    throw new Error('Failed to get canvas context')
}

const UPDATE_FREQUENCY = 250
const PIXEL_SIZE = 10
const GRID_SIZE = vec2(canvas.width / PIXEL_SIZE, canvas.height / PIXEL_SIZE)
const STARTING_ALIVE = Math.ceil(GRID_SIZE.x * GRID_SIZE.y * 0.15)
const NEIGHBOUR_OFFSETS = [
    vec2(-1, -1), vec2(0, -1), vec2(1, -1),
    vec2(-1, 0),               vec2(1, 0),
    vec2(-1, 1),  vec2(0, 1),  vec2(1, 1)
]

const cells = Array.from({ length: GRID_SIZE.x },
    _ => Array.from({ length: GRID_SIZE.y }, _ => false)
)

type CellCallback = (pos: Vec2) => void
function forEachCell(cb: CellCallback) {
    for (let x = 0; x < GRID_SIZE.x; x++) {
        for (let y = 0; y < GRID_SIZE.y; y++) {
            cb(vec2(x, y))
        }
    }
}

// Defaults to `false` for out of bounds locations
function cellAlive(pos: Vec2) {
    if (pos.x < 0 || pos.y < 0 || pos.x >= GRID_SIZE.x || pos.y >= GRID_SIZE.y) {
        return false
    }
    return cells[pos.x][pos.y]
}
function setCellState(pos: Vec2, state: boolean) {
    cells[pos.x][pos.y] = state
}

function reset() {
    forEachCell(pos => setCellState(pos, false))
    for (let i = 0; i < STARTING_ALIVE; i++) {
        const x = Math.floor(Math.random() * GRID_SIZE.x)
        const y = Math.floor(Math.random() * GRID_SIZE.y)
        setCellState(vec2(x, y), true)
    }
}

function newCellState(alive: boolean, aliveNeighbours: number) {
    // Underpopulation
    if (alive && aliveNeighbours < 2) return false
    // Overpopulation
    else if (alive && aliveNeighbours > 3) return false
    // Birth
    else if (!alive && aliveNeighbours == 3) return true
    // No change
    return alive
}

function update() {
    forEachCell(pos => {
        const alive = cellAlive(pos)
        const neighbours = NEIGHBOUR_OFFSETS.map(off => vecAdd(off, pos)).filter(neighbour => cellAlive(neighbour)).length

        setCellState(pos, newCellState(alive, neighbours))
    })
}

function render() {
    // Should be unreachable
    if (!ctx) throw new Error('Canvas context missing')

    ctx.clearRect(0, 0, canvas.width, canvas.height)

    ctx.fillStyle = 'white'
    forEachCell(pos => {
        if (cellAlive(pos)) {
            ctx.fillRect(pos.x * PIXEL_SIZE, pos.y * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE)
        }
    })
}

let active = true
setInterval((_: unknown) => {
    if (!active) return;
    update()
    render()
}, UPDATE_FREQUENCY)
reset()
update()
render()

getById<HTMLButtonElement>('gameoflife_reset').addEventListener('click', _ => {
    reset()
    update()
    render()
})

const pauseButton = getById<HTMLButtonElement>('gameoflife_pause')
pauseButton.addEventListener('click', event => {
    active = !active
    pauseButton.textContent = active ? 'Pause' : 'Unpause'
})
