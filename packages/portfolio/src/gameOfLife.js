'use strict'

// Utilities to make working with 2D arrays easier
function vec2(x, y) { return { x, y }}
function vecAdd(a, b) {
    return vec2(a.x + b.x, a.y + b.y)
}

/** @type {HTMLCanvasElement} */
const canvas = document.getElementById('gameoflife')
const ctx = canvas.getContext('2d')

const UPDATE_FREQUENCY = 250
const PIXEL_SIZE = 10
const GRID_SIZE = vec2(canvas.width / PIXEL_SIZE, canvas.height / PIXEL_SIZE)
const STARTING_ALIVE = Math.ceil(GRID_SIZE.x * GRID_SIZE.y * 0.15)
const NEIGHBOUR_OFFSETS = [
    vec2(-1, -1), vec2(0, -1), vec2(1, -1),
    vec2(-1, 0),               vec2(1, 0),
    vec2(-1, 1),  vec2(0, 1),  vec2(1, 1)
]

const cells = Array.from({ length: GRID_SIZE.x }, (v, i) => Array.from({ length: GRID_SIZE.y }, (v, i) => false))

function forEachCell(cb) {
    for (let x = 0; x < GRID_SIZE.x; x++) {
        for (let y = 0; y < GRID_SIZE.y; y++) {
            cb(vec2(x, y))
        }
    }
}

// Defaults to `false` for out of bounds locations
function cellAlive(pos) {
    if (pos.x < 0 || pos.y < 0 || pos.x >= GRID_SIZE.x || pos.y >= GRID_SIZE.y) {
        return false
    }
    return cells[pos.x][pos.y]
}
function setCellState(pos, state) {
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

function update() {
    forEachCell(pos => {
        const alive = cellAlive(pos)
        const neighbours = NEIGHBOUR_OFFSETS.map(off => vecAdd(off, pos)).filter(neighbour => cellAlive(neighbour)).length

        // Underpopulation
        if (alive && neighbours < 2) setCellState(pos, false)
        // Overpopulation
        else if (alive && neighbours > 3) setCellState(pos, false)
        // Birth
        else if (!alive && neighbours == 3) setCellState(pos, true)
    })
}

function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height)

    ctx.fillStyle = 'white'
    forEachCell(pos => {
        if (cellAlive(pos)) {
            ctx.fillRect(pos.x * PIXEL_SIZE, pos.y * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE)
        }
    })
}

setInterval(_ => {
    update()
    render()
}, UPDATE_FREQUENCY)
reset()
update()
render()

document.getElementById('gameoflife_reset').addEventListener('click', _ => {
    reset()
    update()
    render()
})
