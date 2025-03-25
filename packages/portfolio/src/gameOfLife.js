const canvas = document.querySelector('canvas#gameoflife')
const ctx = canvas.getContext('2d')

function vec2(x, y) { return { x, y }}
function vecAdd(a, b) {
    return vec2(a.x + b.x, a.y + b.y)
}

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
            cb(x, y)
        }
    }
}

for (let i = 0; i < STARTING_ALIVE; i++) {
    const x = Math.floor(Math.random() * GRID_SIZE.x)
    const y = Math.floor(Math.random() * GRID_SIZE.y)
    cells[x][y] = true
}

function cellAlive(x, y) {
    if (x < 0 || y < 0 || x > GRID_SIZE.x || y > GRID_SIZE.y) {
        return false
    }
    return cells[x][y]
}

function update() {
    forEachCell((x, y) => {
    })
}

function render() {
    ctx.fillStyle = 'black'
    ctx.fill()

    ctx.fillStyle = 'white'
    forEachCell((x, y) => {
        if (cellAlive(x, y)) {
            ctx.fillRect(x * PIXEL_SIZE, y * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE)
        }
    })
}

setInterval(_ => {
    update()
    render()
}, 500)
render()
