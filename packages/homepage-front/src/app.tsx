import { Component } from 'preact'
import { formatSize } from './utils'
import { type CombinedResponse } from './bindings/CombinedResponse'

export class App extends Component<{}, { metrics?: CombinedResponse }> {
  timer?: number

  constructor(props: {}) {
    super(props)
    this.state = { metrics: undefined };
  }

  async refresh() {
    const res = await fetch('http://localhost:4321');
    const data: CombinedResponse = await res.json();
    this.setState({ metrics: data });
  }

  componentDidMount(): void {
    this.timer = setInterval(() => {
      this.refresh();
    }, 1000);
  }

  componentWillUnmount(): void {
    clearInterval(this.timer)
  }

  render() {
    const { metrics } = this.state;
    if (metrics === undefined) {
      return <div>Loading...</div>
    }
    return (
      <div>
        <h2>System Information</h2>
        <p>Total Memory: {formatSize(metrics.sysinfo.mem.total)}</p>
        <p>Used Memory: {formatSize(metrics.sysinfo.mem.used)}</p>
        <p>CPU Usage: {metrics.sysinfo.cpu_usage}%</p>
      </div>
    );
  }
}
