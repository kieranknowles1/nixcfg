import type { DiskInfo } from "./bindings/DiskInfo";
import Graph from "./components/Graph";
import { formatFilesize, latest } from "./utils";

export interface DiskGraphProps {
  name: string
  samples: DiskInfo[]
}

export default function DiskGraph(props: DiskGraphProps) {
  const latestDat = latest(props.samples)

  let maxSpeed = 0
  for (const s of props.samples) {
    maxSpeed = Math.max(maxSpeed, s.read_speed, s.write_speed)
  }

  return <Graph
    title={props.name}
    range={{min: 0, max: maxSpeed}}

    description={`${formatFilesize(latestDat.free)}/${formatFilesize(latestDat.capacity)} available`}
    samples={[
      props.samples.map(s => s.read_speed),
      props.samples.map(s => s.write_speed)
    ]}

    value={`${formatFilesize(latestDat.read_speed)}/s read. ${formatFilesize(latestDat.write_speed)}/s write.`}
  />
}
