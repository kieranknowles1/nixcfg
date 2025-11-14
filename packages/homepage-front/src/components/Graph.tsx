import { Line } from "react-chartjs-2"
import Widget from "./Widget"

export type Sample = number | bigint | undefined

export interface GraphProps {
  samples: Sample[]
  range: {
    min: number,
    max: number
  },
  title: string,
  description: string,
  value: string,
}

export default function Graph(props: GraphProps) {
  return <Widget className="grid grid-cols-1">
    <Line
      className="col-start-1 row-start-1"
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
          data: props.samples
        }]
      }}
    />
    <div className="col-start-1 row-start-1 relative">
      <span className="font-bold text-lg text-white">{props.title}</span>
      <span className="absolute bottom-0 flex italic text-gray-50">{props.description}</span>
      <span className="absolute bottom-0 right-0 italic text-gray-50">{props.value}</span>
    </div>
  </Widget>
}
