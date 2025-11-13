import { Line } from "react-chartjs-2"

export type Sample = number | undefined

export interface GraphProps {
  samples: Sample[]
  range: {
    min: number,
    max: number
  }
}

export default function Graph(props: GraphProps) {
  console.log(props.samples)

  // T-N seconds, as data is for "this many seconds ago"
  const labels = Array.from(
    {length: props.samples.length},
    (_, i) => `T-${props.samples.length - (i + 1)}`
  )

  return <Line
    options={{
      animation: false,
      scales: {
        yAxis: {
          display: false,
          min: 0,
          max: 100
        }
      }
    }}
    data={{
      labels,
      datasets: [{
        borderColor: 'white',
        backgroundColor: 'white',
        data: props.samples
      }]
    }}
  />
}
