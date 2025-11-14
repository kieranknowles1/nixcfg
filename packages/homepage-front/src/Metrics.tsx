import type { SysInfo } from "./bindings/SysInfo";
import Graph from "./components/Graph";
import Section from "./components/Section";
import { any, GIGABYTE, latest } from "./utils";

export interface MetricsProps {
  samples: Array<SysInfo | undefined>
}

export default function Metrics(props: MetricsProps) {
  const totalMemBytes = any(props.samples)?.mem.total || 0
  const latestDat = latest(props.samples)

  return (
    <Section title="Metrics" columns={4}>
      <Graph
        title="CPU Usage"
        description={any(props.samples)?.cpu.name}
        value={`${Math.round(latestDat?.cpu.average || 0)}% Used`}
        range={{min: 0, max: 100}}
        samples={props.samples.map(s => s?.cpu.average)}
      />
      <Graph
        title="Memory Usage"
        description={`${(totalMemBytes / GIGABYTE).toFixed(1)}GB Total`}
        value={`${((latestDat?.mem.used || 0) / GIGABYTE).toFixed(1)}GB Used`}
        range={{min: 0, max: totalMemBytes / GIGABYTE}}
        samples={props.samples.map(s => s && s.mem.used / GIGABYTE)}
      />
    </Section>
  )
}
