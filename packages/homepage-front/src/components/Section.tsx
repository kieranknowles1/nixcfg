import type { ReactNode } from "react"

type ColCount = 1 | 4

export type SectionProps = React.PropsWithChildren<{
  columns: ColCount
} & ({
  type: 'row'
  icon: ReactNode
  title: string
} | {
  type: 'multicolumn'
})>

function columnClass(cols: ColCount): string {
  switch (cols) {
    case 1: return "grid-cols-1"
    case 4: return "grid-cols-4"
  }
}

export default function Section(props: SectionProps) {
  return <section>
    {props.type == "row" && <h2 className="text-xl text-slate-50 font-bold">{props.icon} {props.title}</h2>}
    <div className={`grid ${columnClass(props.columns)}`}>
      {props.children}
    </div>
  </section>
}
