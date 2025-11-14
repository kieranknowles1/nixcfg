import { Line } from "react-chartjs-2"

export type Sample = number | bigint | undefined

export interface GraphProps {
  samples: Sample[]
  range: {
    min: number,
    max: number
  }
}

export default function Graph(props: GraphProps) {
  return <Line
    options={{
      // Animation would move a point up/down based on what the next point to
      // the right sent it, this doesn't look right as we want the graph to travel
      // right to left
      animation: false,
      scales: {
        yAxis: {
          display: false,
          // Min/max determine the height of the graph
          min: props.range.min,
          max: props.range.max,
          grid: { display: false }
        },
        xAxis: {
          display: false,
          grid: { display: false, }
        }
      }
    }}
    data={{
      // This is invisible, but required for anything to show at all
      labels: props.samples,
      datasets: [{
        xAxisID: 'xAxis',
        yAxisID: 'yAxis',
        borderColor: 'white',
        backgroundColor: 'white',
        data: props.samples
      }]
    }}
  />
}
