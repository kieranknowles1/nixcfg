import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import { CategoryScale, Chart, LinearScale, LineElement, PointElement } from 'chart.js'

Chart.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
)

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
