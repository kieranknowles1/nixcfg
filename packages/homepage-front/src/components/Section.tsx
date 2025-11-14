import { Children } from "react"

export type SectionProps = React.PropsWithChildren<{
  title: string
  columns: number
}>

export default function Section(props: SectionProps) {
  return <section>
    <h2 className="text-xl text-slate-50 font-bold">{props.title}</h2>
    <div className={`grid grid-cols-${props.columns}`}>
      {props.children}
    </div>
  </section>
}
