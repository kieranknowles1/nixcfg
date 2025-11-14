import type { SysInfo } from "./bindings/SysInfo";
import Graph from "./components/Graph";
import { GIGABYTE } from "./utils";

export interface MetricsProps {
  samples: Array<SysInfo | undefined>
}

export default function Metrics(props: MetricsProps) {
  const totalMemBytes = props.samples.length > 0 ? props.samples[0].mem.total : 0
  return (
    <>
      <p>CPU Usage</p>
      <Graph
        range={{min: 0, max: 100}}
        samples={props.samples.map(s => s?.cpu.average)}
      />
      <p>Memory Usage</p>
      <Graph
        range={{min: 0, max: totalMemBytes / GIGABYTE}}
        samples={props.samples.map(s => s?.mem.used / GIGABYTE)}
      />
    </>
  )
}
