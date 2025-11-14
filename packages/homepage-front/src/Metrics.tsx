import type { SysInfo } from "./bindings/SysInfo";
import Graph from "./components/Graph";
import Section from "./components/Section";
import DiskGraph from "./DiskGraph";
import { GIGABYTE, latest } from "./utils";
import ChartLineIcon from 'mdi-react/ChartLineIcon'

export interface MetricsProps {
  samples: SysInfo[]
}

export default function Metrics(props: MetricsProps) {
  const totalMemBytes = props.samples[0].mem.total
  const latestDat = latest(props.samples)

  return (
    <Section title="Metrics" icon={<ChartLineIcon className="inline" />} columns={4}>
      <Graph
        title="CPU Usage"
        description={props.samples[0].cpu.name}
        value={`${Math.round(latestDat?.cpu.average || 0)}% Used`}
        range={{min: 0, max: 100}}
        samples={[props.samples.map(s => s?.cpu.average)]}
      />
      <Graph
        title="Memory Usage"
        description={`${(totalMemBytes / GIGABYTE).toFixed(1)}GB Total`}
        value={`${((latestDat?.mem.used || 0) / GIGABYTE).toFixed(1)}GB Used`}
        range={{min: 0, max: totalMemBytes / GIGABYTE}}
        samples={[props.samples.map(s => s && s.mem.used / GIGABYTE)]}
      />
      <DiskGraph
        name="Internal Disk"
        samples={props.samples.map(s => s.disk["/dev/nvme0n1p2"]!)}
      />
    </Section>
  )
}
